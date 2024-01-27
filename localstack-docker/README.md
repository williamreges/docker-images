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

---
### Requisitos

Nos exemplos desse readme estaremos utilizaodo docker para utilizar uma imagem do localstack para simular
os recursos da AWS localmente. Também utilizaremos o AWS CLI para iteragir com o simulador através do 
parâmetro  `--endpoint-url=http://localhost:4566` que apontará os comandos do CLI para a porta container.

1. Instale a [imagen do LocalStack](https://docs.localstack.cloud/getting-started/installation/#docker-compose) pelo 
`docker compose`:
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

> #### Obs: 
> Paramais informações sobre como utilizar os comandos S3 do AWS Cli veja em 
> https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/index.html#
---

#### [Comece com Lambda no LocalStack ](https://docs.localstack.cloud/user-guide/aws/lambda)

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

> #### Obs:
> Para mais orientações sobre uso prático do AWS CLI na ferramenta Lambda acesse o link
> direto na doc da AWS ou [AWS CLI Command Reference Lambda](https://docs.aws.amazon.com/cli/latest/reference/lambda/)
> ou a doc [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html)
---

#### [Comece a usar o DynamoDB no LocalStack ](https://docs.localstack.cloud/user-guide/aws/dynamodb)

Você pode criar uma tabela do DynamoDB usando o `create-table`. 

```shell
aws dynamodb create-table \
    --table-name global01 \
    --key-schema AttributeName=id,KeyType=HASH \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --billing-mode PAY_PER_REQUEST \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566 
```
---

Listar Tabelas com `ListTables`

```shell
aws  dynamodb list-tables \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566
```
Inserir registro com `PutItem`

```shell
aws  dynamodb put-item \
    --table-name global01 \
    --item '{"id":{"S":"foo"}}' \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566
```

Consulte quantidade de itens na tabela com `DescriteTable`
```shell
aws dynamodb describe-table \
    --table-name global01 \
    --query 'Table.ItemCount' \
    --region ap-south-1 \
    --endpoint-url=http://localhost:4566
``` 


> #### Obs: 
> Para mais orientações sobre uso prático do AWS CLI na ferramenta Dynamodb acesse o link
> acesse [Getting started with DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStartedDynamoDB.html)
> direto na doc da AWS ou [AWS CLI Command Referenc e DynamoDb](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/dynamodb/index.html).

#### [Comece com o Simple Queue Service (SQS) no LocalStack](https://docs.localstack.cloud/user-guide/aws/sqs/)

Para criar uma fila SQS, use o CreateQueueAPI. Execute o seguinte comando para criar uma fila chamada localstack-queue:

```shell
aws sqs create-queue \
--queue-name localstack-queue \
--endpoint-url=http://localhost:4566  
```

Listar SQS

```shell
aws sqs list-queues \
--endpoint-url=http://localhost:4566 
```

> #### Obs:
> Para mais orientações sobre uso prático do AWS CLI na ferramenta SQS acesse o link
> direto na doc da AWS [AWS CLI Command Reference SQS](https://docs.aws.amazon.com/cli/latest/reference/sqs/).

---

#### [Comece com o Simple Notification Service (SNS) no LocalStack ](https://docs.localstack.cloud/user-guide/aws/sns/)

Para criar um tópico SNS, use o `create-topic`:

```shell
aws sns create-topic --name localstack-topic --endpoint-url=http://localhost:4566 
```

Você pode definir o atributo do tópico SNS usando o tópico SNS criado anteriormente usando o comando `set-topic-attributes`.
```shell
aws sns set-topic-attributes \
   --topic-arn arn:aws:sns:sa-east-1:000000000000:localstack-topic \
   --attribute-name DisplayName \
   --attribute-value MyTopicDisplayName \
   --endpoint-url=http://localhost:4566
```

Você pode listar todos os tópicos do SNS usando o `list-topics
```shell
aws sns list-topics --endpoint-url=http://localhost:4566 
```

Você pode obter atributos para um único tópico SNS usando o `get-topic-attributes`
```shell
aws sns get-topic-attributes \
   --topic-arn arn:aws:sns:sa-east-1:000000000000:localstack-topic \
   --endpoint-url=http://localhost:4566 
```

Para publicar mensagens no tópico SNS, crie um novo arquivo chamado messages.txt em seu diretório atual e adicione algum 
conteúdo. Execute o seguinte comando para publicar mensagens no tópico SNS usando o `publish`:
```shell
aws sns publish \
   --topic-arn "arn:aws:sns:sa-east-1:000000000000:localstack-topic" \
   --message file://message.txt \
   --endpoint-url=http://localhost:4566 
```

Você pode se inscrever no tópico SNS usando o `subscribe`:
```shell
aws sns subscribe \
   --topic-arn arn:aws:sns:sa-east-1:000000000000:localstack-topic \
   --protocol email \
   --notification-endpoint william.reges1986@gmail.com \
   --endpoint-url=http://localhost:4566 
```

> #### Obs:
> Para mais orientações sobre uso prático do AWS CLI na ferramenta SNS acesse o link
> direto na doc da AWS [AWS CLI Command Reference SNS](https://docs.aws.amazon.com/cli/latest/reference/sns/).

---

### Referencias

LocalStack:
- Overview: https://docs.localstack.cloud/overview
- User Guides: https://docs.localstack.cloud/user-guide
- [Comece com S3 no LocalStack ](https://docs.localstack.cloud/user-guide/aws/s3)
- [Comece com Lambda no LocalStack ](https://docs.localstack.cloud/user-guide/aws/lambda)
- [Comece a usar o DynamoDB no LocalStack ](https://docs.localstack.cloud/user-guide/aws/dynamodb)
- [Comece com o Simple Queue Service (SQS) no LocalStack](https://docs.localstack.cloud/user-guide/aws/sqs/)
- [Comece com o Simple Notification Service (SNS) no LocalStack ](https://docs.localstack.cloud/user-guide/aws/sns/)

AWS:
- [AWS Cli Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
