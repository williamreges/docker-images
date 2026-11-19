# 📊 Grafana + Prometheus para desenvolvimento

Este projeto inicia um ambiente local de observabilidade com Grafana e
Prometheus. Há dois manifests porque a comunicação entre containers e o acesso
a serviços executados no host variam entre Linux e Docker Desktop no Windows.

Escolha **apenas um** dos diretórios abaixo de acordo com o ambiente:

- [`linux-environment/`](./linux-environment/): Linux com Docker Engine.
- [`windows-environment/`](./windows-environment/): Windows com Docker Desktop
  usando containers Linux.

## 📦 O que é provisionado

As duas variantes iniciam:

- **Prometheus**, na porta `9090`, com configuração montada de
  `prometheus/prometheus.yml`.
- **Grafana**, na porta `3000`, com datasource Prometheus e dashboards
  provisionados a partir de `grafana/provisioning/`.
- O dashboard **Spring Boot & Endpoint Metrics 2.0** e o dashboard
  **Spring HTTP Example**.
- Um job Prometheus chamado `prometheus`, que coleta as métricas do próprio
  Prometheus a cada 5 segundos.
- Um job chamado `service-app`, configurado para coletar métricas de uma
  aplicação local a cada 5 segundos. Por padrão, usa a porta `8000` e o
  caminho `/metrics`.

## 🎯 Apontar para uma aplicação local

O job `service-app` é um exemplo para você adaptar à aplicação que estiver
executando na sua máquina. Edite o arquivo `prometheus/prometheus.yml` do
ambiente escolhido e ajuste:

- `metrics_path`: caminho HTTP onde a aplicação expõe as métricas.
- `targets`: endereço e porta da aplicação. Não inclua `http://` nem o caminho
  nesse valor.

Por exemplo, para coletar em uma aplicação na porta `8081` pelo caminho
`/actuator/prometheus`, altere esses campos. O endereço depende do ambiente:

```yaml
    metrics_path: /actuator/prometheus
    static_configs:
      - targets:
          - localhost:8081 # Linux
```

No Windows com Docker Desktop, use `host.docker.internal` no lugar de
`localhost`:

```yaml
    metrics_path: /actuator/prometheus
    static_configs:
      - targets:
          - host.docker.internal:8081
```

A aplicação precisa estar em execução, acessível pelo host e expor métricas
em formato compatível com Prometheus no caminho configurado. Depois de salvar
o arquivo, reinicie o Prometheus no diretório do ambiente selecionado para
aplicar a alteração:

```bash
docker compose restart prometheus
```

Confira o estado do alvo na página **Status → Targets** do Prometheus em
<http://localhost:9090/targets>.

## 🖥️ Diferenças entre os ambientes

### 🐧 Linux

Os dois serviços usam `network_mode: host`. Assim, o Prometheus acessa a
aplicação local em `localhost:8000`, e o Grafana acessa o Prometheus em
`localhost:9090`. Nesse modo, o Docker não usa os mapeamentos `ports`; por
isso, as portas ficam disponíveis diretamente no host.

Use esta opção em um host Linux com Docker Engine. O modo de rede host depende
do suporte do runtime e não é a opção adequada para Docker Desktop no Windows.

### 🪟 Windows com Docker Desktop

Os serviços usam a rede padrão criada pelo Docker Compose. O Grafana acessa o
Prometheus pelo DNS interno do Compose, em `http://prometheus:9090`. As portas
`3000` e `9090` são publicadas no host.

O Prometheus acessa uma aplicação executada diretamente no Windows por
`host.docker.internal:8000`, nome fornecido pelo Docker Desktop para alcançar
o host.

## 🚀 Como iniciar

Execute os comandos na raiz deste projeto. Inicie somente a variante
correspondente ao seu sistema.

### 🐧 Linux

```bash
cd linux-environment
docker compose up -d
docker compose ps
```

### 🪟 Windows (PowerShell)

```powershell
Set-Location .\windows-environment
docker compose up -d
docker compose ps
```

Abra:

- Grafana: <http://localhost:3000>
- Prometheus: <http://localhost:9090>

O usuário e a senha iniciais configurados no Grafana são `admin` e `admin`.
Porém, os arquivos `grafana/grafana.ini` também habilitam acesso anônimo com
papel `Admin`; portanto, atualmente não é necessário fazer login e qualquer
pessoa que alcance o serviço tem permissões administrativas. Use somente em
um ambiente de desenvolvimento confiável. Alterar a senha não desativa o
acesso anônimo: antes de expor o serviço a outras redes, desabilite
`[auth.anonymous]` (`enabled = false`) e defina credenciais seguras.

Para ver os logs, execute `docker compose logs -f` no diretório de ambiente.
Para parar e remover os containers, execute `docker compose down` no mesmo
diretório.

## 💾 Persistência e ajustes

Os arquivos de configuração e dashboards são montados a partir do diretório
do ambiente selecionado. Alterações nesses arquivos ficam no host. Não há
volume de dados para o banco interno do Grafana ou para os dados TSDB do
Prometheus; portanto, esses dados podem ser perdidos ao remover/recriar os
containers.

Ambos os manifests usam os nomes fixos `grafana` e `prometheus` e as portas
`3000` e `9090`. Não inicie as duas variantes simultaneamente no mesmo host,
pois elas entram em conflito nesses recursos.
