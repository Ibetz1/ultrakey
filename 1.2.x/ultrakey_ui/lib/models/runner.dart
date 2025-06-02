import 'package:ffi/ffi.dart';
import 'package:launcher/models/libraries.dart';
import 'package:launcher/models/utils.dart';

class UltrakeyRunner {
  static bool running = false;

  static void start(String configJson, Map<String, String> scriptSource) {
    try {
      emuStop();
      final configUtf8 = configJson.toNativeUtf8();

      emuRun();
      emuPushConfig(configJson.toNativeUtf8());

      for (String source in scriptSource.values) {
        emuPushScript(source.toNativeUtf8());
      }

      malloc.free(configUtf8);
      running = true;
    } catch (e) {
      printf("error starting emulator $e");
    }
  }

  static void stop() {
    try {
      emuStop();
      running = false;
    } catch (e) {
      printf("error stopping emulator $e");
    }
  }
}

