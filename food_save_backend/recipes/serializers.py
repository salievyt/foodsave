from rest_framework import serializers
from .models import Recipe, RecipeIngredient, RecipeStep

class RecipeIngredientSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecipeIngredient
        fields = ('id', 'name', 'amount', 'is_optional')

class RecipeStepSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecipeStep
        fields = ('id', 'step_number', 'instruction')

class RecipeSerializer(serializers.ModelSerializer):
    ingredients = RecipeIngredientSerializer(many=True, read_only=True)
    steps = RecipeStepSerializer(many=True, read_only=True)

    class Meta:
        model = Recipe
        fields = ('id', 'title', 'description', 'image_url', 'prep_time_minutes', 'cook_time_minutes', 'calories', 'dietary_tags', 'ingredients', 'steps')
