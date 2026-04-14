import 'package:flutter/material.dart';

class RepairWorkflowStepper extends StatelessWidget {
  const RepairWorkflowStepper({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _labels = ['Repair assigned', 'Fixing', 'Quality check'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Outer row must top-align columns: different label lengths/heights were
    // vertically centering each column and breaking connector alignment.
    const trackHeight = 32.0;
    const circleSize = 28.0;
    const lineThickness = 4.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final active = i <= currentIndex;
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: trackHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Center(
                          child: Container(
                            height: lineThickness,
                            color: i <= currentIndex
                                ? cs.primary
                                : cs.outline.withValues(alpha: 0.30),
                          ),
                        ),
                      ),
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        color: active ? cs.primary : cs.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active ? cs.primary : cs.outline.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        i < currentIndex ? Icons.check : Icons.circle,
                        size: i < currentIndex ? 16 : 10,
                        color: active ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
                    ),
                    if (i < _labels.length - 1)
                      Expanded(
                        child: Center(
                          child: Container(
                            height: lineThickness,
                            color: i < currentIndex
                                ? cs.primary
                                : cs.outline.withValues(alpha: 0.30),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _labels[i].toUpperCase(),
                style: tt.labelSmall?.copyWith(
                  color: active ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}
