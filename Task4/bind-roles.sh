#!/bin/bash

# Связываем пользователя viewer с ролью viewer-role
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: viewer-binding
subjects:
- kind: User
  name: viewer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: viewer-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Связываем пользователя editor с ролью editor-role
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: editor-binding
subjects:
- kind: User
  name: editor
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: editor-role
  apiGroup: rbac.authorization.k8s.io
EOF

# Связываем пользователя admin с ролью admin-role
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-binding
subjects:
- kind: User
  name: admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin-role
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Пользователи привязаны к соответствующим ролям"