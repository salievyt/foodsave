import 'package:flutter/material.dart';
import 'package:food_save/core/theme/app_colors.dart';
import 'package:food_save/features/profile/presentation/viewmodels/profile_view_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onAvatarTap;
  final Widget? badge;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onAvatarTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor.withOpacity(0.6)),
              image: profile.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(profile.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile.avatarUrl == null
                ? Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withOpacity(0.6))
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.username,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email ?? "",
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
              ),
              if (badge != null) ...[
                const SizedBox(height: 6),
                badge!,
              ]
            ],
          ),
        ),
        IconButton(
          onPressed: onAvatarTap,
          icon: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        )
      ],
    );
  }
}
