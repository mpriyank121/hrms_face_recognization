import 'package:flutter/material.dart';
import '../../config/font_style.dart';

class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final InputDecoration decoration;
  final String? hint;
  final bool enabled;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.decoration = const InputDecoration(),
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _removeDropdown();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    if (_isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _removeDropdown() {
    _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _showDropdown() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownHeight = widget.items.length > 6 ? 280.0 : widget.items.length * 52.0;
    final showAbove = offset.dy + size.height + dropdownHeight > screenHeight - 100;
    double leftPosition = offset.dx;
    if (leftPosition + size.width > screenWidth - 16) {
      leftPosition = screenWidth - size.width - 16;
    }
    if (leftPosition < 16) {
      leftPosition = 16;
    }
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            Positioned(
              left: leftPosition,
              width: size.width,
              top: showAbove
                  ? offset.dy - dropdownHeight - 8
                  : offset.dy + size.height + 4,
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.95 + (0.05 * _expandAnimation.value),
                    alignment: showAbove ? Alignment.bottomCenter : Alignment.topCenter,
                    child: Opacity(
                      opacity: _expandAnimation.value,
                      child: Material(
                        elevation: 8,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 280,
                                minHeight: 52,
                              ),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                shrinkWrap: true,
                                itemCount: widget.items.length,
                                itemBuilder: (context, index) {
                                  final item = widget.items[index];
                                  final isSelected = item.value == widget.value;
                                  final isFirst = index == 0;
                                  final isLast = index == widget.items.length - 1;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        widget.onChanged(item.value);
                                        _removeDropdown();
                                      },
                                      borderRadius: BorderRadius.vertical(
                                        top: isFirst ? const Radius.circular(12) : Radius.zero,
                                        bottom: isLast ? const Radius.circular(12) : Radius.zero,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue.shade50
                                              : Colors.transparent,
                                          border: index < widget.items.length - 1
                                              ? Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade100,
                                              width: 1,
                                            ),
                                          )
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: DefaultTextStyle(
                                                style: FontStyles.subHeadingStyle().copyWith(
                                                  color: isSelected
                                                      ? Colors.blue.shade700
                                                      : Colors.grey.shade800,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                                ),
                                                child: item.child,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade700,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _isDropdownOpen = true;
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    DropdownMenuItem<T>? selectedItem;
    try {
      selectedItem = widget.items.firstWhere(
        (item) => item.value == widget.value,
      );
    } catch (e) {
      selectedItem = null;
    }
    final bool hasValue = widget.value != null && selectedItem != null;
    final String displayText = hasValue
        ? ''
        : widget.hint ?? widget.decoration.hintText ?? 'Select an option';
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AbsorbPointer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,
            ),
            child: InputDecorator(
              decoration: widget.decoration.copyWith(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                suffixIcon: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 6.28,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: widget.enabled
                            ? (_isDropdownOpen ? Colors.grey.shade600 : Colors.grey.shade600)
                            : Colors.grey.shade400,
                        size: 24,
                      ),
                    );
                  },
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: hasValue
                        ? DefaultTextStyle(
                            style: FontStyles.subHeadingStyle().copyWith(
                              color: widget.enabled
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                            child: selectedItem.child,
                          )
                        : Text(
                            displayText,
                            style: FontStyles.subHeadingStyle().copyWith(
                              color: widget.enabled
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}