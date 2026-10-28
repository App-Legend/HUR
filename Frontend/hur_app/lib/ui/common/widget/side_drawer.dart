import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/ui/pages/info/info_pages.dart';
import 'package:hur_app/ui/pages/library/blocked_page.dart';
import 'package:hur_app/ui/pages/library/history_page.dart';
import 'package:hur_app/ui/pages/library/product_list_page.dart';
import 'package:hur_app/ui/pages/profile/settings/settings_page.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: HurColors.panel,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _DrawerGroup(
              items: [
                _DrawerItem(
                  icon: Icons.eco_outlined,
                  label: '커뮤니티 가이드라인',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CommunityGuidelinesPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DrawerGroup(
              items: [
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  label: '내 화장품',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListPage(
                        title: '내 화장품',
                        path: '/products/marks/me?kind=own',
                        emptyText: '아직 담은 화장품이 없어요.\n화장품 옆 ... 메뉴에서 담아보세요.',
                        requiresLogin: true,
                      ),
                    ),
                  ),
                ),
                _DrawerItem(
                  icon: Icons.star_border,
                  label: '찜한 화장품',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListPage(
                        title: '찜한 화장품',
                        path: '/products/marks/me?kind=wish',
                        emptyText: '아직 찜한 화장품이 없어요.\n화장품 옆 ... 메뉴에서 찜해보세요.',
                        requiresLogin: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DrawerGroup(
              items: [
                _DrawerItem(
                  icon: Icons.history,
                  label: '조회 기록',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  ),
                ),
                _DrawerItem(
                  icon: Icons.block_outlined,
                  label: '차단됨',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BlockedPage()),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Row(
                children: [
                  _DrawerIconButton(
                    icon: Icons.headset_mic_outlined,
                    label: '고객센터',
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.push(MaterialPageRoute(builder: (_) => const SupportPage()));
                    },
                  ),
                  const SizedBox(width: 24),
                  _DrawerIconButton(
                    icon: Icons.settings_outlined,
                    label: '설정',
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.push(MaterialPageRoute(builder: (_) => const SettingsPage()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerGroup extends StatelessWidget {
  final List<Widget> items;
  const _DrawerGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: HurColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HurColors.line),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            return Column(
              children: [
                items[i],
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: HurColors.line,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: HurColors.muted, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, color: HurColors.text),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

class _DrawerIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: HurColors.surfaceStrong,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: HurColors.muted, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: HurColors.muted),
          ),
        ],
      ),
    );
  }
}
