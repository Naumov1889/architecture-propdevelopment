# Настройка сетевой изоляции в Kubernetes

[файл с настройкой сетевых политик в кластере Kubernetes](./non-admin-api-allow.yaml)

## Шаг 1: Развертывание четырех сервисов
Создайте четыре пода с соответствующими метками и сервисами:
```bash
# 1. Front-end сервис
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80

# 2. Back-end API сервис

kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80

# 3. Admin Front-end сервис
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80

# 4. Admin Back-end API сервис
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80
```

## Шаг 2: Проверка созданных ресурсов
```bash
# Проверим созданные поды
kubectl get pods --show-labels

## Проверим созданные сервисы
kubectl get services
```

## Шаг 3: Создание сетевых политик
Файл non-admin-api-allow.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: non-admin-api-allow
spec:
  podSelector:
    matchLabels:
      role: back-end-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: front-end
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: front-end
    ports:
    - protocol: TCP
      port: 80
  - to: {}
    ports:
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: front-end-allow
spec:
  podSelector:
    matchLabels:
      role: front-end
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: back-end-api
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: back-end-api
    ports:
    - protocol: TCP
      port: 80
  - to: {}
    ports:
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-api-allow
spec:
  podSelector:
    matchLabels:
      role: admin-back-end-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: admin-front-end
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: admin-front-end
    ports:
    - protocol: TCP
      port: 80
  - to: {}
    ports:
    - protocol: UDP
      port: 53
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-front-end-allow
spec:
  podSelector:
    matchLabels:
      role: admin-front-end
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: admin-back-end-api
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - podSelector:
        matchLabels:
          role: admin-back-end-api
    ports:
    - protocol: TCP
      port: 80
  - to: {}
    ports:
    - protocol: UDP
      port: 53
```

## Шаг 4: Применение сетевых политик
```bash
# Применить сетевые политики
kubectl apply -f non-admin-api-allow.yaml

# Проверить созданные политики
kubectl get networkpolicies
```

## Шаг 5: Тестирование сетевых политик
Разрешенные соединения (должны работать):
```bash
# Тест соединения front-end -> back-end-api
kubectl run test-frontend-$RANDOM --rm -i -t --image=alpine --labels role=front-end -- sh
# В контейнере:
wget -qO- --timeout=2 http://back-end-api-app

# Тест соединения admin-front-end -> admin-back-end-api
kubectl run test-admin-frontend-$RANDOM --rm -i -t --image=alpine --labels role=admin-front-end -- sh
# В контейнере:
wget -qO- --timeout=2 http://admin-back-end-api-app
```

Запрещенные соединения (должны не работать):
```bash
# Тест соединения front-end -> admin-back-end-api (должно быть заблокировано)
kubectl run test-blocked-$RANDOM --rm -i -t --image=alpine --labels role=front-end -- sh
# В контейнере:
wget -qO- --timeout=2 http://admin-back-end-api-app

# Тест соединения admin-front-end -> back-end-api (должно быть заблокировано)
kubectl run test-blocked2-$RANDOM --rm -i -t --image=alpine --labels role=admin-front-end -- sh
# В контейнере:
wget -qO- --timeout=2 http://back-end-api-app
```

## Объяснение Network Policy
Созданные политики обеспечивают следующие правила:

front-end может взаимодействовать только с back-end-api
back-end-api может взаимодействовать только с front-end
admin-front-end может взаимодействовать только с admin-back-end-api
admin-back-end-api может взаимодействовать только с admin-front-end

Все остальные соединения между подами блокируются.

## Дополнительные команды для диагностики
```bash
# Посмотреть подробную информацию о NetworkPolicy
kubectl describe networkpolicy non-admin-api-allow

# Проверить логи подов

kubectl logs <pod-name>

# Удалить все созданные ресурсы (если нужно)
kubectl delete pods --selector="role in (front-end,back-end-api,admin-front-end,admin-back-end-api)"
kubectl delete services --selector="role in (front-end,back-end-api,admin-front-end,admin-back-end-api)"
kubectl delete networkpolicies --all
```

## Важные замечания
- DNS разрешение: В политиках добавлен egress для UDP порта 53, чтобы разрешить DNS-запросы
- Двусторонняя связь: Политики настроены для обеспечения связи в обе стороны между парными сервисами
- Изоляция: Поды без соответствующих меток не смогут взаимодействовать с защищенными сервисами
- CNI поддержка: Убедитесь, что ваш CNI плагин (например, Calico, Cilium) поддерживает Network Policies