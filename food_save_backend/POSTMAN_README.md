# FoodSave API - Postman Коллекция

Документация для импорта в Postman.

## Импорт коллекции

1. Откройте Postman
2. Нажмите **Import** (кнопка в левом верхнем углу)
3. Выберите файл `FoodSave_API.postman_collection.json`
4. Нажмите **Import**

## Импорт окружения (опционально)

1. В Postman нажмите на шестерёнку (Manage Environments)
2. Нажмите **Import**
3. Выберите файл `FoodSave_Environment.postman_environment.json`

## Быстрый старт

### 1. Регистрация
```
POST {{baseUrl}}/api/auth/register/
Body: {
    "username": "your_username",
    "email": "your@email.com",
    "password": "your_password"
}
```

### 2. Вход (получение токенов)
```
POST {{baseUrl}}/api/auth/login/
Body: {
    "username": "your_username",
    "password": "your_password"
}
```

Ответ содержит:
- `access` - токен доступа (действителен 5 минут)
- `refresh` - токен обновления

### 3. Настройка токена
1. Скопируйте значение `access` из ответа
2. В Postman перейдите в **Manage Environments**
3. В переменную `accessToken` вставьте полученный токен

Теперь все запросы авторизованы.

## Эндпоинты

### Auth (Аутентификация)

| Метод | URL | Описание |
|-------|-----|----------|
| POST | `/api/auth/register/` | Регистрация нового пользователя |
| POST | `/api/auth/login/` | Вход, получение JWT токенов |
| POST | `/api/auth/login/refresh/` | Обновление access токена |
| GET | `/api/auth/profile/` | Получить профиль пользователя |
| PUT | `/api/auth/profile/` | Обновить профиль |

### Fridge (Холодильник)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/fridge/categories/` | Список категорий продуктов |
| GET | `/api/fridge/products/` | Список продуктов пользователя |
| POST | `/api/fridge/products/` | Добавить продукт |
| GET | `/api/fridge/products/{id}/` | Детали продукта |
| PUT | `/api/fridge/products/{id}/` | Обновить продукт |
| DELETE | `/api/fridge/products/{id}/` | Удалить продукт |
| POST | `/api/fridge/products/scan-receipt/` | Сканировать чек |

### Recipes (Рецепты)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/recipes/` | Список рецептов |
| GET | `/api/recipes/{id}/` | Детали рецепта |

### Notifications (Уведомления)

| Метод | URL | Описание |
|-------|-----|----------|
| GET | `/api/notifications/list/` | Список уведомлений |
| POST | `/api/notifications/list/` | Создать уведомление |
| POST | `/api/notifications/list/{id}/mark_read/` | Отметить как прочитанное |
| GET | `/api/notifications/support-chat/` | История чата поддержки |
| POST | `/api/notifications/support-chat/` | Отправить сообщение в поддержку |

## Типы данных

### Product Status
- `ACTIVE` - В холодильнике
- `CONSUMED` - Съедено
- `WASTED` - Выброшено

### Product Unit
- `PCS` - штук
- `G` - грамм
- `KG` - килограмм
- `ML` - миллилитр
- `L` - литр

## Запуск сервера

```bash
cd food_save_backend
python manage.py runserver
```

Сервер запустится на http://localhost:8000
