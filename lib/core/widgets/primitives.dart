part of '../../app/app.dart';

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _lineColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF231C10).withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    this.icon,
    this.leading,
    required this.color,
    required this.background,
  }) : assert(icon != null || leading != null);

  final String label;
  final IconData? icon;
  final Widget? leading;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading ?? Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextSearchField extends StatelessWidget {
  const _ContextSearchField({
    required this.hintText,
    required this.accent,
    this.controller,
    this.enabled = true,
    this.maxWidth = 620,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onSearch,
  });

  final TextEditingController? controller;
  final String hintText;
  final Color accent;
  final bool enabled;
  final double maxWidth;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFDDE7E2)),
          boxShadow: [
            BoxShadow(
              color: _deepTealColor.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 4),
              child: Icon(Icons.search_rounded, color: accent, size: 19),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.search,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: const TextStyle(fontSize: 13, color: _inkColor),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF9BA8A1),
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            _ContextSearchActions(
              controller: controller,
              enabled: enabled,
              onClear: onClear,
              onSearch: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextSearchActions extends StatelessWidget {
  const _ContextSearchActions({
    required this.controller,
    required this.enabled,
    required this.onClear,
    required this.onSearch,
  });

  final TextEditingController? controller;
  final bool enabled;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final clearButton = controller == null || onClear == null
        ? const SizedBox(width: 38)
        : ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller!,
            builder: (context, value, child) {
              return SizedBox(
                width: 38,
                height: 40,
                child: value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: enabled ? onClear : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 38,
                          height: 40,
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              );
            },
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        clearButton,
        SizedBox(
          width: 42,
          height: 46,
          child: IconButton(
            tooltip: 'Buscar',
            onPressed: enabled ? onSearch : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            color: const Color(0xFF9B5B24),
          ),
        ),
      ],
    );
  }
}
