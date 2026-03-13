import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_save/features/profile/presentation/controllers/profile_controller.dart';

class HomeBrandHeader extends ConsumerWidget {
  final VoidCallback onAvatarTap;

  const HomeBrandHeader({super.key, required this.onAvatarTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileState = ref.watch(userProfileProvider);
    final name = profileState.data?.username.split(' ').first ?? "Друг";

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "FoodSave",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Привет, $name",
              style: theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
              image: profileState.data?.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profileState.data!.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileState.data?.avatarUrl == null
              // ignore: deprecated_member_use
                ? Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withOpacity(0.6))
                : null,
          ),
        ),
      ],
    );
  }
}
