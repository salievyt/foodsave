from django.db import models

class Recipe(models.Model):
    title = models.CharField(max_length=200, help_text="Recipe Title")
    description = models.TextField(blank=True, help_text="Short overview of the dish")
    image_url = models.URLField(max_length=500, blank=True, null=True, help_text="Link to dish image")
    
    prep_time_minutes = models.PositiveIntegerField(default=15, help_text="Preparation time")
    cook_time_minutes = models.PositiveIntegerField(default=30, help_text="Cooking time")
    calories = models.PositiveIntegerField(blank=True, null=True, help_text="Calories per serving")
    
    dietary_tags = models.TextField(blank=True, help_text="Comma-separated tags (e.g., Vegan, Gluten-Free, Keto)")

    def __str__(self):
        return self.title

class RecipeIngredient(models.Model):
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name='ingredients')
    name = models.CharField(max_length=150, help_text="Ingredient name (e.g., Apple, Chicken Breast)")
    amount = models.CharField(max_length=100, help_text="Quantity (e.g., 500g, 2 pieces, 1 cup)")
    is_optional = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.amount} of {self.name} for {self.recipe.title}"

class RecipeStep(models.Model):
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name='steps')
    step_number = models.PositiveIntegerField(help_text="Order of execution")
    instruction = models.TextField(help_text="What to do in this step")

    class Meta:
        ordering = ['step_number']

    def __str__(self):
        return f"Step {self.step_number} for {self.recipe.title}"
