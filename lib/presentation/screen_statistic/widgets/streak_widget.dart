import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/my_animated_card.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/wave_shimmer_overlay.dart';

class StreakWidget extends StatelessWidget {
  final int streakCount;

  const StreakWidget({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color cardColor = colorScheme.surface.withValues(alpha: 0.92);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: MyAnimatedCard(
        intensity: 0.002,
        child: Card(
          elevation: 6,
          color: cardColor,
          shadowColor: Colors.black.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.black12, width: 0.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: WaveShimmerOverlay(
            id: 'stat_streak',
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('streak: '),
                    Text(
                      streakCount.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
