from django.contrib import admin
from .models import Recipe, RecipeIngredient, RecipeStep

class RecipeIngredientInline(admin.TabularInline):
    model = RecipeIngredient
    extra = 1

class RecipeStepInline(admin.TabularInline):
    model = RecipeStep
    extra = 1

@admin.register(Recipe)
class RecipeAdmin(admin.ModelAdmin):
    list_display = ('title', 'prep_time_minutes', 'cook_time_minutes', 'calories')
    inlines = [RecipeIngredientInline, RecipeStepInline]
    search_fields = ('title', 'dietary_tags')
