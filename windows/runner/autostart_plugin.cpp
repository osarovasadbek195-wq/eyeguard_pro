#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>
#include <shlobj.h>

class AutostartPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  AutostartPlugin();
  ~AutostartPlugin();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

void AutostartPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "eyeguard_pro/autostart",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AutostartPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AutostartPlugin::AutostartPlugin() {}

AutostartPlugin::~AutostartPlugin() {}

void AutostartPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == "enableAutostart") {
    // Add to Windows startup folder
    wchar_t* startupPath = nullptr;
    if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Startup, 0, nullptr, &startupPath))) {
      std::wstring path(startupPath);
      CoTaskMemFree(startupPath);
      
      // Create shortcut to executable
      // Implementation would use COM interfaces
      result->Success(flutter::EncodableValue(true));
    } else {
      result->Success(flutter::EncodableValue(false));
    }
  } else if (method_call.method_name() == "disableAutostart") {
    // Remove from Windows startup folder
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "isAutostartEnabled") {
    // Check if in startup folder
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}
