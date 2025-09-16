import 'package:flutter/material.dart';
import '../../../../core/consts/color_manager.dart';

class IsolatedCommentInput extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback? onFocusChange;

  const IsolatedCommentInput({
    Key? key,
    required this.onSubmit,
    this.onFocusChange,
  }) : super(key: key);

  @override
  State<IsolatedCommentInput> createState() => _IsolatedCommentInputState();
}

class _IsolatedCommentInputState extends State<IsolatedCommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    if (mounted && _controller.text != _currentText) {
      setState(() {
        _currentText = _controller.text;
      });
    }
  }

  void _onFocusChanged() {
    if (mounted && widget.onFocusChange != null) {
      widget.onFocusChange!();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E3F),
        border: Border(
          top: BorderSide(
            color: Color(0xFF333366),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A4A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF444466),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(
                    color: Color(0xFF888899),
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(
                      color: Color(0xFF6C5CE7),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  filled: false,
                ),
                style: const TextStyle(
                  color: Color(0xFFE1E3E6),
                  fontSize: 15,
                  height: 1.4,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: _currentText.trim().isNotEmpty
                  ? const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _currentText.trim().isEmpty
                  ? const Color(0xFF2A2A4A)
                  : null,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _currentText.trim().isNotEmpty
                  ? [
                      const BoxShadow(
                        color: Color(0x4D6C5CE7),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              onPressed: _currentText.trim().isEmpty ? null : _handleSubmit,
              icon: Icon(
                Icons.send_rounded,
                color: _currentText.trim().isNotEmpty
                    ? const Color(0xFFE1E3E6)
                    : const Color(0xFF888899),
              ),
              iconSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}