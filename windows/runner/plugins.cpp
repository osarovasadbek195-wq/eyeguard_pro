#include <flutter/plugin_registrar_windows.h>

#include "autostart_plugin.h"
#include "filter_plugin.h"

void RegisterPlugins(flutter::PluginRegistrarWindows *registrar) {
  AutostartPlugin::RegisterWithRegistrar(registrar);
  FilterPlugin::RegisterWithRegistrar(registrar);
}
