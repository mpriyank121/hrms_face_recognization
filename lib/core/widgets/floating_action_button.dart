import 'package:flutter/material.dart';

class FloatingActionButtonWithMenu extends StatefulWidget {
  final void Function(String)? onMenuItemSelected;
  final List<MenuItem> menuItems;
  final IconData fabIcon;

  const FloatingActionButtonWithMenu({
    Key? key,
    this.onMenuItemSelected,
    this.fabIcon = Icons.add,

    required this.menuItems,
  }) : super(key: key);

  @override
  _FloatingActionButtonWithMenuState createState() =>
      _FloatingActionButtonWithMenuState();
}

class MenuItem {
  final IconData icon;
  final String text;
  final String value;

  MenuItem({
    required this.icon,
    required this.text,
    required this.value,
  });
}

class _FloatingActionButtonWithMenuState
    extends State<FloatingActionButtonWithMenu> {
  final GlobalKey _fabKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _showCustomMenu() {
    final RenderBox renderBox =
    _fabKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double menuHeight =
        widget.menuItems.length * 50.0 + 16; // height per item + padding
    final double menuWidth = 180;

    bool showAbove = offset.dy > menuHeight + 20;

    double leftPosition = offset.dx;

    if (leftPosition + menuWidth > screenWidth) {
      leftPosition = offset.dx + size.width - menuWidth;
    }

    if (leftPosition < 16) {
      leftPosition = 16;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black54,
            ),
          ),
          Positioned(
            left: leftPosition,
            top: showAbove
                ? offset.dy - menuHeight - 8
                : offset.dy + size.height + 8,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: menuWidth,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.menuItems.map((item) {
                    return _buildMenuItem(
                      icon: item.icon,
                      text: item.text,
                      value: item.value,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required String value,
  }) {
    return InkWell(
      onTap: () {
        widget.onMenuItemSelected?.call(value);
        _removeOverlay();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: _fabKey,
      onPressed: _showCustomMenu,
      child: Icon(widget.fabIcon),
      backgroundColor: Colors.deepOrange,
    );
  }
}
