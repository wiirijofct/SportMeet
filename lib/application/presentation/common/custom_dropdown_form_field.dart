import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemToString;
  final InputDecoration? decoration;
  final double dropdownMaxHeight;
  final String? errorText;

  const SearchableDropdown({
    Key? key,
    required this.items,
    this.value,
    required this.onChanged,
    required this.itemToString,
    this.decoration,
    this.dropdownMaxHeight = 200.0,
    this.errorText,
  }) : super(key: key);

  @override
  _SearchableDropdownState<T> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  late List<T> filteredItems;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;

    // Set initial value for the search field
    if (widget.value != null) {
      _controller.text = widget.itemToString(widget.value!);
    }

    _controller.addListener(() {
      setState(() {
        filteredItems = widget.items
            .where((item) => widget.itemToString(item)
                .toLowerCase()
                .contains(_controller.text.toLowerCase()))
            .toList();
        if (_isOpen) {
          _overlayEntry?.remove();
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry!);
        }
      });
    });
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() {
      _isOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _closeDropdown,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Positioned(
                width: size.width,
                left: offset.dx,
                top: offset.dy + size.height + 5.0,
                child: Material(
                  elevation: 2,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight),
                    child: ListView(
                      shrinkWrap: true,
                      children: filteredItems.map((item) {
                        return ListTile(
                          title: Text(widget.itemToString(item)),
                          onTap: () {
                            widget.onChanged(item);
                            _controller.text = widget.itemToString(item);
                            _closeDropdown();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: widget.decoration?.copyWith(
          errorText: widget.errorText,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      filteredItems = widget.items;
                    });
                    _openDropdown();
                    _focusNode.requestFocus();
                  },
                ),
              IconButton(
                icon: Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                onPressed: _toggleDropdown,
              ),
            ],
          ),
        ),
        onTap: _toggleDropdown,
      ),
    );
  }
}