# LocalStack

---

### Documentaçao do LocalStack

- Overview: https://docs.localstack.cloud/overview  
- User Guides: https://docs.localstack.cloud/user-guide 

---
### Requisitos
1. Instale o LocalStack pelo Docker Compose

```shell
docker-compose up -d
```

2. Instale o AWS CLI para poder rodar os comandos

```shell
sudo snap install aws-cli --classic
```
3. Configure AWS CLI para utilizar no LocalStack

```shell
aws configure
```
e informe os seguintes parametros pedidos
```shell
AWS Access Key ID [None]: fake
AWS Secret Access Key [None]: fake
Default region name [None]: sa-east-1
Default output format [None]: json
```

### Comandos Exemplos

#### [Criando Bucket S3](https://docs.localstack.cloud/user-guide/aws/s3/#create-an-s3-bucket)
```shell
awslocal s3api create-bucket --bucket sample-bucket
```
ou

```shell
aws s3 mb s3://sample-bucket --endpoint-url=http://localhost:4566 
```

Listar os Buckets
```shell
aws s3 ls --endpoint-url=http://localhost:4566 
```
---

#### [Criando Função Lambda](https://docs.localstack.cloud/user-guide/aws/lambda/#create-a-lambda-function)

Para criar uma nova função Lambda, crie um novo arquivo chamado index.jscom o seguinte código:
```renderscript
exports.handler = async (event) => {
    let body = JSON.parse(event.body)
    const product = body.num1 * body.num2;
    const response = {
        statusCode: 200,
        body: "The product of " + body.num1 + " and " + body.num2 + " is " + product,
    };
    return response;
};
```

Insira o seguinte comando para criar uma nova função Lambda:

```shell
zip function.zip index.js
awslocal lambda create-function \
    --function-name localstack-lambda-url-example \
    --runtime nodejs18.x \
    --zip-file fileb://function.zip \
    --handler index.handler \
    --role arn:aws:iam::000000000000:role/lambda-role
```

Invocar a função

```shell
awslocal lambda invoke --function-name localstack-lambda-url-example \
    --payload '{"body": "{\"num1\": \"10\", \"num2\": \"10\"}" }' output.txt
```
---

#### [Criando Tabela no DynamoDb](https://docs.localstack.cloud/user-guide/aws/dynamodb/#create-a-dynamodb-table)

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
> direto na doc da AWS.

#### [SQS](https://docs.localstack.cloud/user-guide/aws/sqs/)

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

---



