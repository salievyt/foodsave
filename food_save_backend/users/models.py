from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    # FoodSave specific fields
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True, help_text="User's avatar image")
    is_premium = models.BooleanField(default=False, help_text="Designates whether the user has a premium subscription")
    
    # Keeping track of app statistics easily
    items_saved_count = models.PositiveIntegerField(default=0, help_text="Total items this user kept from wasting")
    items_wasted_count = models.PositiveIntegerField(default=0, help_text="Total items this user threw away")

    # Dietary preferences and allergies could be M2M, or simple TextFields/JSONFields depending on scale.
    # For simplicity, we can store comma-separated strings or use Django's ArrayField if on PostgreSQL. 
    # Since we are using SQLite by default, let's use a TextField
    dietary_preferences = models.TextField(blank=True, help_text="Comma separated list of dietary preferences (e.g., Vegan, Keto)")
    allergies = models.TextField(blank=True, help_text="Comma separated list of allergies (e.g., Peanuts, Lactose)")

    def __str__(self):
        return self.username
