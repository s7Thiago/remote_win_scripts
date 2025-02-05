package com.thiago.windows.autokill;

import java.io.InputStream;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public class Main {
    private static String HORARIO_LIVRE_INICIO;
    private static String HORARIO_LIVRE_LIMITE;
    private static int SEGUNDOS_REPETIR;

    public static void main(String[] args) {

        fetchParams();

        // Verifica se o horário atual está fora do intervalo permitido
        LocalTime now = LocalTime.now(ZoneId.of("America/Sao_Paulo"));
        LocalTime inicio = LocalTime.parse(HORARIO_LIVRE_INICIO);
        LocalTime limite = LocalTime.parse(HORARIO_LIVRE_LIMITE);

        boolean canBlockByStartHour = now.isBefore(inicio);
        boolean canBlockByEndHour = now.isAfter(limite);
        boolean canKill =  canBlockByStartHour || canBlockByEndHour;
        if (canKill) {
            killUserProcesses();
        } else {
            System.out.printf("A faixa (%s até %s) está no horário permitido. Não será feito nada a cada %ss.\n", HORARIO_LIVRE_INICIO, HORARIO_LIVRE_LIMITE, SEGUNDOS_REPETIR);
        }

        // Repete a verificação a cada SEGUNDOS_REPETIR segundos
        while (true) {
            try {
                Thread.sleep(SEGUNDOS_REPETIR * 1000);
                main(args);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
         
    }

       private static void fetchParams() {
        try {
            // URL do params.json no GitHub (substitua pelo seu link correto)
            String url = "https://raw.githubusercontent.com/s7Thiago/remote_win_scripts/refs/heads/main/encerrar_tarefas_faixa_horario/params.json";
            
            // Baixa o JSON
            InputStream inputStream = new URL(url).openStream();
            String json = new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
            
            // Converte JSON para um mapa de valores
            // ObjectMapper objectMapper = new ObjectMapper();
            // Map<String, Object> params = objectMapper.readValue(json, new TypeReference<>() {});
            Map<String, Object> params = parseJson(json);

            // Atribui valores às variáveis globais
            HORARIO_LIVRE_INICIO = (String) params.get("HORARIO_LIVRE_INICIO");
            HORARIO_LIVRE_LIMITE = (String) params.get("HORARIO_LIVRE_LIMITE");
            SEGUNDOS_REPETIR = (Integer) params.get("SEGUNDOS_REPETIR");

            System.out.println("Parâmetros carregados com sucesso!\n");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Map<String, Object> parseJson(String json) {
        Map<String, Object> map = new HashMap<>();

        // Remove as chaves { } do início e fim da string
        json = json.trim();
        if (json.startsWith("{")) {
            json = json.substring(1);
        }
        if (json.endsWith("}")) {
            json = json.substring(0, json.length() - 1);
        }

        // Remove espaços desnecessários
        json = json.replaceAll("\\s+", "");

        // Divide os pares chave:valor
        String[] pairs = json.split(",");

        for (String pair : pairs) {
            // Divide apenas no primeiro ":"
            String[] keyValue = pair.split(":", 2);

            // Remove aspas e caracteres indesejados das chaves e valores
            String key = keyValue[0].replaceAll("[\"{}]", "").trim();
            String value = keyValue[1].replaceAll("[\"{}]", "").trim();

            // Verifica se o valor é um número
            if (value.matches("\\d+")) {
                map.put(key, Integer.parseInt(value)); // Converte para inteiro
            } else {
                map.put(key, value); // Mantém como string
            }
        }
        return map;
    }
    
    
    private static void killUserProcesses() {
        ProcessHandle.allProcesses().forEach(process -> killProcess(process));
        System.out.println("################ TODOS os processos foram carregados e destruídos com sucesso! ################");
    }

    private static void killProcess(ProcessHandle process) {
        System.out.printf("(%ss) Um processo foi encerrado: %s\n", SEGUNDOS_REPETIR, processDetails(process));
        try {

            String details = processDetails(process);
            List<String> whitelist = List.of(
                "windows.autokill",
                "windows-autokill",
                "autokill",
                "energy",
                "taskmgr",
                "screensaver",
                "video",
                "taskbar",
                "System",
                "docker",
                "vscode","vs-code",
                "chrome",
                "firefox",
                "edge",
                "explorer",
                "powershell",
                "cmd",
                "java",
                "python",
                "node",
                "git",
                "git-bash",
                "git-cmd"
            );

            boolean isWhitelisted = whitelist.stream().anyMatch(details::contains);

            if(isWhitelisted) {
                System.out.printf("\n(%ss) Processo está na whitelist, não será encerrado: %s\n", SEGUNDOS_REPETIR, processDetails(process));
                return;
            };
            

            //process.children().forEach(Main::killProcess);
            process.destroy();
            System.out.printf("\n\n(%ss)Erro processo DESTRUÍDO: %s\n", SEGUNDOS_REPETIR, processDetails(process));
        } catch (Exception e) {
            System.out.printf("\n(%ss)Erro ao encerrar o processo: %s\n", SEGUNDOS_REPETIR, processDetails(process));
        }
    }


    private static String processDetails(ProcessHandle process) {
        return String.format("%8d %8s %10s %26s %-40s",
                process.pid(),
                text(process.parent().map(ProcessHandle::pid)),
                text(process.info().user()),
                text(process.info().startInstant()),
                text(process.info().commandLine()));

    }

    private static String text(Optional<?> optional) {
    return optional.map(Object::toString).orElse("-");
}
}