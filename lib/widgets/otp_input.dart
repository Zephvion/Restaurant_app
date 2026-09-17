import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// A row of [length] single-digit boxes for OTP entry, matching the Figma
/// "Verify OTP!" screen. Auto-advances focus on input and steps back on
/// delete. Reports the full code via [onChanged] and [onCompleted].
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 4,
    this.value,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final String? value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    if (widget.value != null && widget.value!.isNotEmpty) {
      _applyValue(widget.value!);
    }
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != oldWidget.value && widget.value != _code) {
      _applyValue(widget.value!);
    }
  }

  void _applyValue(String val) {
    final chars = val.split('');
    for (int i = 0; i < widget.length; i++) {
      if (i < chars.length) {
        _controllers[i].text = chars[i];
      } else {
        _controllers[i].clear();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _handleChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
    final code = _code;
    widget.onChanged?.call(code);
    if (code.length == widget.length && !code.contains(RegExp(r'\s')) &&
        _controllers.every((c) => c.text.isNotEmpty)) {
      widget.onCompleted?.call(code);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == widget.length - 1 ? 0 : 16),
          child: _OtpBox(
            controller: _controllers[index],
            focusNode: _nodes[index],
            onChanged: (v) => _handleChanged(index, v),
            onBackspaceOnEmpty: () {
              if (index > 0) {
                _nodes[index - 1].requestFocus();
                _controllers[index - 1].clear();
                widget.onChanged?.call(_code);
              }
            },
          ),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspaceOnEmpty,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspaceOnEmpty;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  // Owns the raw-key listener node so it can be disposed properly.
  final FocusNode _rawKeyNode = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _rawKeyNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 78,
      child: KeyboardListener(
        focusNode: _rawKeyNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              widget.controller.text.isEmpty) {
            widget.onBackspaceOnEmpty();
          }
        },
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: AppColors.copper,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(color: AppColors.copper.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color color = Colors.transparent}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.otpBox),
      borderSide: BorderSide(color: color, width: 1.4),
    );
  }
}
