# Como Rodar o Jaeger com o IntelliJ IDEA

**Sim, é totalmente possível**, mas com uma distinção importante: você não roda o servidor do **Jaeger** *dentro* do IntelliJ como se fosse um plugin nativo. Em vez disso, você **roda o painel do Jaeger via Docker** e configura a sua aplicação Java/Kotlin dentro do IntelliJ para enviar os dados de rastreamento (traces) para ele.

Aqui está a forma mais rápida e padrão de fazer isso funcionar no seu dia a dia:

---

## 1. Subir o Jaeger com Docker Compose

A forma recomendada pela própria [documentação da JetBrains](https://www.jetbrains.com/help/idea/open-telemetry-tracing-and-metrics.html) e do Jaeger é usar a imagem `all-in-one`. Você pode abrir o terminal integrado do IntelliJ e executar a composição disponível neste projeto:

O arquivo `docker-compose.yml` configura o serviço `jaeger` com a imagem `jaegertracing/all-in-one:latest`. Abra o terminal no diretório do projeto e execute:

```bash
docker compose up -d
```

O Compose inicia o serviço com as mesmas portas do comando direto:

* **`16686`**: porta onde você vai acessar a interface visual (UI).
* **`4317`** (gRPC) e **`4318`** (HTTP): Portas que servem para receber os dados do OpenTelemetry.

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
  -e COLLECTOR_OTLP_ENABLED=true \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  jaegertracing/all-in-one:latest
```

> Se o container já existir, execute `docker rm -f jaeger` antes de rodar o comando direto novamente.

---

## 2. Configurar seu Projeto no IntelliJ

Para que o seu código envie os *spans* e *traces* para o Jaeger, você precisa instrumentar a sua aplicação. O padrão de mercado hoje é usar o **OpenTelemetry**.

Se você estiver usando a abordagem sem mexer no código (via agente Java):

1. Baixe o arquivo [opentelemetry-javaagent.jar](https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.32.0/opentelemetry-javaagent.jar).
2. No menu superior do IntelliJ, vá em **Run** > **Edit Configurations...**.
3. Na sua aplicação, adicione em **VM Options**:
   ```text
   -javaagent:/caminho/para/opentelemetry-javaagent.jar
   ```
4. Adicione as seguintes **Environment Variables** (Variáveis de Ambiente):
   ```text
   OTEL_SERVICE_NAME=nome-da-sua-app
   OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
   ```

---

## 3. Visualizar os Traces

1. Dê o **"Play"** na sua aplicação pelo IntelliJ.
2. Faça algumas requisições nela (ex: mande um GET, salve um dado, etc.).
3. Abra o seu navegador e acesse a interface local do Jaeger: **http://localhost:16686**.
4. Sua aplicação aparecerá listada na barra lateral esquerda pronta para análise.

---

> **Nota:** Se você quiser monitorar o próprio desempenho e os dados internos do IntelliJ, a IDE possui suporte nativo experimental para exportar suas próprias métricas de diagnóstico via OpenTelemetry para o Jaeger.
