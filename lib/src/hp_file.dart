import 'dart:convert';
import 'dart:io';
import 'dart:ui' hide decodeImageFromList;

import 'package:base/src/config_lru_cache.dart';
import 'package:base/src/hp_device.dart';
import 'package:base/src/hp_platform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'image_lru_cache.dart';

class HpFile {
  HpFile._();

  static bool inAssets(String path) {
    return !path.startsWith('/');
  }

  static Future<Uint8List?> unit8<T>({
    required String path,
    T? t,
    bool Function(T? t)? need,
    bool useCache = false,
  }) {
    Uint8List? r = useCache ? ConfigLruCache.get(path) : null;
    if (r != null) {
      return Future.value(r);
    } else {
      Future<Uint8List?> none = Future.value(null);
      Future<Uint8List?> future = none;
      if (inAssets(path)) {
        // asset文件夹
        future = rootBundle.load(path).then(
          (data) {
            if (need == null || need.call(t)) {
              return Uint8List.view(data.buffer);
            } else {
              return none;
            }
          },
        );
      } else {
        // 本地磁盘
        File file = File(path);
        future = file.exists().then(
              (b) => (need == null || need.call(t)) && b ? file.readAsBytes() : none,
            );
      }
      return future.then(
        (v) {
          if (v != null && useCache) {
            ConfigLruCache.put(path, v); // 此处是cache中没有获取到的值
          }
          return Future.value(v);
        },
      );
    }
  }

  static Future<Image?> image<T>({
    required String path,
    T? t,
    bool Function(T? t)? need,
    bool useCache = false,
  }) {
    Image? img = useCache ? ImageLruCache.get(path) : null;
    if (img != null) {
      return Future.value(img);
    } else {
      Future<Image?> none = Future(() => null);
      return unit8(
        path: path,
        t: t,
        need: need,
        useCache: useCache,
      ).then(
        (data) {
          if (data == null) {
            return none;
          } else {
            if (need == null || need.call(t)) {
              Uint8List lst = Uint8List.view(data.buffer);
              return decodeImageFromList(lst).then(
                (img) {
                  if (useCache) {
                    ImageLruCache.put(path, img);
                  }
                  return Future.value(img);
                },
              );
            } else {
              return none;
            }
          }
        },
      );
    }
  }

  static String folderName(String path) {
    String name = path;
    if (path.contains('/')) {
      name = path.substring(0, path.lastIndexOf('/'));
      name = name.substring(name.lastIndexOf('/') + 1);
    }
    return name;
  }

  static String fileName(String path, [bool hasSuffix = true]) {
    if (!path.endsWith('/')) {
      path = '$path/';
    }
    String name = folderName(path);
    if (!hasSuffix) {
      int n = name.lastIndexOf(".");
      if (n > -1) {
        name = name.substring(0, n);
      }
    }
    return name;
  }

  static File? fileSync(Directory d, String fileName) {
    String path = d.path;
    File? file = File('${d.path}${path.endsWith('/') ? '' : '/'}$fileName');
    if (!file.existsSync()) {
      HpDevice.log('hasFileSync: $fileName not in ${d.path}');
      file = null;
    }
    return file;
  }

  static Future<File> createFile(String path) {
    File f = File(path);
    return f.exists().then(
      (b) {
        Future<File> create = f.create();
        if (b) {
          return f.delete().then((_) => create);
        } else {
          return create;
        }
      },
    );
  }

  static Future<Directory?> appDirectory([String? sdFolderName]) {
    if (HpPlatform.isWeb()) {
      return Future.value(null);
    } else if (HpPlatform.isAndroid() && sdFolderName != null) {
      return Future.value(Directory('/sdcard/$sdFolderName'));
    } else {
      return getApplicationDocumentsDirectory();
    }
  }

  static Future<List<String>> lstFilePath(String folderPath, bool Function(String path) filter) {
    Directory d = Directory(folderPath);
    return d.exists().then(
      (b) {
        List<String> lstFilePath = [];
        if (b) {
          d.listSync().forEach(
            (f) {
              String p = f.path;
              if (filter.call(p)) {
                lstFilePath.add(p);
              }
            },
          );
        } else {
          HpDevice.log('HpFile.lstFilePath(): $folderPath not exists');
        }
        return Future.value(lstFilePath);
      },
    );
  }

  // 下载文件
  static Future<File> download({
    required String url,
    required String path,
    ProgressCallback? progress,
  }) =>
      Dio()
          .get(url,
              onReceiveProgress: progress,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: false,
              ))
          .then(
        (response) {
          if (response.data != null) {
            return createFile(path).then((file) => file.writeAsBytes(response.data));
          } else {
            throw HpDevice.exp('no data in: $url');
          }
        },
      );

  static Future<Response> upload(String url, List<String> lstPath) {
    List<Future<MultipartFile>> lstFuture = [];
    for (String path in lstPath) {
      lstFuture.add(MultipartFile.fromFile(
        path,
        filename: fileName(path),
      ));
    }
    return Future.wait(lstFuture).then(
      (lst) => Dio().post(
        url,
        data: FormData.fromMap({
          'name': 'dio',
          'date': DateTime.now().toIso8601String(),
          'files': lst,
        }),
      ),
    );
  }

  static Future<File> tinyPic(String path, Uint8List buf) => Dio()
          .post(
        'https://api.tinify.com/shrink',
        options: Options(
          contentType: 'image/png',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Basic ${base64Encode(utf8.encode('j2Sytf0RW43dp0TCzfFfL998wPsPK9md'))}',
          },
        ),
        data: Stream.fromIterable(buf.map((e) => [e])),
      )
          .then(
        (response) {
          if (response.statusCode == HttpStatus.created) {
            return download(
              url: jsonDecode(response.toString())['output']['url'],
              path: path,
            );
          } else {
            throw HpDevice.exp(response.toString());
          }
        },
      );
}
