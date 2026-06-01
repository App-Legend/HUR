import 'package:flutter/material.dart';
import 'package:hur_app/ui/common/widget/category_chip.dart';

class TagSection extends StatelessWidget {
  final String title;
  final String? hint;
  final List<String> tags;
  final Set<String> selectedTags;
  final void Function(String tag) onTap;

  const TagSection({
    super.key,
    required this.title,
    this.hint,
    required this.tags,
    required this.selectedTags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
            if (hint != null) ...[
              const SizedBox(width: 8),
              Text(
                hint!,
                style: const TextStyle(fontSize: 11, color: Color(0xffaaaaaa)),
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tags.map((tag) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: CategoryChip(
                  text: tag,
                  selected: selectedTags.contains(tag),
                  onTap: () => onTap(tag),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  fontSize: 11,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
