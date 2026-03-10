from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db import transaction
from .models import Category, Product
from .serializers import CategorySerializer, ProductSerializer
import datetime

class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]

class ProductViewSet(viewsets.ModelViewSet):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Users only see their own fridge items
        return Product.objects.filter(user=self.request.user)

    @action(detail=False, methods=['post'], url_path='scan-receipt')
    def scan_receipt(self, request):
        # Mock scanner function
        # Expects: receipt_image (file)
        # We pretend to OCR the receipt and return some found items
        
        # Check if an image is provided
        if 'receipt_image' not in request.FILES:
            return Response({'error': 'No receipt image provided.'}, status=status.HTTP_400_BAD_REQUEST)

        # In a real app we would pass this image to Google Cloud Vision API or AWS Textract
        # and parse the lines. For now, we return mock data based on the idea that 
        # scanning works flawlessly.
        
        today = datetime.date.today()

        # Mock OCR output. We persist the scanned items to the user's fridge.
        scanned_items = [
            {
                "name": "Молоко 'Домик в деревне' 3.2%",
                "quantity": 1,
                "unit": "L",
                "expiration_days_estimated": 7,
                "category": "Молочка",
            },
            {
                "name": "Яблоки Голден",
                "quantity": 1.5,
                "unit": "KG",
                "expiration_days_estimated": 14,
                "category": "Фрукты",
            },
            {
                "name": "Сосиски Молочные",
                "quantity": 0.5,
                "unit": "KG",
                "expiration_days_estimated": 5,
                "category": "Мясо",
            }
        ]

        created_items = []
        with transaction.atomic():
            for item in scanned_items:
                category_name = item.get("category") or "Другое"
                category, _ = Category.objects.get_or_create(
                    name=category_name,
                    defaults={"icon_name": None},
                )
                expiration_date = today + datetime.timedelta(
                    days=int(item.get("expiration_days_estimated", 7))
                )
                product = Product.objects.create(
                    user=request.user,
                    category=category,
                    name=item["name"],
                    quantity=item.get("quantity", 1),
                    unit=item.get("unit", Product.UnitChoices.PIECES),
                    expiration_date=expiration_date,
                    status=Product.StatusChoices.ACTIVE,
                )
                created_items.append({
                    "id": product.id,
                    "name": product.name,
                    "quantity": product.quantity,
                    "unit": product.unit,
                    "expiration_date": product.expiration_date,
                    "category": category.name,
                })

        return Response({
            "status": "success",
            "message": "Чек успешно отсканирован",
            "items": created_items,
        }, status=status.HTTP_200_OK)
