import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/service_model.dart';
import '../core/constants.dart';

class AnimatedServiceCard extends StatelessWidget {
  final ServiceModel service;
  final int index;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnimatedServiceCard({
    super.key,
    required this.service,
    required this.index,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hours = service.duration ~/ 60;
    final mins = service.duration % 60;
    final durationText = hours > 0 && mins > 0
        ? '${hours}h ${mins}m'
        : hours > 0
        ? '${hours}h'
        : '${mins}m';

    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: index * 80)),
        SlideEffect(
          delay: Duration(milliseconds: index * 80),
          begin: const Offset(0.2, 0),
          end: Offset.zero,
          duration: 350.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Image ─────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImage(),
              ),

              const SizedBox(width: 12),

              // ── Text block ────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sub-category (grey small)
                    Text(
                      service.subCategory,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Service name (bold)
                    Text(
                      service.serviceName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // ✅ Bottom row: clock + duration + spacer + edit + delete
                    Row(
                      children: [
                        // Orange clock icon
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFFFF9800),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        // Duration text
                        Text(
                          durationText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(),

                        // ✅ Edit icon — horizontal with delete
                        GestureDetector(
                          onTap: onEdit,
                          child: Icon(
                            Icons.border_color,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 14),

                        // ✅ Delete icon
                        GestureDetector(
                          onTap: onDelete,
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final isValidUrl = service.imageUrl != null &&
        service.imageUrl!.isNotEmpty &&
        service.imageUrl!.startsWith('https://res.cloudinary');

    if (isValidUrl) {
      return CachedNetworkImage(
        imageUrl: service.imageUrl!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        placeholder: (_, __) => _fallback(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.home_repair_service_outlined,
        color: AppConstants.primaryColor,
        size: 30,
      ),
    );
  }
}
