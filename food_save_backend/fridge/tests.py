from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework.test import APIClient
from .models import Product

class ScanReceiptTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = get_user_model().objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpass123",
        )
        self.client.force_authenticate(self.user)

    def test_scan_receipt_creates_products(self):
        before_count = Product.objects.count()
        image = SimpleUploadedFile("receipt.jpg", b"fake-image-bytes", content_type="image/jpeg")

        response = self.client.post(
            "/api/fridge/products/scan-receipt/",
            {"receipt_image": image},
            format="multipart",
        )

        self.assertEqual(response.status_code, 200)
        self.assertGreater(Product.objects.count(), before_count)
        self.assertIn("items", response.data)
