# 🧪 Laboratório de Observabilidade com OpenTelemetry

Este laboratório provisiona um ambiente local para instrumentar uma aplicação Java com o **OpenTelemetry Java Agent** e observar traces, logs e métricas com OpenTelemetry Collector, Jaeger, Loki, Prometheus e Grafana.

Ele reúne:

-   **OpenTelemetry Java Agent** --- instrumentação automática da
    aplicação;
-   **OpenTelemetry Collector** --- recebe e roteia os sinais de
    observabilidade;
-   **Jaeger** --- armazenamento e visualização de traces;
-   **Loki** --- armazenamento de logs;
-   **Prometheus** --- coleta e consulta de métricas;
-   **Grafana** --- visualização dos dados de observabilidade;
-   **Docker Compose** --- execução de toda a infraestrutura local.

## 🏗️ Arquitetura

``` text
                    ┌─────────────────────────┐
                    │   app-repository-       │
                    │        payment          │
                    │                         │
                    │ OpenTelemetry Java      │
                    │ Agent                   │
                    └────────────┬────────────┘
                                 │
                                 │ OTLP HTTP
                                 │ localhost:4318
                                 ▼
                    ┌─────────────────────────┐
                    │ OpenTelemetry Collector │
                    │                         │
                    │        :4318            │
                    └────────────┬────────────┘
                                 │
                       ┌─────────┼─────────┐
                       │         │         │
                    traces     logs     metrics
                       │         │         │
                       ▼         ▼         ▼
                ┌──────────┐ ┌────────┐ ┌────────────┐
                │  Jaeger  │ │  Loki  │ │ Prometheus │
                └────┬─────┘ └───┬────┘ └──────┬─────┘
                     └───────────┼─────────────┘
                                 ▼
                         ┌─────────────┐
                         │   Grafana   │
                         │    :3000    │
                         └─────────────┘
```

## 🎯 Objetivo

A aplicação envia os sinais ao OpenTelemetry Collector, que os encaminha aos backends:

``` text
Application
    |
    | OTLP
    v
OpenTelemetry Collector
    |
    +---- traces ---> Jaeger
    |
    +---- logs -----> Loki
    |
    +---- métricas -> Prometheus
```

Essa abordagem permite trocar ou adicionar backends sem precisar alterar
a configuração da aplicação.

------------------------------------------------------------------------

# 1. 🧰 Pré-requisitos

Instale:

-   Docker
-   Docker Compose
-   Java
-   IntelliJ IDEA

Também é necessário ter o arquivo:

``` text
opentelemetry-javaagent.jar
```
Baixe o arquivo [opentelemetry-javaagent.jar](https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.32.0/opentelemetry-javaagent.jar)

------------------------------------------------------------------------

# 2. 📁 Estrutura do laboratório

Uma sugestão de estrutura:

``` text
observability/
├── docker-compose.yml
├── otel-collector-config.yml
├── loki-config.yml
├── prometheus/
│   └── prometheus.yml
└── grafana/
    └── provisioning/
        ├── dashboards/
        └── datasources/
            └── datasources.yml
```

------------------------------------------------------------------------

# 3. 🐳 Docker Compose

Arquivo:

``` text
docker-compose.yml
```

``` yaml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: jaeger
    ports:
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "16686:16686"
      - "14250:14250"
      - "14268:14268"
      - "14269:14269"

  loki:
    image: grafana/loki:latest
    container_name: loki
    command: -config.file=/etc/loki/loki-config.yml
    volumes:
      - ./loki-config.yml:/etc/loki/loki-config.yml
      - loki-data:/loki
    ports:
      - "3100:3100"

  prometheus:
    image: prom/prometheus
    container_name: prometheus
    ports:
      - "9090:9090"
    command:
      - --config.file=/etc/prometheus/prometheus.yml
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro

  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    container_name: otel-collector
    command: ["--config=/etc/otelcol-contrib/config.yml"]
    volumes:
      - ./otel-collector-config.yml:/etc/otelcol-contrib/config.yml
    ports:
      - "4317:4317"
      - "4318:4318"
      - "8889:8889"
    depends_on:
      - jaeger
      - loki
      - prometheus
      - grafana

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    depends_on:
      - loki
      - jaeger
      - prometheus
    volumes:
      - ./grafana/provisioning/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/provisioning/datasources:/etc/grafana/provisioning/datasources
    ports:
      - "3000:3000"

volumes:
  loki-data:
  grafana-data:
```

## 🔌 Portas

| Serviço | Porta | Função |
| --- | ---: | --- |
| Jaeger | 16686 | Interface Web |
| Jaeger | 6831/UDP, 6832/UDP | Recepção de traces via agent |
| Jaeger | 14250, 14268, 14269 | Endpoints de coleta/administrativos |
| Loki | 3100 | API/ingestão |
| Prometheus | 9090 | Interface Web e API |
| Collector | 4317 | OTLP/gRPC |
| Collector | 4318 | OTLP/HTTP |
| Collector | 8889 | Métricas exportadas pelo Collector |
| Grafana | 3000 | Interface Web |

------------------------------------------------------------------------

# 4. 📡 OpenTelemetry Collector

Arquivo:

``` text
otel-collector-config.yml
```

``` yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 10s
    send_batch_size: 1024

exporters:
  debug:
  prometheus:
    endpoint: 0.0.0.0:8889
  otlp/jaeger:
    endpoint: jaeger:4317
    tls:
      insecure: true
  otlphttp/loki:
    endpoint: http://loki:3100/otlp

service:
  pipelines:
    traces:
      receivers:
        - otlp
      processors:
        - batch
      exporters:
        - otlp/jaeger
    metrics:
      receivers:
        - otlp
      processors:
        - batch
      exporters:
        - prometheus
    logs:
      receivers:
        - otlp
      processors:
        - batch
      exporters:
        - otlphttp/loki
```

O Collector recebe OTLP/gRPC na porta `4317` e OTLP/HTTP na porta `4318`. As métricas processadas são expostas pelo exporter Prometheus na porta `8889`.

O Docker Compose publica as portas OTLP sem remapeamento:

``` text
localhost:4317 -> otel-collector:4317
localhost:4318 -> otel-collector:4318
```

Para usar OTLP/HTTP, configure a aplicação com:

``` text
http://localhost:4318
```

------------------------------------------------------------------------

# 5. 🧱 Loki

Arquivo:

``` text
loki-config.yml
```

``` yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki

  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules

  replication_factor: 1

  ring:
    kvstore:
      store: inmemory

schema_config:

  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

limits_config:
  allow_structured_metadata: true
  volume_enabled: true

ruler:
  enable_api: true
```

------------------------------------------------------------------------

# 6. 📊 Grafana

Arquivo:

``` text
grafana/provisioning/datasources/datasources.yml
```

``` yaml
apiVersion: 1

datasources:
  - name: Loki
    uid: loki
    type: loki
    access: proxy
    url: http://loki:3100
    basicAuth: false

  - name: Jaeger
    uid: jaeger
    type: jaeger
    access: proxy
    url: http://jaeger:16686
    basicAuth: false
    isDefault: true

  - name: prometheus
    uid: prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    basicAuth: false
```

Com isso, o Grafana inicia com fontes de dados para Loki, Jaeger e Prometheus.
O Prometheus fica disponível em `http://localhost:9090`; o endpoint de
métricas exportado pelo Collector fica em `http://localhost:8889/metrics`.

**Atenção:** a configuração atual em `prometheus/prometheus.yml` coleta
`localhost:9090` dentro do container Prometheus, ou seja, coleta o próprio
Prometheus. Para coletar as métricas do Collector, o target deve ser
`otel-collector:8889`.

------------------------------------------------------------------------

# 7. 🚀 Subindo a infraestrutura

Na pasta do laboratório:

``` bash
docker compose up -d
```

Verifique:

``` bash
docker compose ps
```

Os cinco containers esperados são:

``` text
jaeger
loki
otel-collector
grafana
prometheus
```

Para acompanhar os logs:

``` bash
docker compose logs -f
```

Ou individualmente:

``` bash
docker compose logs -f otel-collector
```

``` bash
docker compose logs -f jaeger
```

``` bash
docker compose logs -f loki
```

Para parar:

``` bash
docker compose down
```

Para parar e remover também os volumes:

``` bash
docker compose down -v
```

------------------------------------------------------------------------

# 8. 🌐 Acessando as interfaces

## 🧭 Jaeger

``` text
http://localhost:16686
```

## 📈 Grafana

``` text
http://localhost:3000
```

Por padrão, em um ambiente novo do Grafana, o acesso inicial normalmente
é:

``` text
usuário: admin
senha: admin
```

Caso a imagem/versão utilizada solicite alteração da senha no primeiro
acesso, siga o fluxo apresentado pela interface.

------------------------------------------------------------------------

# 9. ⚙️ Configuração do IntelliJ IDEA

No IntelliJ:

``` text
Run
  -> Edit Configurations
  -> Application
```

## 🧠 VM Options

Configure o Java Agent:

``` text
-javaagent:/caminho-do-agent/opentelemetry-javaagent.jar
```

Adapte o caminho conforme a localização do seu arquivo.

## 🌍 Environment Variables

Use:

``` text
OTEL_JAVAAGENT_DEBUG=false;
OTEL_LOGS_EXPORTER=otlp;
OTEL_METRICS_EXPORTER=otlp;
OTEL_SERVICE_NAME=app-repository-payment;
OTEL_TRACES_EXPORTER=otlp;
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318;
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

### 💡 Por que `4318`?

O Docker Compose publica a porta HTTP do Collector diretamente:

``` text
localhost:4318 -> otel-collector:4318
```

`4318` é o endpoint OTLP/HTTP do Collector.

------------------------------------------------------------------------

# 10. 🔄 Fluxo dos sinais

Com a configuração acima:

``` text
Application
    |
    | OTLP HTTP
    | localhost:4318
    v
OpenTelemetry Collector
    |
    +----------------------+----------------------+
    |                      |                      |
    v                      v                      v
Traces                   Logs                  Metrics
    |                      |                      |
    v                      v                      v
Jaeger                    Loki                 Prometheus
```

As métricas são exportadas pelo Collector no endpoint Prometheus `:8889`:

``` text
OTEL_METRICS_EXPORTER=otlp
```

Os logs estão habilitados:

``` text
OTEL_LOGS_EXPORTER=otlp
```

Os traces estão habilitados:

``` text
OTEL_TRACES_EXPORTER=otlp
```

------------------------------------------------------------------------

# 11. 🧪 Testando traces

Execute a aplicação pelo IntelliJ.

Faça uma requisição HTTP para alguma rota da aplicação:

``` bash
curl http://localhost:8080/sua-rota
```

Depois abra:

``` text
http://localhost:16686
```

No Jaeger, procure pelo serviço:

``` text
app-repository-payment
```

Você deverá encontrar os traces gerados pela aplicação.

------------------------------------------------------------------------

# 12. 📝 Testando logs

No Grafana:

``` text
http://localhost:3000
```

Entre em:

``` text
Explore
```

Selecione:

``` text
Loki
```

Uma consulta inicial:

``` logql
{service_name="app-repository-payment"}
```

Se o atributo de serviço estiver disponível como label no formato
esperado pela versão/configuração do Loki, essa consulta deverá
encontrar os logs da aplicação.

Caso contrário, utilize o explorador de labels do Loki para descobrir
quais atributos foram indexados e ajuste a consulta.

------------------------------------------------------------------------

# 13. 🔗 Correlação entre logs e traces

Um dos objetivos principais deste laboratório é conseguir relacionar:

``` text
trace_id
span_id
```

com os logs produzidos durante uma requisição.

Exemplo conceitual:

``` text
HTTP Request
      |
      v
Trace ID: abc123
      |
      +---- Span: HTTP
      |
      +---- Span: Service
      |
      +---- Span: Database
      |
      +---- Logs associados
             |
             +-- trace_id = abc123
             +-- span_id  = xyz789
```

Em aplicações Java com Logback, o OpenTelemetry pode adicionar
informações de trace ao contexto de logging, como `trace_id` e
`span_id`.

Isso permite localizar os logs relacionados a uma requisição específica.

------------------------------------------------------------------------

# 14. 🪵 Teste com Logback

Uma aplicação Spring Boot normalmente utiliza Logback.

Por exemplo:

``` java
@Slf4j
@RestController
public class PaymentController {

    @GetMapping("/payments/{id}")
    public String getPayment(@PathVariable String id) {

        log.info("Buscando pagamento: {}", id);

        return "payment-" + id;
    }
}
```

Ao executar essa chamada:

``` bash
curl http://localhost:8080/payments/123
```

esperamos que exista:

``` text
Trace
  trace_id = ...
  span_id  = ...
```

e um log relacionado:

``` text
Buscando pagamento: 123
```

com contexto de trace.

------------------------------------------------------------------------

# 15. 🛠️ Troubleshooting

## ⚠️ Erro: `unexpected end of stream`

Se aparecer algo como:

``` text
unexpected end of stream
```

verifique se o protocolo e a porta estão combinando.

### 🔌 OTLP/gRPC

``` text
4317
grpc
```

### 🌐 OTLP/HTTP

``` text
4318
http/protobuf
```

No laboratório atual, a aplicação utiliza:

``` text
4318
http/protobuf
```

porque:

``` text
localhost:4318 -> otel-collector:4318
```

------------------------------------------------------------------------

## ⚠️ Métricas não aparecem no Prometheus

O Collector expõe as métricas recebidas em `:8889/metrics`. Confira se a
aplicação envia métricas:

``` text
OTEL_METRICS_EXPORTER=otlp
```

Em `prometheus/prometheus.yml`, configure o target `otel-collector:8889`
para que Prometheus colete o endpoint do Collector. A configuração padrão
atual está apontada para `localhost:9090` e, portanto, coleta somente o
próprio Prometheus.

------------------------------------------------------------------------

## ⚠️ Erro: `404 page not found` em `4318`

Verifique se você está enviando OTLP HTTP para o componente correto.

No laboratório:

``` text
Application
    |
    v
localhost:4318
    |
    v
Collector:4318
```

Use `http/protobuf` com a porta `4318` para OTLP/HTTP ou `grpc` com a
porta `4317` para OTLP/gRPC.

------------------------------------------------------------------------

## 📡 Collector não recebe dados

Veja:

``` bash
docker compose logs -f otel-collector
```

Confirme também:

``` bash
docker compose ps
```

e teste se as portas estão publicadas:

``` bash
docker ps
```

Você deve encontrar algo equivalente a:

``` text
0.0.0.0:4318->4318/tcp
0.0.0.0:4317->4317/tcp
0.0.0.0:8889->8889/tcp
```

------------------------------------------------------------------------

## 🧱 Loki não recebe logs

Veja:

``` bash
docker compose logs -f loki
```

Depois:

``` bash
docker compose logs -f otel-collector
```

Confirme que o pipeline de logs existe:

``` yaml
service:
  pipelines:
    logs:
      receivers:
        - otlp
      processors:
        - batch
      exporters:
        - otlphttp/loki
```

------------------------------------------------------------------------

# 16. 🧰 Comandos úteis

Subir:

``` bash
docker compose up -d
```

Ver status:

``` bash
docker compose ps
```

Ver todos os logs:

``` bash
docker compose logs -f
```

Ver Collector:

``` bash
docker compose logs -f otel-collector
```

Ver Jaeger:

``` bash
docker compose logs -f jaeger
```

Ver Loki:

``` bash
docker compose logs -f loki
```

Ver Grafana:

``` bash
docker compose logs -f grafana
```

Ver Prometheus:

``` bash
docker compose logs -f prometheus
```

Parar:

``` bash
docker compose down
```

Resetar volumes:

``` bash
docker compose down -v
```

------------------------------------------------------------------------

# 17. 📋 Resumo da configuração

## ☕ Java Agent

``` text
-javaagent:/caminho-do-agent/opentelemetry-javaagent.jar
```

## 🌍 Environment Variables

``` text
OTEL_JAVAAGENT_DEBUG=false
OTEL_LOGS_EXPORTER=otlp
OTEL_METRICS_EXPORTER=otlp
OTEL_SERVICE_NAME=app-repository-payment
OTEL_TRACES_EXPORTER=otlp
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

## 🌐 Endpoints

``` text
Application
    |
    +-- OTLP HTTP --> localhost:4318
                            |
                            v
                     OTel Collector
                      :4318 HTTP
                      :4317 gRPC
                       /     |     \
                      v      v      v
                  Jaeger   Loki  Prometheus
                 :16686   :3100   :9090
                      \     |     /
                       v    v    v
                        Grafana
                         :3000
```

------------------------------------------------------------------------

# 18. ➡️ Próximos passos

Depois que o laboratório básico estiver funcionando, os próximos
experimentos recomendados são:

1.  Adicionar instrumentação de banco de dados.
2.  Adicionar chamadas HTTP entre dois microsserviços.
3.  Propagar `traceparent` entre os serviços.
4.  Visualizar um trace completo no Jaeger.
5.  Correlacionar `trace_id` e `span_id` com logs no Loki.
6.  Adicionar métricas através do OpenTelemetry Collector.
7.  Criar dashboards no Grafana.
8.  Adicionar alertas.
9.  Testar sampling de traces.
10. Experimentar diferentes processors do OpenTelemetry Collector.

O objetivo final é conseguir investigar uma requisição de ponta a ponta:

``` text
HTTP Request
     |
     v
Service A
     |
     +------> Service B
     |            |
     |            +------> Database
     |
     +------> Logs
                  |
                  v
                 Loki

Todos relacionados pelo mesmo Trace ID.
```