

## Роли и их полномочия
| Роль  | Права роли | Группы пользователей |
| --- | --- | --- |
| viewer-role | Чтение (get, list, watch) всех ресурсов в основных API-группах (core, extensions, apps, batch, autoscaling) | Разработчики, тестировщики, аналитики, которые только просматривают ресурсы |
| editor-role | Полный доступ (create, update, delete и др.) ко всем ресурсам в основных API-группах, кроме секретов и serviceaccounts (только чтение) | Старшие разработчики, DevOps-инженеры, которым нужно развертывать приложения |
| admin-role | Полный доступ ко всем ресурсам во всех API-группах | Администраторы кластера, ответственные за инфраструктуру |



## Скрипты
1. [Скрипт для создания пользователей](./create-users.sh)
2. [Скрипт для создания ролей и RoleBindings/ClusterRoleBindings](./create-roles.sh)
3. [Скрипт, чтобы связать пользователей с ролями](./bind-roles.sh)

## Инструкция
Убедитесь, что Minikube запущен:

```bash
minikube start
```

Сделайте скрипты исполняемыми:
```bash
chmod +x create-users.sh create-roles.sh bind-roles.sh
```

Запустите скрипты в следующем порядке:
```bash
./create-users.sh
./create-roles.sh
./bind-roles.sh
```

## Проверка работы
После выполнения скриптов вы можете проверить доступы для разных пользователей:

Для пользователя viewer (только просмотр):
```bash
kubectl --user=viewer get pods
kubectl --user=viewer create deployment nginx --image=nginx  # Должно быть запрещено
```

Для пользователя editor (редактирование):
```bash
kubectl --user=editor create deployment nginx --image=nginx
kubectl --user=editor get secrets  # Должно работать только чтение
```

Для пользователя admin (полный доступ):
```bash
kubectl --user=admin create secret generic test --from-literal=key=value
kubectl --user=admin delete deployment nginx
```


## Это решение обеспечивает:
- Три уровня доступа (viewer, editor, admin)
- Защиту чувствительных ресурсов (секреты)
- Простую масштабируемость для добавления новых пользователей
- Соответствие принципу наименьших привилегий