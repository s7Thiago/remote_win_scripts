import 'dart:async';

import 'package:app/ler_parametros_github.dart' as params;
import 'package:app/processos_windows.dart' as processos;
import 'package:app/criar_autostart_script.dart' as arquivos;
import 'package:intl/intl.dart';

bool verificarHorario(String horarioInicio, String horarioLimite) {
  // Converta a string para um objeto DateTime
  DateFormat formatador = DateFormat("HH:mm");

  DateTime agora = DateTime.now();
  DateTime inicio = formatador.parse(horarioInicio);
  inicio =
      DateTime(agora.year, agora.month, agora.day, inicio.hour, inicio.minute);

  DateTime limite = formatador.parse(horarioLimite);
  limite =
      DateTime(agora.year, agora.month, agora.day, limite.hour, limite.minute);

  bool inicioValido = agora.isAfter(inicio);
  bool limiteValido = agora.isBefore(limite);

  return inicioValido && limiteValido;
}

void main(List<String> arguments) async {
  // baixa os parametros do github
  var paramsGithub = await params.getParams();

  // pega os processos
  var listaProcessos = await processos.getProcessos();
  int numero = 1;
  print('Executando a ${numero++} vez');
  bool isFreeTimeInterval = verificarHorario(
      paramsGithub.horarioLivreInicio, paramsGithub.horarioLivreLimite);

  if (!isFreeTimeInterval) {
    print(
        '(${paramsGithub.intervaloRepeticoes}s) [${paramsGithub.horarioLivreInicio} - ${paramsGithub.horarioLivreLimite}] Horário bloqueado. iniciando encerramento de processos');
    processos.encerrarProcessos(listaProcessos, paramsGithub.whitelist, paramsGithub);
  } else {
    print(
        '(${paramsGithub.intervaloRepeticoes}s) [${paramsGithub.horarioLivreInicio} - ${paramsGithub.horarioLivreLimite}] Horário liberado. nenhum processo será encerrado');
    print('USERPROFILE: ${arquivos.windowsStartupPath}');
    // arquivos.criarAutostartScript();
  }

  Future.delayed(Duration(seconds: paramsGithub.intervaloRepeticoes), () {
    main(arguments);
  });
}
