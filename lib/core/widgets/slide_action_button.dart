import 'dart:async';
import 'package:flutter/material.dart';

class SlideActionButton extends StatefulWidget {
  final double width;
  final double height;
  final bool isCheckoutMode;
  final bool isEnabled;
  final bool isCheckedOut;
  final String checkInText;
  final String checkOutText;
  final VoidCallback? onSlideComplete;
  final DateTime? checkInTime;

  const SlideActionButton({
    Key? key,
    required this.width,
    required this.height,
    required this.isCheckoutMode,
    required this.isEnabled,
    required this.isCheckedOut,
    this.onSlideComplete,
    this.checkInText = 'Slide to clock in',
    this.checkOutText = 'Slide to clock out',
    this.checkInTime,
  }) : super(key: key);

  @override
  State<SlideActionButton> createState() => _SlideActionButtonState();
}

class _SlideActionButtonState extends State<SlideActionButton> {
  double _position = 0.0;
  bool _isSliding = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant SlideActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCheckoutMode && !widget.isCheckedOut) {
      _startTimerIfNeeded();
    } else {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    if (widget.isCheckoutMode && !widget.isCheckedOut && widget.checkInTime != null) {
      _stopTimer();
      _elapsedSeconds = DateTime.now().difference(widget.checkInTime!).inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Color _getBackgroundColor() {
    if (!widget.isEnabled) return Colors.grey.shade200;
    return widget.isCheckoutMode ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
  }

  Color _getBorderColor() {
    if (!widget.isEnabled) return Colors.grey;
    return widget.isCheckoutMode ? Colors.red : const Color(0xFF3CAB88);
  }

  Color _getButtonColor() {
    if (!widget.isEnabled) return Colors.grey;
    return widget.isCheckoutMode ? Colors.red : const Color(0xFF3CAB88);
  }

  // Return just a String
  String _getDisplayText() {
    if (!widget.isEnabled) {
      return widget.isCheckoutMode ? 'Checkout Disabled' : 'Check-in Disabled';
    }
    return widget.isCheckoutMode ? _formatTime(_elapsedSeconds) : widget.checkInText;
  }



  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.isEnabled || _isSliding || widget.isCheckedOut) return;
    setState(() {
      _position += details.delta.dx;
      if (_position < 0) _position = 0;
      if (_position > widget.width * 0.8) {
        _position = widget.width * 0.8;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.isEnabled || _isSliding || widget.isCheckedOut) return;
    if (_position >= widget.width * 0.7) {
      setState(() => _isSliding = true);
      widget.onSlideComplete!();
      setState(() {
        _isSliding = false;
        _position = 0;
      });
    } else {
      setState(() => _position = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: widget.width,
              height: widget.height,
              margin: const EdgeInsets.only(top: 15),
              decoration: ShapeDecoration(
                color: _getBackgroundColor(),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: _getBorderColor(),
                  ),
                  borderRadius: BorderRadius.circular(81),
                ),
              ),
              child:Center(
                child: Text(
                  _getDisplayText(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            ),
            Positioned(
              left: _position + 8,
              bottom: widget.height * 0.17,
              child: GestureDetector(
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: Container(
                  width: widget.height * 0.7,
                  height: widget.height * 0.7,
                  decoration: ShapeDecoration(
                    color: _getButtonColor(),
                    shape: const OvalBorder(),
                  ),
                  child: _isSliding
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }
} 