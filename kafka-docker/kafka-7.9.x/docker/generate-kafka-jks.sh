#!/bin/bash

set -e

SECRETS_DIR="./secrets"
mkdir -p "$SECRETS_DIR"

echo "=== Script para gerar keystores e truststores para Kafka Broker e Cliente ==="

# Entrada de dados para broker
read -p "Digite o hostname do broker (ex: kafka-server): " BROKER_HOSTNAME
BROKER_HOSTNAME=${BROKER_HOSTNAME:-kafka-server}

read -s -p "Digite a senha para o keystore do broker, para a chave privada do broker e para o truststore do broker:" PASS_BROKER

BROKER_KEYSTORE_PASS=$PASS_BROKER
BROKER_KEY_PASS=$PASS_BROKER
BROKER_TRUSTSTORE_PASS=$PASS_BROKER

echo

# Entrada de dados para cliente
read -p "Digite o nome do cliente (ex: kafka-client): " CLIENT_NAME
CLIENT_NAME=${CLIENT_NAME:-kafka-client}

read -s -p "Digite a senha para o keystore do cliente, para a chave privada do cliente e para o truststore do cliente: " PASS_CLIENT
echo

CLIENT_KEYSTORE_PASS=$PASS_CLIENT
CLIENT_KEY_PASS=$PASS_CLIENT
CLIENT_TRUSTSTORE_PASS=$PASS_CLIENT

# Arquivos do broker
BROKER_KEYSTORE="$SECRETS_DIR/$BROKER_HOSTNAME.keystore.jks"
BROKER_TRUSTSTORE="$SECRETS_DIR/$BROKER_HOSTNAME.truststore.jks"
BROKER_CERT="$SECRETS_DIR/$BROKER_HOSTNAME.crt"
echo $BROKER_KEYSTORE_PASS > $SECRETS_DIR/kafka_server_keystore_credentials
echo $BROKER_KEY_PASS > $SECRETS_DIR/kafka_server_sslkey_credentials
echo $BROKER_TRUSTSTORE_PASS > $SECRETS_DIR/kafka_server_truststore_credentials

# Arquivos do cliente
CLIENT_KEYSTORE="$SECRETS_DIR/$CLIENT_NAME.keystore.jks"
CLIENT_TRUSTSTORE="$SECRETS_DIR/$CLIENT_NAME.truststore.jks"
CLIENT_CERT="$SECRETS_DIR/$CLIENT_NAME.crt"
echo $CLIENT_KEYSTORE_PASS > $SECRETS_DIR/kafka_client_keystore_credentials
echo $CLIENT_KEY_PASS > $SECRETS_DIR/kafka_client_sslkey_credentials
echo $CLIENT_TRUSTSTORE_PASS > $SECRETS_DIR/kafka_client_truststore_credentials

echo "Gerando keystore do broker com chave privada e certificado autoassinado..."

keytool -genkeypair \
  -alias kafka-server \
  -keyalg RSA \
  -keysize 2048 \
  -validity 365 \
  -keystore "$BROKER_KEYSTORE" \
  -storepass "$BROKER_KEYSTORE_PASS" \
  -dname "CN=$BROKER_HOSTNAME, OU=Kafka, O=Consultor, L=Guaarulhos, ST=SP, C=Brasil" \
  -keypass "$BROKER_KEY_PASS"

echo "Exportando certificado do broker..."

keytool -export \
  -alias kafka-server \
  -file "$BROKER_CERT" \
  -keystore "$BROKER_KEYSTORE" \
  -storepass "$BROKER_KEYSTORE_PASS"

echo "Gerando keystore do cliente com chave privada e certificado autoassinado..."

keytool -genkeypair \
  -alias $CLIENT_NAME \
  -keyalg RSA \
  -keysize 2048 \
  -validity 365 \
  -keystore "$CLIENT_KEYSTORE" \
  -storepass "$CLIENT_KEYSTORE_PASS" \
  -dname "CN=$CLIENT_NAME, OU=Kafka, O=SuaEmpresa, L=SuaCidade, ST=SeuEstado, C=SeuPais" \
  -keypass "$CLIENT_KEY_PASS"

echo "Exportando certificado do cliente..."
keytool -export \
  -alias $CLIENT_NAME \
  -file "$CLIENT_CERT" \
  -keystore "$CLIENT_KEYSTORE" \
  -storepass "$CLIENT_KEYSTORE_PASS"

echo "Criando truststore do broker e importando certificado do cliente..."
keytool -import \
  -alias $CLIENT_NAME \
  -file "$CLIENT_CERT" \
  -keystore "$BROKER_TRUSTSTORE" \
  -storepass "$BROKER_TRUSTSTORE_PASS" \
  -noprompt

echo "Criando truststore do cliente e importando certificado do broker..."
keytool -import \
  -alias kafka-server \
  -file "$BROKER_CERT" \
  -keystore "$CLIENT_TRUSTSTORE" \
  -storepass "$CLIENT_TRUSTSTORE_PASS" \
  -noprompt

echo
echo "Arquivos gerados em $SECRETS_DIR:"
echo "Broker:"
echo " - Keystore: $BROKER_KEYSTORE"
echo " - Truststore: $BROKER_TRUSTSTORE"
echo " - Certificado: $BROKER_CERT"
echo
echo "Cliente:"
echo " - Keystore: $CLIENT_KEYSTORE"
echo " - Truststore: $CLIENT_TRUSTSTORE"
echo " - Certificado: $CLIENT_CERT"
echo
echo "=== DOCKER BROKER ENVIRONMENT cp-kakfa==="
echo
echo " KAFKA_SSL_CLIENT_AUTH: 'required'"
echo " KAFKA_SSL_KEYSTORE_FILENAME: '${BROKER_HOSTNAME}.keystore.jks'"
echo " KAFKA_SSL_KEYSTORE_CREDENTIALS: 'kafka_server_keystore_credentials'"
echo " KAFKA_SSL_KEY_CREDENTIALS: 'kafka_server_sslkey_credentials'"
echo " KAFKA_SSL_TRUSTSTORE_FILENAME: '${BROKER_HOSTNAME}.truststore.jks'"
echo " KAFKA_SSL_TRUSTSTORE_CREDENTIALS: 'kafka_server_truststore_credentials'"
echo
echo "=== Spring Boot - application.properties==="
echo "security.protocol: SSL"
echo "ssl.truststore.location: file:./${CLIENT_NAME}.truststore.jks"
echo "ssl.truststore.password: ${CLIENT_TRUSTSTORE_PASS}"
echo "ssl.keystore.location: file:./${CLIENT_NAME}.keystore.jks"
echo "ssl.keystore.password: ${CLIENT_KEYSTORE_PASS}"
echo "ssl.key.password: ${CLIENT_KEY_PASS}"
echo
echo "E para o cliente, configure o keystore e truststore correspondentes com as senhas usadas."
