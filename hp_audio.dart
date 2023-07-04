import 'package:anim_studio/base/hp_device.dart';
import 'package:anim_studio/base/hp_file.dart';
import 'package:audioplayers/audioplayers.dart';

class HpAudio {
  HpAudio._();

  static Future<AudioPlayer?> playAudio(String? path) {
    if (path == null) {
      return Future.value(null);
    } else {
      AudioPlayer player = AudioPlayer();
      player.audioCache.prefix = '';
      Future<void> f = HpFile.inAssets(path)
          ? player.setSourceAsset(path)
          : player.setSourceDeviceFile(path);
      return f.onError(
        (error, stackTrace) {
          HpDevice.log('\nerror: \n$error\nstackTrace: \n$stackTrace');
          player.release();
        },
      ).then((_) => Future.value(player.source != null ? player : null));
    }
  }
}
