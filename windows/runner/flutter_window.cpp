#include "flutter_window.h"

#include <optional>
#include "flutter/generated_plugin_registrant.h"

#include <windows.h> // zymixx
#include <flutter/method_channel.h> //zymixx
#include <flutter/standard_method_codec.h> //zymixx
#include <iostream> // Для использования std::cout
#include <flutter/method_call.h>

void SimulateMouseClick() {
    POINT cursorPos;

    // Получить текущие координаты курсора
    if (GetCursorPos(&cursorPos)) {
        int x = cursorPos.x;
        int y = cursorPos.y;

        Sleep(30); // 30 мс задержка, можно настроить при необходимости

        // Получение разрешения экрана
        int screenX = GetSystemMetrics(SM_CXSCREEN);
        int screenY = GetSystemMetrics(SM_CYSCREEN);

        // Первый клик: нажатие
        INPUT input = {0};

        ZeroMemory(&input, sizeof(INPUT));
        input.type = INPUT_MOUSE;
        input.mi.dx = MulDiv(x, 65536, screenX);
        input.mi.dy = MulDiv(y, 65536, screenY);
        input.mi.dwFlags = MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTDOWN;
        SendInput(1, &input, sizeof(INPUT));

        Sleep(25);

        // Второй клик: отпускание
        ZeroMemory(&input, sizeof(INPUT));
        input.type = INPUT_MOUSE;
        input.mi.dx = MulDiv(x, 65536, screenX);
        input.mi.dy = MulDiv(y, 65536, screenY);
        input.mi.dwFlags = MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTUP;
        SendInput(1, &input, sizeof(INPUT));

        ZeroMemory(&input, sizeof(INPUT));
        input.type = INPUT_MOUSE;
        input.mi.dx = MulDiv(x, 65536, screenX);
        input.mi.dy = MulDiv(y, 65536, screenY);
        input.mi.dwFlags = MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTDOWN;
        SendInput(1, &input, sizeof(INPUT));

        Sleep(25);

        // Второй клик: отпускание
        ZeroMemory(&input, sizeof(INPUT));
        input.type = INPUT_MOUSE;
        input.mi.dx = MulDiv(x, 65536, screenX);
        input.mi.dy = MulDiv(y, 65536, screenY);
        input.mi.dwFlags = MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_MOVE | MOUSEEVENTF_LEFTUP;
        SendInput(1, &input, sizeof(INPUT));
    }
}
FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.

    auto engine = flutter_controller_->engine();
    if (engine) {
        HWND hwnd = GetHandle();
        ShowWindow(hwnd, SW_MAXIMIZE);

        flutter::MethodChannel<> channel(
                engine->messenger(), "ru.zymixx/simulateMouseClick",
                &flutter::StandardMethodCodec::GetInstance()
        );

        channel.SetMethodCallHandler(
                [hwnd](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
                    if (call.method_name() == "simulateMouseClick") {
                        SimulateMouseClick();
                        result->Success();
                    } else {
                        result->NotImplemented();
                    }
                }
        );
    }
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
