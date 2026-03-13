import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.redis import RedisIntegration
from sentry_sdk.integrations.channels import ChannelsIntegration
import os

def init_sentry():
    dsn = os.environ.get('SENTRY_DSN')
    
    if not dsn:
        print("Sentry DSN not configured - skipping initialization")
        return
    
    sentry_sdk.init(
        dsn=dsn,
        integrations=[
            DjangoIntegration(),
            RedisIntegration(),
            ChannelsIntegration(),
        ],
        # Трейсинг
        traces_sample_rate=0.1 if not DEBUG else 1.0,
        # Профилирование (требует Sentry Pro)
        profiles_sample_rate=0.0,
        # Режим release
        release=f'foodsave@1.1.0',
        environment='development' if DEBUG else 'production',
        # Фильтры
        ignore_errors=[
            'SocketException',
            'TimeoutError',
            'ConnectionRefusedError',
        ],
        #_before_send = before_send,
    )
    
    print("Sentry initialized successfully")

def before_send(event, hint):
    # Добавить дополнительные теги
    event['tags'] = {
        **event.get('tags', {}),
        'app': 'foodsave_backend',
        'backend': 'django',
    }
    return event
