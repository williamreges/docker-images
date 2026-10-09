# 🚀 Como Rodar o Jaeger com o IntelliJ IDEA

**Sim, é totalmente possível**, mas com uma distinção importante: você não roda o servidor do **Jaeger** *dentro* do IntelliJ como se fosse um plugin nativo. Em vez disso, você **roda o painel do Jaeger via Docker** e configura a sua aplicação Java/Kotlin dentro do IntelliJ para enviar os dados de rastreamento (traces) para ele.

Aqui está a forma mais rápida e padrão de fazer isso funcionar no seu dia a dia:

---

## 🐳 1. Subir o Jaeger com Docker Compose

A forma recomendada pela própria [documentação da JetBrains](https://www.jetbrains.com/help/idea/open-telemetry-tracing-and-metrics.html) e do Jaeger é usar a imagem `all-in-one`. Você pode abrir o terminal integrado do IntelliJ e executar a composição disponível neste projeto:

O arquivo `docker-compose.yml` configura o serviço `jaeger` com a imagem `jaegertracing/all-in-one:1.38`. Abra o terminal no diretório do projeto e execute:

```bash
docker compose up -d
```

O Compose inicia o serviço com as portas e variáveis abaixo:

* **`6831` e `6832`**: portas UDP para os agentes Jaeger.
* **`5778`**: porta para o endpoint de métricas.
* **`16686`**: Porta onde você vai acessar a interface visual (UI).
* **`4317`** (gRPC) e **`4318`** (HTTP): Portas que servem para receber os dados do OpenTelemetry.
* **`14250`, `14268` e `14269`**: portas de coleta do Jaeger.
* **`9411`**: Porta do endpoint HTTP do Zipkin e do collector Zipkin.

A variável `COLLECTOR_ZIPKIN_HTTP_PORT=9411` e `COLLECTOR_OTLP_ENABLED=true` também são configuradas no serviço.

Para verificar o estado do container, execute:

```bash
docker compose ps
docker compose logs -f jaeger
```

Para parar e remover o Jaeger:

```bash
docker compose down
```

### Executar sem Docker Compose

Você também pode iniciar o Jaeger diretamente com o Docker, sem usar a composição:

```bash
docker run -d --name jaeger \
  -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
  -e COLLECTOR_OTLP_ENABLED=true \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 14250:14250 \
  -p 14268:14268 \
  -p 14269:14269 \
  -p 9411:9411 \
  jaegertracing/all-in-one:1.38
```

> Se o container já existir, execute `docker rm -f jaeger` antes de rodar o comando direto novamente.

---

## ⚙️ 2. Configurar seu Projeto no IntelliJ

Para que o seu código envie os *spans* e *traces* para o Jaeger, você precisa instrumentar a sua aplicação. O padrão de mercado hoje é usar o **OpenTelemetry**.

Se você estiver usando a abordagem sem mexer no código (via agente Java):

1. Baixe o arquivo [opentelemetry-javaagent.jar](https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.32.0/opentelemetry-javaagent.jar).
2. No menu superior do IntelliJ, vá em **Run** > **Edit Configurations...**.
3. Na sua aplicação, adicione em **VM Options**:
   ```text
   -javaagent:/caminho/para/opentelemetry-javaagent.jar
   ```
4. Adicione as **Environment Variables** (Variáveis de Ambiente) da opção de exportação que deseja utilizar.

### Exportação via gRPC

Para enviar os spans usando gRPC, configure:

```text
OTEL_SERVICE_NAME=nome-da-sua-app
OTEL_EXPORTER_OTLP_TRACES_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://localhost:4317
```

### Exportação via HTTP/protobuf

Para enviar os spans usando HTTP com o formato protobuf, configure as variáveis a seguir no IntelliJ, no campo de **Environment Variables**:

```text
OTEL_JAVAAGENT_DEBUG=false
OTEL_LOGS_EXPORTER=none
OTEL_METRICS_EXPORTER=none
OTEL_SERVICE_NAME=app-repository-payment
OTEL_TRACES_EXPORTER=otlp
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
```

Estas variáveis desabilitam o debug do agente, impedem a exportação de logs e métricas e enviam somente os traces pelo endpoint OTLP da porta `4318`. O endpoint corresponde à porta HTTP/protobuf exposta pelo Jaeger.

Os endpoints acima correspondem às portas expostas pelo Jaeger. Escolha apenas uma das duas opções e não configure os dois protocolos simultaneamente.

## 🧪 Exemplo de Configuração de variávies no Run do IntelliJ
![alt text](image.png)

---

## 🔎 3. Visualizar os Traces

1. Dê o **"Play"** na sua aplicação pelo IntelliJ.
2. Faça algumas requisições nela (ex: mande um GET, salve um dado, etc.).
3. Abra o seu navegador e acesse a interface local do Jaeger: **http://localhost:16686**.
4. Sua aplicação aparecerá listada na barra lateral esquerda pronta para análise.

### 📸 Exemplo:

![alt text](/docs/image-1.png)

Entrando no trace terá algo parecido abaixo:

![alt text](/docs/image-2.png)

---

## 📚 Referências

- [Documentação oficial do Jaeger](https://www.jaegertracing.io/docs/)
- [Documentação do Jaeger 1.38](https://www.jaegertracing.io/docs/1.38/)
- [OpenTelemetry Java instrumentation](https://opentelemetry.io/docs/languages/java/)
- [Configuração do agente Java OpenTelemetry](https://opentelemetry.io/docs/languages/java/configuration/)
- [OpenTelemetry OTLP exporter](https://opentelemetry.io/docs/specs/otlp/)
- [Documentação da JetBrains sobre OpenTelemetry](https://www.jetbrains.com/help/idea/open-telemetry-tracing-and-metrics.html)

