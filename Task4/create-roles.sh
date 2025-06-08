#!/bin/bash

# Создаем ClusterRole для просмотра ресурсов (view-only)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: viewer-role
rules:
- apiGroups: ["", "extensions", "apps", "batch", "autoscaling"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
EOF

# Создаем ClusterRole для редактирования ресурсов (но без доступа к секретам и другим чувствительным данным)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: editor-role
rules:
- apiGroups: ["", "extensions", "apps", "batch", "autoscaling"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["secrets", "serviceaccounts"]
  verbs: ["get", "list", "watch"]
EOF

# Создаем ClusterRole для администраторов (полный доступ)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: admin-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

echo "Роли viewer-role, editor-role и admin-role созданы"