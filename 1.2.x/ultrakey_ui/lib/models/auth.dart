import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:ffi/ffi.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:mime/mime.dart';
import 'package:ultrakey_ui/models/value_update_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win32/win32.dart';

enum AuthState {
  awaitingLogin,
  awaitingToken,
  validToken,
  invalidToken,
  nolicense,
  validLogin,
  banned,
}

class AuthStorage {
  static final String tokenFilePath = p.join(
    Directory.current.path,
    'license.key',
  );
  static final String salt = "c06005db-9d98-4bad-afe1-9bd0c8a2db7f";

  static String getHardwareId() {
    const keyPath = r'SOFTWARE\Microsoft\Cryptography';
    const valueName = 'MachineGuid';

    final hKey = calloc<HKEY>();
    final lpSubKey = TEXT(keyPath);
    final result =
        RegOpenKeyEx(HKEY_LOCAL_MACHINE, lpSubKey, 0, KEY_READ, hKey);

    if (result != ERROR_SUCCESS) {
      calloc.free(lpSubKey);
      calloc.free(hKey);
      throw Exception('Failed to open registry key: $result');
    }

    final buffer = calloc<Uint8>(256);
    final dataSize = calloc<Uint32>()..value = 256;

    final valueResult = RegQueryValueEx(
      hKey.value,
      TEXT(valueName),
      nullptr,
      nullptr,
      buffer,
      dataSize,
    );

    RegCloseKey(hKey.value);
    calloc.free(lpSubKey);
    calloc.free(hKey);

    if (valueResult != ERROR_SUCCESS) {
      calloc.free(buffer);
      calloc.free(dataSize);
      throw Exception('Failed to query registry value: $valueResult');
    }

    final guid = utf8.decode(buffer.asTypedList(dataSize.value));
    calloc.free(buffer);
    calloc.free(dataSize);
    return guid.trim();
  }

  static Uint8List deriveKey(
    String hardwareId, {
    int iterations = 100000,
    int length = 32,
  }) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(utf8.encode(salt), iterations, length);
    derivator.init(params);
    return derivator.process(utf8.encode(hardwareId));
  }

  static void delToken() {
    File(tokenFilePath).writeAsStringSync("");
  }

  static void saveToken(String token) {
    final hardwareId = getHardwareId();
    final keyBytes = deriveKey(hardwareId);
    final key = encrypt.Key(keyBytes);

    final iv = encrypt.IV.fromLength(16);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(token, iv: iv);

    final file = File(tokenFilePath);
    file.writeAsBytesSync(iv.bytes + encrypted.bytes);
  }

  static String? loadToken() {
    final file = File(tokenFilePath);
    if (!file.existsSync()) return null;

    final bytes = file.readAsBytesSync();
    if (bytes.length < 16) return null;

    final iv = encrypt.IV(Uint8List.fromList(bytes.sublist(0, 16)));
    final cipherText = bytes.sublist(16);

    final hardwareId = getHardwareId();
    final keyBytes = deriveKey(hardwareId);
    final key = encrypt.Key(keyBytes);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    try {
      final decrypted =
          encrypter.decrypt(encrypt.Encrypted(cipherText), iv: iv);
      return decrypted;
    } catch (_) {
      return null;
    }
  }
}

class AuthServer {
  static const String ukPlusId = "1366679702567260180";
  static const String premiumId = "1353625280111181856";
  static const String ownerId = "1353186170724683924";
  static const String giftedId = "1354086033108762624";
  static const String guildId = "1353186170711965836";
  static const String revokedId = "1366878376262107288";
  static const String lifetimeId = "1366877501481160807";

  static const String tempAuthUrl = "https://ultrakey.onrender.com/getkey";
  static const String discAuthUrl = "https://ultrakey.onrender.com/access";

  static const int port = 49152;
  static HttpServer? _server;
  static StreamController updateNotifier = StreamController.broadcast();
  static ValueUpdateStream updateStream = ValueUpdateStream();
  static AuthState state = AuthState.awaitingLogin;
  static String? currentToken;

  static StreamSubscription listen(void Function(dynamic) callback) {
    return updateNotifier.stream.listen(callback);
  }

  static void notify() {
    updateNotifier.add(null);
  }

  static Future<void> _serveHtml(
    HttpRequest request,
    String path,
    int statusCode,
  ) async {
    final file = File(path);
    final content = await file.exists()
        ? await file.readAsString()
        : "<html><body><h1>Error</h1></body></html>";

    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.html
      ..write(content);

    await request.response.close();
  }

  static Future<bool> _serveStaticFile(
    HttpRequest request, {
    required String basePath,
  }) async {
    final uriPath = request.uri.path;
    final normalizedPath = Uri.decodeComponent(uriPath);

    final file = File('$basePath$normalizedPath');
    if (await file.exists()) {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.parse(mimeType)
        ..add(await file.readAsBytes());
      await request.response.close();
      return true;
    } else {
      return false;
    }
  }

  static Future<void> start() async {
    if (_server != null) return;

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    printf("AuthServer running at http://localhost:$port");

    _server!.listen((HttpRequest request) async {
      if (await _serveStaticFile(request, basePath: './assets')) {
        return;
      }

      final uri = request.uri;

      final token = uri.queryParameters['access_token'];
      if (token != null && token.isNotEmpty) {
        printf("Access token received: $token");
        String? discordToken = await fetchDiscordToken(token);
        updateStream.push(id: "gotToken", value: discordToken);
        await _serveHtml(request, 'assets/success.html', HttpStatus.ok);
      } else {
        updateStream.push(id: "gotToken", value: null);
        await _serveHtml(request, 'assets/failed.html', HttpStatus.badRequest);
      }

      await request.response.close();
    });
  }

  static Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
      printf('AuthServer stopped.');
    } else {
      printf('AuthServer is not running.');
    }
  }

  static Future<String?> fetchDiscordToken(String tempToken) async {
    final uri = Uri.parse('$discAuthUrl?access_token=$tempToken');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'] as String?;
    } else {
      printf(
        'Failed to get access token: ${response.statusCode} ${response.body}',
      );
      return null;
    }
  }

  static void openDiscordOAuth() {
    final clientId = '1353490529660309524';
    final redirectUri = Uri.encodeComponent(tempAuthUrl);
    final scope = Uri.encodeComponent('identify guilds guilds.members.read');
    final responseType = 'code';

    final authUrl = Uri.parse(
      'https://discord.com/oauth2/authorize'
      '?client_id=$clientId'
      '&redirect_uri=$redirectUri'
      '&response_type=$responseType'
      '&scope=$scope',
    ).toString();

    printf('Opening browser to:\n$authUrl');

    // For Flutter apps or Dart CLI on Windows/macOS
    launchUrl(
      Uri.parse(authUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  static Future<List<String>> getSubscribed(
    String guildId,
    String accessToken,
  ) async {
    final url =
        Uri.parse('https://discord.com/api/users/@me/guilds/$guildId/member');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final roles = List<String>.from(data['roles'] ?? []);
      return roles;
    } else {
      printf(
        "Failed to get member info: ${response.statusCode} ${response.body}",
      );
      return [];
    }
  }

  static Future<List<String>> getGuilds(String accessToken) async {
    final url = Uri.parse('https://discord.com/api/users/@me/guilds');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((guild) => guild['id'] as String).toList();
    } else {
      printf("Failed to fetch guilds: ${response.statusCode} ${response.body}");
      return [];
    }
  }

  static Future<bool> isTokenValid(String accessToken) async {
    final url = Uri.parse('https://discord.com/api/users/@me');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      printf("Token is valid.");
      return true;
    } else {
      printf("Token is invalid. Status code: ${response.statusCode}");
      return false;
    }
  }
}
