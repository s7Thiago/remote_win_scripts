import 'dart:io';

final location = 'C:\\Windows\\system_taskbar.exe';
final vbsFile = 'C:\\Windows\\system_taskbar_autostart.vbs';
final windowsStartupPath = '${getUserHome()}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup';
final String _script = '''
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "$location" & Chr(34), 0
Set WshShell = Nothing
''';

String getUserHome() {
  final String? home = Platform.environment['USERPROFILE'];
  if (home == null) {
    throw Exception('Could not find home directory');
  }
  return home;
}

void criarAutostartScript() {
  final file = File(windowsStartupPath);
  Platform.isWindows ? file.createSync(recursive: true) : file.createSync();
  file.writeAsStringSync(_script);
}