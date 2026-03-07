from rest_framework import serializers
from .models import AppNotification, SupportMessage

class AppNotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppNotification
        fields = ('id', 'title', 'content', 'is_read', 'created_at', 'notification_type')
        read_only_fields = ('id', 'created_at')

class SupportMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = SupportMessage
        fields = ('id', 'text', 'is_from_user', 'created_at')
        read_only_fields = ('id', 'created_at')
