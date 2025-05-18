import 'package:ffi/ffi.dart';
import 'package:ultrakey_ui/models/libraries.dart';
import 'package:ultrakey_ui/models/utils.dart';

class UltrakeyRunner {
  static bool running = false;

  static void start(String config) {
    try {
      emuStop();
      final configUtf8 = config.toNativeUtf8();
      emuMain(configUtf8);
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

