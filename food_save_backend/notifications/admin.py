from django.contrib import admin
from .models import AppNotification, SupportMessage
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

@admin.register(AppNotification)
class AppNotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'title', 'notification_type', 'is_read', 'created_at')
    list_filter = ('is_read', 'notification_type')

@admin.register(SupportMessage)
class SupportMessageAdmin(admin.ModelAdmin):
    list_display = ('user', 'is_from_user', 'text', 'created_at')
    list_filter = ('is_from_user', 'user')

    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)
        
        # Если это сообщение от поддержки, отправляем его юзеру через вебсокет
        if not obj.is_from_user and obj.user:
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                f'support_chat_{obj.user.id}',
                {
                    'type': 'chat_message',
                    'message': obj.text,
                    'is_from_user': False
                }
            )
    search_fields = ('user__username', 'message')
