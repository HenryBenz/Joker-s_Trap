import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Draws an ornate PNG behind [child], keeping the child inside the velvet.
///
/// Insets are fractions of the frame. When the parent gives a tight size
/// (rule panels, result card) the frame fills that size. Otherwise the frame
/// grows with the child so titles and buttons are not painted on the gold.
class OrnateFrame extends StatefulWidget {
  const OrnateFrame({
    super.key,
    required this.asset,
    required this.child,
    this.left = 0.13,
    this.top = 0.24,
    this.right = 0.13,
    this.bottom = 0.26,
    this.highlight,
  });

  final String asset;
  final Widget child;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final Color? highlight;

  @override
  State<OrnateFrame> createState() => _OrnateFrameState();
}

class _OrnateFrameState extends State<OrnateFrame> {
  ImageStream? _stream;
  ImageInfo? _info;
  late final ImageStreamListener _listener = ImageStreamListener((info, _) {
    if (!mounted) {
      info.dispose();
      return;
    }
    final previous = _info;
    setState(() => _info = info);
    previous?.dispose();
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve(widget.asset);
  }

  @override
  void didUpdateWidget(OrnateFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve(widget.asset);
  }

  void _resolve(String asset) {
    final stream = AssetImage(asset).resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _info = null;
    _stream = stream;
    stream.addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _info?.dispose();
    _info = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OrnateFrameBox(
      left: widget.left,
      top: widget.top,
      right: widget.right,
      bottom: widget.bottom,
      image: _info?.image,
      highlight: widget.highlight,
      child: widget.child,
    );
  }
}

class _OrnateFrameBox extends SingleChildRenderObjectWidget {
  const _OrnateFrameBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.image,
    required this.highlight,
    required super.child,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
  final ui.Image? image;
  final Color? highlight;

  @override
  RenderOrnateFrame createRenderObject(BuildContext context) {
    return RenderOrnateFrame(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      image: image,
      highlight: highlight,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderOrnateFrame renderObject) {
    renderObject
      ..left = left
      ..top = top
      ..right = right
      ..bottom = bottom
      ..image = image
      ..highlight = highlight;
  }
}

class RenderOrnateFrame extends RenderShiftedBox {
  RenderOrnateFrame({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required ui.Image? image,
    required Color? highlight,
  }) : _left = left,
       _top = top,
       _right = right,
       _bottom = bottom,
       _image = image,
       _highlight = highlight,
       super(null);

  double _left;
  double _top;
  double _right;
  double _bottom;
  ui.Image? _image;
  Color? _highlight;

  double get left => _left;
  set left(double value) {
    if (_left == value) return;
    _left = value;
    markNeedsLayout();
  }

  double get top => _top;
  set top(double value) {
    if (_top == value) return;
    _top = value;
    markNeedsLayout();
  }

  double get right => _right;
  set right(double value) {
    if (_right == value) return;
    _right = value;
    markNeedsLayout();
  }

  double get bottom => _bottom;
  set bottom(double value) {
    if (_bottom == value) return;
    _bottom = value;
    markNeedsLayout();
  }

  ui.Image? get image => _image;
  set image(ui.Image? value) {
    if (_image == value) return;
    _image = value;
    markNeedsPaint();
  }

  Color? get highlight => _highlight;
  set highlight(Color? value) {
    if (_highlight == value) return;
    _highlight = value;
    markNeedsPaint();
  }

  double get _innerHeightFactor => (1 - _top - _bottom).clamp(0.25, 1.0);

  @override
  void performLayout() {
    final child = this.child;
    final tight = constraints.hasTightWidth && constraints.hasTightHeight;
    if (tight) {
      size = constraints.smallest;
      if (child != null) {
        final inner = Size(
          math.max(0, size.width * (1 - _left - _right)),
          math.max(0, size.height * _innerHeightFactor),
        );
        child.layout(BoxConstraints.tight(inner));
        (child.parentData! as BoxParentData).offset = Offset(size.width * _left, size.height * _top);
      }
      return;
    }

    final frameW = constraints.constrainWidth(
      constraints.maxWidth.isFinite ? constraints.maxWidth : 400,
    );
    final innerW = math.max(0.0, frameW * (1 - _left - _right));
    if (child == null) {
      size = constraints.constrain(Size(frameW, constraints.minHeight));
      return;
    }
    child.layout(
      BoxConstraints(minWidth: innerW, maxWidth: innerW),
      parentUsesSize: true,
    );
    var frameH = child.size.height / _innerHeightFactor;
    final maxH = constraints.maxHeight;
    if (maxH.isFinite && frameH > maxH) frameH = maxH;
    size = constraints.constrain(Size(frameW, frameH));
    (child.parentData! as BoxParentData).offset = Offset(size.width * _left, size.height * _top);
  }

  Rect _innerRect(Offset offset) {
    return Rect.fromLTWH(
      offset.dx + size.width * _left,
      offset.dy + size.height * _top,
      math.max(0, size.width * (1 - _left - _right)),
      math.max(0, size.height * _innerHeightFactor),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final rect = offset & size;
    final image = _image;
    if (image != null) {
      paintImage(
        canvas: context.canvas,
        rect: rect,
        image: image,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
      );
    } else {
      context.canvas.drawRect(rect, Paint()..color = const Color(0xFF2A0845));
    }
    final highlight = _highlight;
    if (highlight != null) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(_innerRect(offset), const Radius.circular(16)),
        Paint()..color = highlight,
      );
    }
    context.pushClipRect(needsCompositing, offset, _innerRect(Offset.zero), super.paint);
  }
}
