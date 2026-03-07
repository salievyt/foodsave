from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
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
        
        scanned_items = [
            {
                "name": "Молоко 'Домик в деревне' 3.2%",
                "quantity": 1,
                "unit": "L",
                "expiration_days_estimated": 7
            },
            {
                "name": "Яблоки Голден",
                "quantity": 1.5,
                "unit": "KG",
                "expiration_days_estimated": 14
            },
            {
                "name": "Сосиски Молочные",
                "quantity": 0.5,
                "unit": "KG",
                "expiration_days_estimated": 5
            }
        ]

        return Response({
            "status": "success",
            "message": "Чек успешно отсканирован",
            "items": scanned_items
        }, status=status.HTTP_200_OK)
