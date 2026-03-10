from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model

class Command(BaseCommand):
    help = "Create a demo user for local development"

    def handle(self, *args, **options):
        User = get_user_model()
        username = "demo"
        email = "demo@example.com"
        password = "demo12345"

        user, created = User.objects.get_or_create(
            username=username,
            defaults={"email": email},
        )

        if created:
            user.set_password(password)
            user.save()
            self.stdout.write(self.style.SUCCESS("Created demo user: demo / demo12345"))
        else:
            self.stdout.write(self.style.WARNING("Demo user already exists"))
