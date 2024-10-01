import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// A highly customizable tooltip widget for Flutter applications.
///
/// This widget wraps a child widget and displays a tooltip when the child is
/// hovered over (on desktop/web) or tapped (on mobile). The tooltip can be
/// customized in terms of appearance, timing, and content.
///
/// The tooltip automatically adjusts its position to stay within the screen bounds.
class CustomTooltip extends StatefulWidget {
  /// The widget that will trigger the tooltip when interacted with.
  final Widget child;

  /// The content of the tooltip. Can be any widget, allowing for rich tooltip content.
  final Widget tooltip;

  /// The width of the tooltip. If null, the tooltip will size itself to fit its content.
  final double? tooltipWidth;

  /// The height of the tooltip. If null, the tooltip will size itself to fit its content.
  final double? tooltipHeight;

  /// The background color of the tooltip.
  ///
  /// This is ignored if [decoration] is provided.
  final Color backgroundColor;

  /// The border radius of the tooltip.
  ///
  /// This is ignored if [decoration] is provided.
  final double borderRadius;

  /// The padding inside the tooltip.
  final EdgeInsetsGeometry padding;

  /// The elevation of the tooltip, controlling the size of the shadow.
  final double elevation;

  /// The delay before the tooltip is shown when hovering.
  ///
  /// This is only applicable for desktop and web platforms.
  final Duration hoverShowDelay;

  /// The duration of the show animation.
  final Duration showDuration;

  /// The duration of the hide animation.
  final Duration hideDuration;

  /// Custom decoration for the tooltip.
  ///
  /// If provided, this overrides [backgroundColor] and [borderRadius].
  final BoxDecoration? decoration;

  /// The text style for the tooltip content.
  ///
  /// This is applied to all text widgets inside the tooltip.
  final TextStyle? textStyle;

  /// Creates a [CustomTooltip].
  ///
  /// The [child] and [tooltip] parameters must not be null.
  ///
  /// Example:
  /// ```dart
  /// CustomTooltip(
  ///   child: Icon(Icons.info),
  ///   tooltip: Text('This is an info icon'),
  ///   tooltipWidth: 200,
  ///   backgroundColor: Colors.blue,
  ///   textStyle: TextStyle(color: Colors.white),
  /// )
  /// ```
  const CustomTooltip({
    super.key,
    required this.child,
    required this.tooltip,
    this.tooltipWidth,
    this.tooltipHeight,
    this.backgroundColor = const Color.fromARGB(193, 21, 12, 87),
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(8.0),
    this.elevation = 6.0,
    this.hoverShowDelay = const Duration(milliseconds: 800),
    this.showDuration = const Duration(milliseconds: 200),
    this.hideDuration = const Duration(milliseconds: 100),
    this.decoration,
    this.textStyle = const TextStyle(
        color: Color.fromARGB(255, 139, 209, 255), fontSize: 18),
  });

  @override
  CustomTooltipState createState() => CustomTooltipState();
}

/// The state for [CustomTooltip].
///
/// This class handles the logic for showing and hiding the tooltip,
/// as well as positioning it on the screen.
class CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _showTimer;
  Timer? _hideTimer;
  bool _isTooltipVisible = false;
  bool _isTooltipPinned = false;
  bool _isGlobalRouteAdded = false;

  /// Determines if the current platform is desktop or web.
  bool get _isDesktopOrWeb {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
  }

  /// Initializes the animation controller and fade animation.
  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.showDuration,
      reverseDuration: widget.hideDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeTooltip();
    _showTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _isDesktopOrWeb ? _handleHoverStart() : null,
        onExit: (_) => _isDesktopOrWeb ? _handleHoverEnd() : null,
        child: Listener(
          onPointerDown: _handlePointerDown,
          onPointerUp: _handlePointerUp,
          behavior: HitTestBehavior.translucent,
          child: widget.child,
        ),
      ),
    );
  }

  /// Handles the start of a hover event.
  void _handleHoverStart() {
    if (!_isTooltipPinned) {
      _showTimer?.cancel();
      _hideTimer?.cancel();
      _showTimer = Timer(widget.hoverShowDelay, () {
        if (mounted && !_isTooltipVisible) {
          _showTooltip();
        }
      });
    }
  }

  /// Handles the end of a hover event.
  void _handleHoverEnd() {
    if (!_isTooltipPinned) {
      _showTimer?.cancel();
      _startHideTimer();
    }
  }

  /// Handles pointer down events.
  void _handlePointerDown(PointerDownEvent event) {
    if (_isTooltipVisible && _isTooltipPinned) {
      _hideTooltip();
    } else {
      _showTooltipImmediately();
      _pinTooltip();
    }
  }

  /// Handles pointer up events.
  void _handlePointerUp(PointerUpEvent event) {
    // This allows the tap to propagate to widgets below
  }

  /// Pins the tooltip in place.
  void _pinTooltip() {
    setState(() {
      _isTooltipPinned = true;
    });
  }

  /// Shows the tooltip immediately, canceling any pending show or hide timers.
  void _showTooltipImmediately() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _showTooltip();
  }

  /// Starts the timer to hide the tooltip.
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 500), _hideTooltip);
  }

  /// Shows the tooltip.
  void _showTooltip() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _buildTooltipOverlay(position, size, screenSize);
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    _isTooltipVisible = true;

    _addGlobalRoute();
  }

  /// Builds the tooltip overlay widget.
  Widget _buildTooltipOverlay(Offset position, Size size, Size screenSize) {
    double dx = 0;
    double dy = size.height + 5;

    // Adjust horizontal position if tooltip goes beyond right edge
    if (widget.tooltipWidth != null &&
        position.dx + widget.tooltipWidth! > screenSize.width) {
      dx = screenSize.width - position.dx - widget.tooltipWidth!;
    }

    // Adjust horizontal position if tooltip goes beyond left edge
    if (position.dx + dx < 0) {
      dx = -position.dx;
    }

    // Adjust vertical position if tooltip goes beyond bottom edge
    if (widget.tooltipHeight != null &&
        position.dy + size.height + 5 + widget.tooltipHeight! >
            screenSize.height) {
      dy = -widget.tooltipHeight! - 5;
    }

    return Positioned(
      width: widget.tooltipWidth,
      height: widget.tooltipHeight,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(dx, dy),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: widget.elevation,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Colors.transparent,
            child: Container(
              width: widget.tooltipWidth,
              height: widget.tooltipHeight,
              decoration: widget.decoration ??
                  BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
              padding: widget.padding,
              child: DefaultTextStyle(
                style:
                    widget.textStyle ?? Theme.of(context).textTheme.bodyMedium!,
                child: widget.tooltip,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Adds a global route to handle taps outside the tooltip.
  void _addGlobalRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isGlobalRouteAdded) {
        GestureBinding.instance.pointerRouter
            .addGlobalRoute(_handleGlobalPointerEvent);
        _isGlobalRouteAdded = true;
      }
    });
  }

  /// Handles global pointer events to dismiss the tooltip when tapping outside.
  void _handleGlobalPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final localPosition = renderBox.globalToLocal(event.position);
        if (!renderBox.size.contains(localPosition)) {
          _hideTooltip();
        }
      }
    }
  }

  /// Hides the tooltip.
  void _hideTooltip() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _animationController.reverse().then((_) {
      _removeTooltip();
    });
    setState(() {
      _isTooltipPinned = false;
    });
  }

  /// Removes the tooltip overlay and cleans up resources.
  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isTooltipVisible = false;
    if (_isGlobalRouteAdded) {
      GestureBinding.instance.pointerRouter
          .removeGlobalRoute(_handleGlobalPointerEvent);
      _isGlobalRouteAdded = false;
    }
  }
}
