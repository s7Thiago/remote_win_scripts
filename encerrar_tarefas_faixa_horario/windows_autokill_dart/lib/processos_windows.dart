import 'dart:io';

import 'package:app/ler_parametros_github.dart';

Future<List<Processo>> getProcessos() async {
  final result = await Process.run('tasklist', ['/fo', 'csv', '/nh']);
  if (result.exitCode == 0) {
    String dados = result.stdout;
    return _parseProcessos(dados);
  } else {
    print('Erro ao executar o comando tasklist: ${result.stderr}');
  }

  return Future.value([]);
}

List<Processo> _parseProcessos(String dados) {
  final linhas = dados.trim().split('\n');
  List<Processo> processos = [];

  for (var linha in linhas) {
    final colunas = linha.replaceAll('"', '').split(',');
    try {
      processos.add(Processo(
        executavel: colunas[0],
        pid: int.parse(colunas[1]),
        sessao: colunas[2],
        numeroSessao: colunas[3],
        usoMemoria: colunas[4],
      ));
    } catch (e) {
      print('Erro ao processar a linha: $linha');
    }
  }

  return processos;
}

void _encerrarProcesso(Processo processo, List<String> whitelist) {
  bool isWhitelisted = whitelist.contains(processo.executavel.toLowerCase());

  for (var item in whitelist) {
    if (processo.executavel.toLowerCase().contains(item.toLowerCase())) {
      isWhitelisted = true;
      break;
    }
  }

  // Verifica se o processo está na whitelist
  if (isWhitelisted) {
    print('* O processo ${processo.executavel} está na whitelist');
    return;
  }

  final result = Process.runSync('taskkill', ['/F', "/PID", '${processo.pid}']);
  if (result.exitCode == 0) {
    print('Processo ${processo.executavel} encerrado com sucesso');
  } else {
    print(
        'Erro ao encerrar o processo ${processo.executavel}: ${result.stderr}');
  }
}

void _desligarMaquinaReiniciar({required AutoKillParams params}) async {
  bool reiniciar = params.modoEncerramento == ModoEncerramento.restart;
// Configurando os parâmetros
  // /s = desligar
  // /r = reiniciar
  // /f = forçar fechamento de programas
  // /t 0 = tempo de espera de 0 segundos
  final List<String> parametros = [
    reiniciar ? '/r' : '/s',
    '/f',
    '/t', '0'
  ];
  
  try {
    final result = await Process.run('shutdown', parametros);
    if (result.exitCode == 0) {
      print(reiniciar ? 'Reiniciando o sistema...' : 'Desligando o sistema...');
    } else {
      print('Erro ao ${reiniciar ? "reiniciar" : "desligar"} o sistema: ${result.stderr}');
    }
  } catch (e) {
    print('Exceção ao executar o comando: $e');
  }
}

void _reiniciarMaquina() {
  final result = Process.runSync('shutdown', ['/r', '/t', '0']);
  if (result.exitCode == 0) {
    print('Comando de reinicialização enviado com sucesso');
  } else {
    print('Erro ao tentar reiniciar o computador: ${result.stderr}');
  }
}

void encerrarProcessos(List<Processo> processos, List<String> whitelist, AutoKillParams params) {
  // reiniciar a máquina
  _desligarMaquinaReiniciar(params: params);

  // for (var p in processos) {
  //   _encerrarProcesso(p, whitelist);
  // }
}

class Processo {
  final String executavel;
  final int pid;
  final String sessao;
  final String numeroSessao;
  final String usoMemoria;

  Processo({
    required this.executavel,
    required this.pid,
    required this.sessao,
    required this.numeroSessao,
    required this.usoMemoria,
  });

  @override
  toString() {
    return 'PID: $pid, Executável: $executavel - Sessão: $sessao, Número da Sessão: $numeroSessao, Uso de Memória: $usoMemoria';
  }
}
