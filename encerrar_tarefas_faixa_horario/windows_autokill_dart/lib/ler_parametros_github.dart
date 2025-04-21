import 'dart:io';
import 'dart:convert';

Future<Map<String, dynamic>> _lerParametros() async {
  // Requisitar o json e salvar numa string
  final url = Uri.parse(
      'https://raw.githubusercontent.com/s7Thiago/remote_win_scripts/refs/heads/main/encerrar_tarefas_faixa_horario/params.json');
  final client = HttpClient();

  final request = await client.getUrl(url);
  final response = await request.close();
  final statusCode = response.statusCode;

  if (statusCode == 200) {
    final json = await response.transform(utf8.decoder).join();
    // Converter a string para um map
    // Retornar o map
    return Future.value(jsonDecode(json));
  } else {
    print('Erro $statusCode ao requisitar o arquivo');
  }

  return Future.value({});
}

Future<AutoKillParams> getParams() async {
  Map<String, dynamic> data;
  try {
    data = await _lerParametros();
  } catch (e) {
    return AutoKillParams();
  }

  // print('inicio: ${data['HORARIO_LIVRE_INICIO']}');
  // print('limite: ${data['HORARIO_LIVRE_LIMITE']}');
  // print('intervalo: ${data['SEGUNDOS_REPETIR']}');
  // print('modo: ${data['MODO_ENCERRAMENTO']}');
  // print('whitelist: ${data['WHITELIST']}');
  // print('==============================================\n');

  var modoEncerramento = ModoEncerramento.values.firstWhere(
      (element) =>
          element.toString() == 'ModoEncerramento.${data['MODO_ENCERRAMENTO'].toString().toLowerCase()}',
      orElse: () => ModoEncerramento.shutdown);

  return AutoKillParams(
    horarioLivreInicio: data['HORARIO_LIVRE_INICIO'],
    horarioLivreLimite: data['HORARIO_LIVRE_LIMITE'],
    intervaloRepeticoes: data['SEGUNDOS_REPETIR'],
    modoEncerramento: modoEncerramento,
    whitelist:
        (data['WHITELIST'] as List<dynamic>).map((e) => e.toString()).toList(),
  );
}

enum ModoEncerramento { restart, shutdown, logoff }

class AutoKillParams {
  final String horarioLivreInicio;
  final String horarioLivreLimite;
  final int intervaloRepeticoes;
  final List<String> whitelist;
  final ModoEncerramento
      modoEncerramento; // RESTART, SHUTDOWN, LOGOFF (NÃO IMPLEMENTADO)

  AutoKillParams({
    this.horarioLivreInicio = '07:00',
    this.horarioLivreLimite = '23:00',
    this.intervaloRepeticoes = 15,
    this.modoEncerramento = ModoEncerramento.shutdown,
    this.whitelist = const ["system_taskbar", "taskbar", "system"],
  });
}
