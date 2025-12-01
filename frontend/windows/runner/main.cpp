#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

// --- ADIÇÃO PARA CORRIGIR A FLUIDEZ (144Hz) ---
// Inclui a biblioteca de tempo multimídia do Windows
#include <timeapi.h>
// Instrui o linker a incluir a biblioteca winmm.lib
#pragma comment(lib, "winmm.lib") 
// ----------------------------------------------

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {

  // --- ATIVAR ALTA PRECISÃO DO TIMER ---
  // Define a resolução do timer do Windows para 1ms.
  // Isso reduz a latência do agendador do Windows, permitindo que o Flutter
  // desenhe quadros mais rapidamente em monitores High Refresh Rate.
  ::timeBeginPeriod(1);
  // -------------------------------------

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"SGC Pro", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // --- DESATIVAR ALTA PRECISÃO ---
  // É uma boa prática restaurar a configuração ao fechar o app.
  ::timeEndPeriod(1);
  // -------------------------------

  ::CoUninitialize();
  return EXIT_SUCCESS;
}