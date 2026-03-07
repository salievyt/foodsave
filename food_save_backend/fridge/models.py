from django.db import models
from django.conf import settings

User = settings.AUTH_USER_MODEL

class Category(models.Model):
    name = models.CharField(max_length=100, help_text="Category name (e.g., Dairy, Meat, Vegetables)")
    icon_name = models.CharField(max_length=50, blank=True, null=True, help_text="Flutter IconData name or asset path")
    
    class Meta:
        verbose_name_plural = "Categories"

    def __str__(self):
        return self.name

class Product(models.Model):
    class StatusChoices(models.TextChoices):
        ACTIVE = 'ACTIVE', 'В холодильнике'
        CONSUMED = 'CONSUMED', 'Съедено'
        WASTED = 'WASTED', 'Выброшено'
        
    class UnitChoices(models.TextChoices):
        PIECES = 'PCS', 'шт'
        GRAMS = 'G', 'г'
        KILOGRAMS = 'KG', 'кг'
        MILLILITERS = 'ML', 'мл'
        LITERS = 'L', 'л'

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='fridge_items')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='products')
    name = models.CharField(max_length=200, help_text="Name of the product (e.g., Milk, Tomatoes)")
    
    quantity = models.DecimalField(max_digits=10, decimal_places=2, default=1.0)
    unit = models.CharField(max_length=10, choices=UnitChoices.choices, default=UnitChoices.PIECES)
    
    added_date = models.DateField(auto_now_add=True)
    expiration_date = models.DateField(help_text="Best before or use by date")
    
    status = models.CharField(max_length=10, choices=StatusChoices.choices, default=StatusChoices.ACTIVE)
    notes = models.TextField(blank=True, help_text="Optional remarks on this product")
    
    def __str__(self):
        return f'{self.name} ({self.user})'
    
    class Meta:
        ordering = ['expiration_date']
