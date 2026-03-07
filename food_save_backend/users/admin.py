from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

# Register your models here.
@admin.register(User)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ('FoodSave Info', {'fields': ('avatar_url', 'is_premium', 'items_saved_count', 'items_wasted_count', 'dietary_preferences', 'allergies')}),
    )
    list_display = ('username', 'email', 'is_premium', 'items_saved_count', 'items_wasted_count', 'is_staff')
