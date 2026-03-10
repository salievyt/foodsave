# ⚙️ FoodSave Backend (Django REST Framework)

Это серверная часть приложения **FoodSave**, обеспечивающая логику хранения данных, аутентификацию и Realtime-взаимодействие.

## 🏗️ Основные Функции Backend:

*   🔐 **Auth System:** JWT-аутентификация (Simple JWT) с поддержкой регистрации и обновления токенов.
*   📦 **Fridge API:** CRUD операции для инвентаря пользователя.
*   📸 **Receipt OCR Simulator:** Эндпоинт для обработки изображений чеков и возврата структурированных данных (название, количество, срок годности).
*   🤖 **AI Recipes:** Эндпоинт для подбора блюд на основе скоропортящихся ингредиентов.
*   💬 **Django Channels:** WebSocket сервер для чата техподдержки.
*   🛡️ **CORS Support:** Полная настройка для работы с мобильным клиентом.

---

## 🛠️ Технологический Стек

*   🐍 **Core:** Python 3.x + Django 5.x
*   🚦 **Framework:** Django REST Framework (DRF)
*   🔑 **Security:** djangorestframework-simplejwt
*   📡 **Realtime:** Django Channels + Daphne (ASGI)
*   💾 **Database:** SQLite (по умолчанию для разработки) + Pillow (для обработки фото)
*   🔄 **CORS:** django-cors-headers

---

## 📂 Структура Сервера

```
food_save_backend/
 ├── config/            # Основные настройки проекта (settings.py, asgi.py, urls.py)
 ├── users/             # Кастомная модель пользователя и Auth эндпоинты
 ├── fridge/            # Логика холодильника и эмуляция OCR
 ├── recipes/           # База рецептов и логика поиска блюд
 └── notifications/     # Уведомления и WebSocket потребители (Support Chat)
```

---

## ⚡ Быстрый запуск

1.  Создайте виртуальное окружение: `python -m venv venv`
2.  Активируйте его: `source venv/bin/activate` (Mac/Linux) или `venv\Scripts\activate` (Windows)
3.  Установите пакеты (при необходимости): `pip install django djangorestframework djangorestframework-simplejwt channels daphne Pillow django-cors-headers`
4.  Сделайте миграции: `python manage.py makemigrations` и `python manage.py migrate`
5.  Запустите сервер: `python manage.py runserver 0.0.0.0:8000`

## 🧪 Тестовые данные (fixtures)

Для заполнения базовыми категориями и рецептами:

```bash
python manage.py loaddata fixtures/seed.json
```

Создание тестового пользователя:

```bash
python manage.py seed_demo
```

---

**Сервер готов принимать запросы от Flutter клиента. 🚀🥓**
