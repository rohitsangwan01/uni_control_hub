#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/standard_message_codec.h>

#include <windows.h>
#include <memory>
#include <optional>
#include <winuser.h>
#include <initguid.h>
#include <usbiodef.h>
#include <Dbt.h>
#include <string>
#include <iostream>
#include <stdexcept>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }

  RegisterPlugins(flutter_controller_->engine());

  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "@uni_control_hub/native_channel",
      &flutter::StandardMethodCodec::GetInstance());

  messageConnector = std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "@uni_control_hub/message_connector",
      &flutter::StandardMessageCodec::GetInstance());

  channel.SetMethodCallHandler([this](const flutter::MethodCall<flutter::EncodableValue> &call,
                                      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
                               { this->HandleMethodCall(call, std::move(result)); });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                      { this->Show(); });

  flutter_controller_->ForceRedraw();
  return true;
}

void FlutterWindow::OnDestroy()
{
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
{
  if (call.method_name() == "test")
  {
    result->Success(100);
  }
  else
  {
    result->NotImplemented();
  }
}

void FlutterWindow::OnUsbDeviceConnectionUpdate(bool connected)
{
  messageConnector->Send(flutter::EncodableMap{
      {"event", "device_update"},
      {"connected", connected},
  });
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  case WM_CREATE:
  {
    LPCREATESTRUCT params = (LPCREATESTRUCT)lparam;
    GUID InterfaceClassGuid = *((GUID *)params->lpCreateParams);
    DEV_BROADCAST_DEVICEINTERFACE NotificationFilter;
    ZeroMemory(&NotificationFilter, sizeof(NotificationFilter));
    NotificationFilter.dbcc_size = sizeof(DEV_BROADCAST_DEVICEINTERFACE);
    NotificationFilter.dbcc_devicetype = DBT_DEVTYP_DEVICEINTERFACE;
    memcpy(&(NotificationFilter.dbcc_classguid), &(GUID_DEVINTERFACE_USB_DEVICE), sizeof(struct _GUID));
    HDEVNOTIFY dev_notify = RegisterDeviceNotification(hwnd, &NotificationFilter, DEVICE_NOTIFY_WINDOW_HANDLE);
    if (dev_notify == NULL)
    {
      std::cout << "Could not register for devicenotifications!" << std::endl;
    }
    break;
  }

  case WM_DEVICECHANGE:
  {
    PDEV_BROADCAST_HDR lpdb = (PDEV_BROADCAST_HDR)lparam;
    if (lpdb != nullptr && lpdb->dbch_devicetype == DBT_DEVTYP_DEVICEINTERFACE)
    {
      // PDEV_BROADCAST_DEVICEINTERFACE lpdbv = (PDEV_BROADCAST_DEVICEINTERFACE)lpdb;
      // auto path = lpdbv->dbcc_name;
      switch (wparam)
      {
      case DBT_DEVICEARRIVAL:
        OnUsbDeviceConnectionUpdate(true);
        break;
      case DBT_DEVICEREMOVECOMPLETE:
        OnUsbDeviceConnectionUpdate(false);
        break;
      }
    }
  }
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
