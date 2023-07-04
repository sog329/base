#ifndef FLUTTER_PLUGIN_BASE_PLUGIN_H_
#define FLUTTER_PLUGIN_BASE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace base {

class BasePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BasePlugin();

  virtual ~BasePlugin();

  // Disallow copy and assign.
  BasePlugin(const BasePlugin&) = delete;
  BasePlugin& operator=(const BasePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace base

#endif  // FLUTTER_PLUGIN_BASE_PLUGIN_H_
