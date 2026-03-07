from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AppNotificationViewSet, SupportMessageViewSet

router = DefaultRouter()
router.register(r'list', AppNotificationViewSet, basename='notification')
router.register(r'support-chat', SupportMessageViewSet, basename='support-chat')

urlpatterns = [
    path('', include(router.urls)),
]
