import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FilterTestWidget extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const FilterTestWidget({
    super.key,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: isActive
              ? ColorFilter.mode(
                  Colors.orange.withOpacity(0.3),
                  BlendMode.overlay,
                )
              : const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.srcOver,
                ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(AppTheme.glassOpacity),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Preview area
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      isActive ? 'Ilg\' filtr aktiv' : 'Normal ekran',
                      style: TextStyle(
                        color: isActive ? Colors.orange : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Toggle button
                ElevatedButton.icon(
                  onPressed: () => onToggle(!isActive),
                  icon: Icon(isActive ? Icons.visibility_off : Icons.visibility),
                  label: Text(isActive ? 'Filtrni o\'chirish' : 'Filtrni yoqish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isActive ? AppTheme.warningColor : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
