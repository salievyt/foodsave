import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import AccessToken
from .models import SupportMessage

User = get_user_model()

class SupportChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Получаем токен из query параметров
        query_string = self.scope['query_string'].decode()
        token = None
        if 'token=' in query_string:
            token = query_string.split('token=')[1].split('&')[0]

        self.user = None
        if token:
            try:
                access_token = AccessToken(token)
                user_id = access_token['user_id']
                self.user = await self.get_user(user_id)
            except Exception as e:
                print(f"WS Auth Error: {e}")

        if self.user and self.user.is_authenticated:
            # Уникальная комната для пользователя
            self.room_group_name = f'support_chat_{self.user.id}'
            await self.channel_layer.group_add(self.room_group_name, self.channel_name)
            await self.accept()
        else:
            await self.close()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']

        # Сохраняем в БД с привязкой к юзеру
        await self.save_message(message, is_from_user=True)

        # Рассылаем в комнату (хотя в этой комнате только юзер, 
        # но это позволит оператору подключиться к ней же если надо)
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message,
                'is_from_user': True
            }
        )

    async def chat_message(self, event):
        message = event['message']
        is_from_user = event.get('is_from_user', False)

        # Отправляем юзеру в сокет только сообщения от ПОДДЕРЖКИ
        # (свои он и так видит в UI мгновенно)
        if not is_from_user:
            await self.send(text_data=json.dumps({
                'message': message,
                'is_from_support': True
            }))

    @database_sync_to_async
    def get_user(self, user_id):
        try:
            return User.objects.get(id=user_id)
        except User.DoesNotExist:
            return None

    @database_sync_to_async
    def save_message(self, text, is_from_user):
        return SupportMessage.objects.create(
            user=self.user, 
            text=text, 
            is_from_user=is_from_user
        )
