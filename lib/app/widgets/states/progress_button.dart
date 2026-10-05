import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../app_primary_button.dart';

/// Button that shows a spinner, then a short tick, without changing size.
class ProgressButton extends StatefulWidget {
  const ProgressButton({
    required this.label,
    required this.onPressed,
    this.busyLabel,
    this.onSuccess,
    super.key,
  });

  final String label;
  final String? busyLabel;
  final Future<bool> Function()? onPressed;
  final VoidCallback? onSuccess;

  @override
  State<ProgressButton> createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton> {
  var _busy = false;
  var _done = false;

  Future<void> _run() async {
    if (_busy || widget.onPressed == null) {
      return;
    }
    setState(() {
      _busy = true;
      _done = false;
    });
    var ok = false;
    try {
      ok = await widget.onPressed!();
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _done = ok;
        });
      }
    }
    if (!ok || !mounted) {
      return;
    }
    await Future<void>.delayed(AppMotion.standard);
    if (!mounted) {
      return;
    }
    setState(() => _done = false);
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final label = _done
        ? 'Done'
        : _busy
            ? (widget.busyLabel ?? widget.label)
            : widget.label;
    return AppPrimaryButton(
      label: label,
      loading: _busy,
      showCheck: _done,
      onPressed: widget.onPressed == null || _busy ? null : _run,
    );
  }
}
