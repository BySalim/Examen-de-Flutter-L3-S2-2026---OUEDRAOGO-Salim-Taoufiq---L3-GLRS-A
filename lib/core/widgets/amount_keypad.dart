import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AmountKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const AmountKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
  });

  static const List<String> _keys = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '', '0', '<',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.9,
      children: _keys.map((key) {
        if (key.isEmpty) return const SizedBox.shrink();
        final isDelete = key == '<';
        return _KeypadButton(
          onTap: () => isDelete ? onDelete() : onDigit(key),
          child: isDelete
              ? const Icon(Icons.backspace_outlined,
                  color: AppColors.textPrimary)
              : Text(
                  key,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _KeypadButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 46,
        child: Center(child: child),
      ),
    );
  }
}
