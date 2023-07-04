// import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:io' as io;

import 'package:anim_studio/base/hp_device.dart';
import 'package:flutter/foundation.dart';

import 'package:file_picker/file_picker.dart';

class HpPlatform {
  HpPlatform._();

  static bool isWeb() => kIsWeb;

  static bool isMac() => kIsWeb ? false : io.Platform.isMacOS;

  static bool isAndroid() => kIsWeb ? false : io.Platform.isAndroid;

  static bool isIOS() => kIsWeb ? false : io.Platform.isIOS;

  static void web() {
    if (HpPlatform.isWeb()) {
      FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pic', 'xml', 'plist'],
      ).then(
        (r) {
          HpDevice.log(r.toString());
        },
      );
      // var blob = Blob(["data"], 'text/plain', 'native');
      // AnchorElement(href: Url.createObjectUrlFromBlob(blob).toString())
      //   ..setAttribute("download", "data.txt")
      //   ..click();
    }
  }
}
