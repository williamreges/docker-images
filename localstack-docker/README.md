# LocalStack


---

LocalStack é um emulador de serviço em nuvem executado em um único contêiner em seu laptop ou 
ambiente de CI. Com LocalStack, você pode executar seus aplicativos AWS ou Lambdas inteiramente em 
sua máquina local sem se conectar a um provedor de nuvem remoto.

Contudo esse Reame é apenas um resumo de alguns recursos que esse poderoso simulador pode 
nos auxiliar como desenvolvedores de serviços de Núvem AWS.

### Documentação Oficial do LocalStack

- Overview: https://docs.localstack.cloud/overview  
- Getting Started: https://docs.localstack.cloud/getting-started/
- User Guides: https://docs.localstack.cloud/user-guide
- LocalStack Desktop: https://app.localstack.cloud

---
### Requisitos

Nos exemplos desse readme estaremos utilizaodo docker para utilizar uma imagem do localstack para simular
os recursos da AWS localmente. Também utilizaremos o AWS CLI para iteragir com o simulador através do 
parâmetro  `--endpoint-url=http://localhost:4566` que apontará os comandos do CLI para a porta container.

1. Instale a [imagen do LocalStack](docker-compose.yml) pelo 
`manifesto`:

```yaml
version: "3.8"

services:
  localstack:
    container_name: "${LOCALSTACK_DOCKER_NAME:-localstack-main}"
    image: localstack/localstack
    ports:
      - "127.0.0.1:4566:4566"            # LocalStack Gateway
      - "127.0.0.1:4510-4559:4510-4559"  # external services port range
    environment:
     - SERVICES=${SERVICES- }
     - DEBUG=${DEBUG- }
     - DATA_DIR=${DATA_DIR- }
     - PORT_WEB_UI=${PORT_WEB_UI- }
     - LAMBDA_EXECUTOR=${LAMBDA_EXECUTOR- }
     - KINESIS_ERROR_PROBABILITY=${KINESIS_ERROR_PROBABILITY- }
     - DOCKER_HOST=unix:///var/run/docker.sock
     - HOST_TMP_FOLDER=${TMPDIR}
    volumes:
      - "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
```
Rode o comando docker compose em cims desse manifesto:
```shell
docker-compose up -d
```

ou instale pelo `docker run` direto
```shell
docker run \
  --rm -it \
  -p 4566:4566 \
  -p 4510-4559:4510-4559 \
  localstack/localstack
```

2. Se não tiver instalado o AWS CLI pode instala-lo pelo snap da distribuição Linux:

```shell
sudo snap install aws-cli --classic
```
3. Configure AWS CLI para utilizar no LocalStack

```shell
aws configure
```
e informe os seguintes parametros pedidos na configuração. Pode ser nomes genérico mesmo. Como exemplo utilizei
um nome `fake` e informei a região de São Paulo com `sa-east-1`:
```shell
AWS Access Key ID [None]: fake
AWS Secret Access Key [None]: fake
Default region name [None]: sa-east-1
Default output format [None]: json
```

---

### Serviços Locais da AWS 

#### [Comece com S3 no LocalStack ](https://docs.localstack.cloud/user-guide/aws/s3)

Simple Storage Service (S3) é um serviço de armazenamento de objetos que fornece uma solução altamente escalonável e durável para armazenamento e recuperação de dados.


1. Criando  Buckets com `mb`:

```shell
aws s3 mb s3://sample-bucket \
--endpoint-url=http://localhost:4566 

aws s3 mb s3://sample-bucket2 \
--endpoint-url=http://localhost:4566 
```

2. Listar os Buckets com `ls`
```shell
aws s3 ls \
--endpoint-url=http://localhost:4566 
```

3. Copiando Objeto local `testeS3.txt` para o Bucket com `cp`
```shell
#Criando Arquivos
mkdir upload-s3 && \ 
touch upload-s3/teste1.txt upload-s3/teste2.txt upload-s3/teste3.txt upload-s3/testeS3.txt upload-s3/image1.jpg upload-s3/image2.jpg

# Copiando arquivos para o Buket
aws s3 cp upload-s3/testeS3.txt s3://sample-bucket \
--endpoint-url=http://localhost:4566
```

4. Copiando Objetos locais da pasta `upload-s3` para o Bucket com `cp` em lote com `--recursive`
e ignorando outros arquivos com `--exclude`
```shell
aws s3 cp upload-s3 s3://sample-bucket \
--recursive \
--exclude "*.jpg" \
--endpoint-url=http://localhost:4566
```
5. Listando os Objetos do Bucket com `ls`:
```shell
aws s3 ls s3://sample-bucket --endpoint-url=http://localhost:4566
```

6. Copia Objetos de um Bucket para outro com `cp`:
```shell
aws s3 cp s3://sample-bucket s3://sample-bucket2 \
--recursive \
--endpoint-url=http://localhost:4566
```

7. Dowload de objetos do Bucket com `cp` para o desktop:
```shell
aws s3 cp s3://sample-bucket ./dowload-s3 \
--recursive \
--endpoint-url=http://localhost:4566
```

8. Deletando Objeto no Bucket com `rm`:
```shell
aws s3 rm s3://sample-bucket/testeS3.txt \
--endpoint-url=http://localhost:4566
```

9. Deletando todos Objetos no Bucket com `rm` e `--recursive`:
```shell
aws s3 rm s3://sample-bucket \
--recursive \
--endpoint-url=http://localhost:4566
```

10. Deletando um Bucket com `rb` e `--force` para remover prmeiramente todos os arquivos
para depois remover o bucket de fato:
```shell
aws s3 rb s3://sample-bucket \
--force \
--endpoint-url=http://localhost:4566
```
```shell
aws s3 rb s3://sample-bucket2 \
--force \
--endpoint-url=http://localhost:4566
```

> #### Ajuda:
> Veja o recurso de forma visual em:
> - [LocalStack Desktop S3](https://app.localstack.cloud/inst/default/resources/s3)
> 
> Veja mais assunto avançado em:
> - [Doc AWS S3](https://docs.aws.amazon.com/s3/?icmpid=docs_homepage_featuredsvcs)
> - [AWS CLI Command Reference S3](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/index.html#)


---

#### [Comece com Lambda no LocalStack ](https://docs.localstack.cloud/user-guide/aws/lambda)

AWS Lambda é uma plataforma de função como serviço (FaaS) sem servidor que permite executar código em sua linguagem de programação preferida no ecossistema AWS. O AWS Lambda dimensiona automaticamente seu código para atender à demanda e cuida do provisionamento, gerenciamento e manutenção do servidor. O AWS Lambda permite dividir seu aplicativo em funções menores e independentes que se integram perfeitamente aos serviços da AWS.

1. Para criar uma nova função Lambda, crie um novo arquivo chamado `index.js` com o seguinte código a ser 
executado dentro do Lambda:


```shell
cat << EOF > index.js

exports.handler = async (event) => {
    let body = JSON.parse(event.body)
    const product = body.num1 * body.num2;
    const response = {
        statusCode: 200,
        body: "The product of " + body.num1 + " and " + body.num2 + " is " + product,
    };
    return response;
};

EOF

```

2. Insira o seguinte comando para criar um `funcion.zip` do arquivo `index.js` e utilize
 como parametro no momento que se criar uma nova função Lambda com `create-function`:

```shell
# Zip index.js para function.zip
zip function.zip index.js

# Cria lambda configurando a function.zip
aws lambda create-function \
    --function-name localstack-lambda-url-example \
    --runtime nodejs18.x \
    --zip-file fileb://function.zip \
    --handler index.handler \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --endpoint-url=http://localhost:4566 
```
3. Listar as funções Lambda `list-functions`:
```shell
aws lambda list-functions \
 --endpoint-url=http://localhost:4566 
```

4. Invocar a função Lambda com `invoke`:

```shell
aws lambda invoke --function-name localstack-lambda-url-example \
    --endpoint-url=http://localhost:4566 \
    --cli-binary-format raw-in-base64-out \
    --payload '{"body": "{\"num1\": \"10\", \"num2\": \"10\"}" }' ./download/output.txt 
```

5. Deletando Função Lambda `delete-function`:
```shell
aws lambda delete-function \
--function-name localstack-lambda-url-example \
--endpoint-url=http://localhost:4566 
```

> #### Ajuda:
> Veja o recurso de forma visual em:
> - [LocalStack Desktop Lambda](https://app.localstack.cloud/inst/default/resources/lambda/functions)
>
> Veja mais assunto avançado em:
> - [Doc AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html)
> - [AWS CLI Command Reference Lambda](https://docs.aws.amazon.com/cli/latest/reference/lambda/)

---
 
#### [Comece a usar o DynamoDB no LocalStack ](https://docs.localstack.cloud/user-guide/aws/dynamodb)

DynamoDB é um serviço de banco de dados NoSQL totalmente gerenciado fornecido pela AWS. Ele oferece uma maneira flexível e altamente escalável de armazenar e recuperar dados, tornando-o adequado para uma ampla gama de aplicações. O DynamoDB fornece um armazenamento de dados de chave-valor rápido e escalonável com suporte para replicação, escalonamento automático, criptografia de dados em repouso e backup sob demanda, entre outros recursos.

1. Você pode criar uma tabela do DynamoDB usando o `create-table`. 

```shell
aws dynamodb create-table \
    --table-name global01 \
    --key-schema AttributeName=id,KeyType=HASH \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566 
```


2. Listar Tabelas com `list-tables`:

```shell
aws  dynamodb list-tables \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566
```
3. Inserir registro com `put-item`:

```shell
aws  dynamodb put-item \
    --table-name global01 \
    --item '{"id":{"S":"foo"}}' \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566
```

4. Consulte quantidade de itens na tabela com `descrite-table`:
```shell
aws dynamodb describe-table \
    --table-name global01 \
    --query 'Table.ItemCount' \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566
``` 


> #### Ajuda:
> Veja o recurso de forma visual em:
> - [LocalStack Desktop DynamoDb](https://app.localstack.cloud/inst/default/resources/dynamodb)
>
> Veja mais assunto avançado em:
> - [Doc AWS DynamoDB](https://docs.aws.amazon.com/dynamodb/)
> - [Getting started with DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStartedDynamoDB.html)
> - [AWS CLI Command Referenc e DynamoDb](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/dynamodb/index.html)

---

#### [Comece com o Simple Queue Service (SQS) no LocalStack](https://docs.localstack.cloud/user-guide/aws/sqs/)

Simple Queue Service (SQS) é um serviço de mensagens gerenciado oferecido pela AWS. Ele permite dissociar diferentes componentes de seus aplicativos, permitindo a comunicação assíncrona por meio de filas de mensagens. O SQS permite enviar, armazenar e receber mensagens de maneira confiável, com suporte para filas padrão e FIFO.

1. Para criar uma fila SQS, use o `create-queue`: 
```shell
aws sqs create-queue \
--queue-name localstack-queue \
--endpoint-url=http://localhost:4566  
```

2. Listar SQS com `list-queues`:

```shell
aws sqs list-queues \
--endpoint-url=http://localhost:4566 
```

> #### Ajuda:
> Veja o recurso de forma visual em:
> - [LocalStack Desktop SQS](https://app.localstack.cloud/inst/default/resources/sqs)
>
> Veja mais assunto avançado em:
> - [Doc AWS SQS](https://docs.aws.amazon.com/sqs/?icmpid=docs_homepage_appintegration)
> - [AWS CLI Command Reference SQS](https://docs.aws.amazon.com/cli/latest/reference/sqs/).

---

#### [Comece com o Simple Notification Service (SNS) no LocalStack ](https://docs.localstack.cloud/user-guide/aws/sns/)

Simple Notification Service (SNS) é um serviço de mensagens sem servidor que pode distribuir um grande número de mensagens para vários assinantes e pode ser usado para enviar mensagens para dispositivos móveis, endereços de e-mail e pontos de extremidade HTTP(s).

1. Para criar um tópico SNS, use o `create-topic`:

```shell
aws sns create-topic --name localstack-topic --endpoint-url=http://localhost:4566 
```

2. Você pode definir o atributo do tópico SNS usando o tópico SNS criado anteriormente usando o comando `set-topic-attributes`.
```shell
aws sns set-topic-attributes \
   --topic-arn arn:aws:sns:sa-east-1:000000000000:localstack-topic \
   --attribute-name DisplayName \
   --attribute-value MyTopicDisplayName \
   --endpoint-url=http://localhost:4566
```

3. Você pode listar todos os tópicos do SNS usando o `list-topics
```shell
aws sns list-topics --endpoint-url=http://localhost:4566 
```

4. Você pode obter atributos para um único tópico SNS usando o `get-topic-attributes`
```shell
aws sns get-topic-attributes \
   --topic-arn arn:aws:sns:sa-east-1:000000000000:localstack-topic \
   --endpoint-url=http://localhost:4566 
```

5. Para publicar mensagens no tópico SNS, crie um novo arquivo chamado messages.txt em seu diretório atual e adicione algum 
conteúdo. Execute o seguinte comando para publicar mensagens no tópico SNS usando o `publish`:
```shell
aws sns publish \
   --topic-arn "arn:aws:sns:sa-east-1:000000000000:localstack-topic" \
   --message file://message.txt \
   --endpoint-url=http://localhost:4566 
```

6. Você pode se inscrever no tópico SNS usando o `subscribe`:
```shell
aws sns subscribe \
   --topic-arn arn:aws:sns:sa-east-1:000000000000:localstack-topic \
   --protocol email \
   --notification-endpoint william.reges1986@gmail.com \
   --endpoint-url=http://localhost:4566 
```

> #### Obs:
> Para mais orientações sobre uso prático do AWS CLI na ferramenta SNS acesse o link
> direto na doc da AWS 

> #### Ajuda:
> Veja o recurso de forma visual em:
> - [LocalStack Desktop SNS](https://app.localstack.cloud/inst/default/resources/sns)
>
> Veja mais assunto avançado em:
> - [Doc AWS SNS](https://docs.aws.amazon.com/sns/?icmpid=docs_homepage_appintegration)
> - [AWS CLI Command Reference SNS](https://docs.aws.amazon.com/cli/latest/reference/sns/).

---

#### [Comece com Simple System Manager(SSM) no LocalStack ](https://docs.localstack.cloud/user-guide/aws/ssm/)

O Systems Manager (SSM) é um serviço de gerenciamento fornecido pela Amazon Web Services que ajuda você a gerenciar e controlar com eficácia os recursos de sua infraestrutura. O SSM simplifica tarefas relacionadas ao gerenciamento de sistemas e aplicativos, aplicação de patches, configuração e automação, permitindo manter a integridade e a conformidade do seu ambiente.

1. Para criar um parametro no SSM utilizando AWS Parameter Store, use o `ssm put-parameter`
```shell
aws ssm put-parameter \
     --name "docslocalstack" \
     --type "String" \
     --value "https://docs.localstack.cloud/overview/" \
     --overwrite \
     --endpoint-url=http://localhost:4566
```
2. Você pode obter o parametro salvo com `ssm get-parameter`

```shell
aws ssm get-parameter \
   --name "docslocalstack" \
   --endpoint-url=http://localhost:4566
```
3. Você pode deleter um parametro com `ssm delete-parameter`

```shell
aws ssm delete-parameter \
   --name "docslocalstack" \
   --endpoint-url=http://localhost:4566
```

> #### Ajuda:
>  Veja o recurso de forma visual em:
> - [LocalStack Desktop SSM](https://app.localstack.cloud/inst/default/resources/ssm)
>
> Veja mais assunto avançado em:
> - [Doc AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/)
> - [Doc AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
> - [AWS CLI Command Referenc SSM](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ssm/index.html)

---

### Referencias

- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
