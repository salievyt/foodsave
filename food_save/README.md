# 📱 FoodSave App (Flutter Frontend)

Это клиентская часть приложения **FoodSave**, построенная на Flutter с использованием современной **Feature-First** архитектуры.

## 🏛️ Архитектура (Senior Level)

Проект организован по функциональным модулям в директории `lib/features/`:

```
lib/
 ├── core/
 │    ├── router/      # Роутинг (AutoRoute)
 │    ├── services/    # Общие сервисы (ApiService)
 │    ├── theme/       # Темы и цвета
 │    └── widgets/     # Глобальные виджеты
 └── features/         # Функциональные фичи
      └── <feature_name>/
           ├── domain/          # Модели и сущности
           └── presentation/    # Pages, Widgets, Controllers
```

---

## 🛠️ Основные Зависимости

*   🛡️ **State Management:** `flutter_riverpod`
*   🚦 **Navigation:** `auto_route`
*   🌐 **Networking:** `dio`
*   💾 **Local Storage:** `shared_preferences`
*   📸 **Image Capture:** `image_picker`
*   💬 **Realtime Support:** `web_socket_channel`

---

## 🔌 Связь с Backend

Все запросы проходят через `ApiService` (находится в `/lib/core/services/`).

*   **Логин (Login):** Реальный запрос к Django серверу с получением JWT токенов.
*   **Сканер (OCR):** Отправка фото на сервер и получение результатов распознавания.
*   **Чат:** Прямое WebSocket соединение с Django Channels.

---

## ⚡ Быстрый запуск

1.  Подготовьте env: `cp .env.example .env`
2.  Установите зависимости: `flutter pub get`
3.  Сгенерируйте код: `flutter pub run build_runner build --delete-conflicting-outputs`
4.  Запустите: `flutter run`

## ⚙️ Конфигурация окружения

Фронтенд читает `API_BASE_URL` и `WS_BASE_URL` из файла `.env`.

---

**Приложение поддерживает мобильные платформы (iOS, Android). 🚀🍎**
