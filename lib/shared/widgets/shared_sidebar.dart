import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/system_provider.dart';

class SharedSidebar extends ConsumerWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> menuItems;
  final Function(int) onItemSelected;
  final Color? accentColor;

  const SharedSidebar({
    super.key,
    required this.selectedIndex,
    required this.menuItems,
    required this.onItemSelected,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemSettings = ref.watch(systemSettingsProvider).value;
    final primaryColor = accentColor ?? const Color(0xFF2B3674);

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Branding Header
          Container(
            height: 70,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                if (systemSettings?.logoUrl != null)
                  Image.network(systemSettings!.logoUrl!, height: 32, errorBuilder: (_, __, ___) => _buildDefaultLogo(primaryColor))
                else
                  _buildDefaultLogo(primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    systemSettings?.schoolName ?? 'SI Madrasah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: InkWell(
                    onTap: () {
                      onItemSelected(index);
                      if (MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                          ? Border.all(color: primaryColor.withOpacity(0.1))
                          : null,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'],
                            color: isSelected ? primaryColor : Colors.grey.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              item['title'],
                              style: TextStyle(
                                color: isSelected ? primaryColor : Colors.grey.shade600,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // App Name Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              systemSettings?.appName ?? 'Selamat Datang',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo(Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.school, color: Colors.white, size: 20),
    );
  }
}
