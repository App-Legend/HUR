//  ————————————————————————————————
//  |        구매하기 링크 팝업       |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

class PurchasePopup extends StatelessWidget {
  const PurchasePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: HurColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '구매하기',
                  style: TextStyle(
                    color: HurColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 8),

                const Text(
                  '파워링크',
                  style: TextStyle(
                    color: HurColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: HurColors.muted,
                    size: 26,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: HurColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: HurColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          '네이버',
                          style: TextStyle(
                            color: HurColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: HurColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: HurColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          '쿠팡',
                          style: TextStyle(
                            color: HurColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
