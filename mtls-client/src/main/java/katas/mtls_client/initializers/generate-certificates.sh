#!/bin/bash

# Set up variables
ROOT_CA_PASSWORD="rootcapass"
SERVER_PASSWORD="serverpass"
CLIENT_PASSWORD="clientpass"
KEYSTORE_PASSWORD="keystorepass"

# Create directories
mkdir -p ../../resources/certs
CERT_DIR="../../resources/certs"
rm -rf $CERT_DIR
mkdir -p $CERT_DIR

# Generate Root CA key and certificate
openssl genpkey -algorithm RSA -out $CERT_DIR/rootCA.key -aes256 -pass pass:$ROOT_CA_PASSWORD
openssl req -x509 -new -key $CERT_DIR/rootCA.key -days 365 -out $CERT_DIR/rootCA.crt -passin pass:$ROOT_CA_PASSWORD -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=RootCA"

# Generate Server key and CSR
openssl genpkey -algorithm RSA -out $CERT_DIR/server.key -aes256 -pass pass:$SERVER_PASSWORD
openssl req -new -key $CERT_DIR/server.key -out $CERT_DIR/server.csr -passin pass:$SERVER_PASSWORD -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost"

# Sign the server CSR with Root CA
openssl x509 -req -in $CERT_DIR/server.csr -CA $CERT_DIR/rootCA.crt -CAkey $CERT_DIR/rootCA.key -CAcreateserial -out $CERT_DIR/server.crt -days 365 -sha256 -passin pass:$ROOT_CA_PASSWORD

# Generate Client key and CSR
openssl genpkey -algorithm RSA -out $CERT_DIR/client.key -aes256 -pass pass:$CLIENT_PASSWORD
openssl req -new -key $CERT_DIR/client.key -out $CERT_DIR/client.csr -passin pass:$CLIENT_PASSWORD -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=Client"

# Sign the client CSR with Root CA
openssl x509 -req -in $CERT_DIR/client.csr -CA $CERT_DIR/rootCA.crt -CAkey $CERT_DIR/rootCA.key -CAcreateserial -out $CERT_DIR/client.crt -days 365 -sha256 -passin pass:$ROOT_CA_PASSWORD

# Create PKCS12 keystore for server
openssl pkcs12 -export -in $CERT_DIR/server.crt -inkey $CERT_DIR/server.key -out $CERT_DIR/server-keystore.p12 -name server -CAfile $CERT_DIR/rootCA.crt -caname root -passin pass:$SERVER_PASSWORD -passout pass:$KEYSTORE_PASSWORD

# Create PKCS12 keystore for client
openssl pkcs12 -export -in $CERT_DIR/client.crt -inkey $CERT_DIR/client.key -out $CERT_DIR/client-keystore.p12 -name client -CAfile $CERT_DIR/rootCA.crt -caname root -passin pass:$CLIENT_PASSWORD -passout pass:$KEYSTORE_PASSWORD

# Convert PKCS12 keystores to JKS
keytool -importkeystore -srckeystore $CERT_DIR/server-keystore.p12 -srcstoretype pkcs12 -destkeystore $CERT_DIR/server-keystore.jks -deststoretype jks -srcstorepass $KEYSTORE_PASSWORD -deststorepass $KEYSTORE_PASSWORD -alias server
keytool -importkeystore -srckeystore $CERT_DIR/client-keystore.p12 -srcstoretype pkcs12 -destkeystore $CERT_DIR/client-keystore.jks -deststoretype jks -srcstorepass $KEYSTORE_PASSWORD -deststorepass $KEYSTORE_PASSWORD -alias client

echo "Certificates generated and stored in $CERT_DIR"
