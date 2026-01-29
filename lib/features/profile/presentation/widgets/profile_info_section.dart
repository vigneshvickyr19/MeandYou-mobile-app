import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileInfoItem {
  final String title;
  final String value;
  final String? iconPath;
  final bool isVerified;
  final Widget? customValue;
  final VoidCallback? onTap;
  final bool canExpand;

  ProfileInfoItem({
    required this.title,
    required this.value,
    this.iconPath,
    this.isVerified = false,
    this.customValue,
    this.onTap,
    this.canExpand = true,
  });
}

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<ProfileInfoItem> items;
  final bool showDivider;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.items,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.white.withOpacity(0.1),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: item.onTap ?? () => _handleItemTap(context, item),
                borderRadius: _getBorderRadius(index, items.length),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      if (item.iconPath != null) ...[
                        Image.asset(
                          item.iconPath!,
                          width: 20,
                          height: 20,
                          color: AppColors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Title
                      SizedBox(
                        width: 100, // Fixed width for titles to keep values aligned
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Value Part
                      Expanded(
                        child: item.customValue ??
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (item.isVerified) ...[
                                  _buildVerifiedBadge(),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Text(
                                    item.value,
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.white.withOpacity(0.3),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.info.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.check_circle,
            color: AppColors.info,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            "Verified",
            style: TextStyle(
              color: AppColors.info,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(BuildContext context, ProfileInfoItem item) {
    if (!item.canExpand) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.value,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  BorderRadius _getBorderRadius(int index, int total) {
    if (total == 1) return BorderRadius.circular(16);
    if (index == 0) return const BorderRadius.vertical(top: Radius.circular(16));
    if (index == total - 1) return const BorderRadius.vertical(bottom: Radius.circular(16));
    return BorderRadius.zero;
  }
}
