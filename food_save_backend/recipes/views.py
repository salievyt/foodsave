from rest_framework import viewsets, permissions
from .models import Recipe
from .serializers import RecipeSerializer

class RecipeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Recipe.objects.all()
    serializer_class = RecipeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = Recipe.objects.all()
        # Here we could add logic to filter by available ingredients in fridge
        # For now, just return all recipes
        return queryset
