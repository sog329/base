#include "include/base/base_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "base_plugin.h"

void BasePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  base::BasePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
