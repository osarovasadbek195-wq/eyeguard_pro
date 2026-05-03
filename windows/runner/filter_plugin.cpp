#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>
#include <dwmapi.h>

class FilterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  FilterPlugin();
  ~FilterPlugin();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  HWND overlay_window_ = nullptr;
};

void FilterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "eyeguard_pro/filter",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FilterPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FilterPlugin::FilterPlugin() {}

FilterPlugin::~FilterPlugin() {
  if (overlay_window_ != nullptr) {
    DestroyWindow(overlay_window_);
  }
}

void FilterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == "startFilter") {
    // Create transparent overlay window with color filter
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "stopFilter") {
    if (overlay_window_ != nullptr) {
      DestroyWindow(overlay_window_);
      overlay_window_ = nullptr;
    }
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "updateFilter") {
    // Update filter parameters
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}
