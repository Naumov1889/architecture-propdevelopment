#!/bin/bash

# Создаем директорию для сертификатов пользователей
mkdir -p user-certs
cd user-certs

# Создаем приватный ключ для пользователя viewer
openssl genrsa -out viewer.key 2048
# Создаем CSR (Certificate Signing Request)
openssl req -new -key viewer.key -out viewer.csr -subj "/CN=viewer/O=viewers"
# Подписываем CSR корневым сертификатом кластера
openssl x509 -req -in viewer.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out viewer.crt -days 365

# Создаем приватный ключ для пользователя editor
openssl genrsa -out editor.key 2048
# Создаем CSR (Certificate Signing Request)
openssl req -new -key editor.key -out editor.csr -subj "/CN=editor/O=editors"
# Подписываем CSR корневым сертификатом кластера
openssl x509 -req -in editor.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out editor.crt -days 365

# Создаем приватный ключ для пользователя admin
openssl genrsa -out admin.key 2048
# Создаем CSR (Certificate Signing Request)
openssl req -new -key admin.key -out admin.csr -subj "/CN=admin/O=admins"
# Подписываем CSR корневым сертификатом кластера
openssl x509 -req -in admin.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out admin.crt -days 365

# Добавляем конфигурации пользователей в kubeconfig
kubectl config set-credentials viewer --client-certificate=viewer.crt --client-key=viewer.key --embed-certs=true
kubectl config set-credentials editor --client-certificate=editor.crt --client-key=editor.key --embed-certs=true
kubectl config set-credentials admin --client-certificate=admin.crt --client-key=admin.key --embed-certs=true

echo "Пользователи viewer, editor и admin созданы и добавлены в kubeconfig"