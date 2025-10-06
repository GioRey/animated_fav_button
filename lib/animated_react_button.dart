library animated_fav_button;

import 'dart:math' as math;

import 'package:animated_fav_button/canvas/painter.dart';
import 'package:animated_fav_button/model/bubble.dart';
import 'package:flutter/material.dart';

class AnimatedReactButton extends StatefulWidget {
  final Color defaultColor;
  final IconData defaultIcon;
  final Color reactColor;
  final Function onPressed;
  final bool showSplash;
  final double iconSize;
  final bool enableTap;
  final List<IconData> splashIcons;
  final List<Color> splashColors;
  final bool isFavorite;

  const AnimatedReactButton({
    Key? key,
    this.defaultColor = Colors.grey,
    this.defaultIcon = Icons.favorite,
    required this.reactColor,
    required this.onPressed,
    this.showSplash = true,
    this.iconSize = 35,
    this.enableTap = true,
    this.splashIcons = const [
      Icons.pets,
    ],
    this.splashColors = const [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.pink,
    ],
    this.isFavorite = false,
  }) : super(key: key);

  @override
  State<AnimatedReactButton> createState() => _AnimatedReactButtonState();
}

class _AnimatedReactButtonState extends State<AnimatedReactButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Bubble> _bubbles = [];
  final double _maxResaultant = 35.0;
  final int _maxBubbles = 15;
  final double _sizeBoundSeeder = 1.0;
  double _refDx = 0.0;
  double _refDy = 0.0;
  Color _favStatus = Colors.grey;
  bool _isLoading = false;
  final GlobalKey _widgetKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _favStatus = widget.isFavorite ? widget.reactColor : widget.defaultColor;
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
    _animation = Tween<double>(begin: 0, end: _maxResaultant).animate(curve);

    WidgetsBinding.instance.addPostFrameCallback(handleRenderBox);

    _controller.addListener(bubbleHandler);
  }

  @override
  void didUpdateWidget(AnimatedReactButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _favStatus =
            widget.isFavorite ? widget.reactColor : widget.defaultColor;
      });
    }
  }

  void handleRenderBox(timeStamp) {
    final RenderBox renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox;

    _widgetKey.currentContext?.size;
    final Size size = renderBox.size;
    _refDx = size.width / 2;
    _refDy = size.height / 2;
  }

  void bubbleHandler() {
    for (var bubble in _bubbles) {
      bubble.dx = _refDx + math.cos(bubble.angle) * _animation.value;
      bubble.dy = _refDy + math.sin(bubble.angle) * _animation.value;
    }
  }

  void generateBubbles() {
    for (int i = 0; i < _maxBubbles; i++) {
      double angle = math.Random().nextDouble() * math.pi * 2;

      // Seleccionar icono y color aleatoriamente de las listas configuradas
      IconData selectedIcon =
          widget.splashIcons[math.Random().nextInt(widget.splashIcons.length)];
      Color selectedColor = widget
          .splashColors[math.Random().nextInt(widget.splashColors.length)];

      Bubble bubble = Bubble(
          angle: angle,
          dx: _refDx + math.sin(angle) * _maxResaultant,
          dy: _refDy + math.cos(angle) * _maxResaultant,
          r: math.Random().nextDouble() * 5 +
              2, // Radio entre 2 y 7 para mejor visibilidad de iconos
          color: selectedColor,
          icon: selectedIcon);
      handleCollision(i, bubble);
      _bubbles.add(bubble);
    }
    for (var bubble in _bubbles) {
      //Initing launching pos
      bubble.dx = _refDx;
      bubble.dy = _refDy;
    }
  }

  void handleCollision(int i, Bubble bubble) {
    for (int j = 0; j < _bubbles.length; j++) {
      if (j == i) continue;
      if (distance(bubble.dx, bubble.dy, _bubbles[j].dx, _bubbles[j].dy) -
              (bubble.r + _bubbles[j].r) <
          0) {
        double angle = math.Random().nextDouble() * math.pi * 2;
        bubble.dx = _refDx + math.cos(angle) * _maxResaultant;
        bubble.dy = _refDy + math.sin(angle) * _maxResaultant;
        bubble.angle = angle;
        bubble.r = math.Random().nextDouble() * 5;
        handleCollision(i, bubble);
      }
    }
  }

  distance(x1, y1, x2, y2) {
    double xDiff = x2 - x1;
    double yDiff = y2 - y1;
    return math.sqrt(math.pow(xDiff, 2) + math.pow(yDiff, 2));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoading)
          Positioned.fill(
            child: CircularProgressIndicator(
              // strokeWidth: 2,
              color: _favStatus,
            ),
          ),
        CircleAvatar(
          radius: widget.iconSize * _sizeBoundSeeder,
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            key: _widgetKey,
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  FadeTransition(
                    opacity:
                        Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    )),
                    child: CustomPaint(
                      child: Container(),
                      foregroundPainter: ReactPainter(
                          value: _animation.value, bubbles: _bubbles),
                    ),
                  ),
                  Align(alignment: Alignment.center, child: child!)
                ],
              );
            },
            child: GestureDetector(
              onTap: widget.enableTap ? loveHandler : null,
              child: Icon(
                widget.defaultIcon,
                size: widget.iconSize,
                color: _favStatus,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void loveHandler() async {
    // Mostrar indicador de carga
    setState(() {
      _isLoading = true;
    });

    // Ejecutar la función onPressed (puede incluir llamadas a API)
    await widget.onPressed();

    // El color se actualiza basado en el nuevo estado de isFavorite
    // (el padre debe actualizar isFavorite y el widget se re-renderizará)
    setState(() {
      _isLoading = false; // Ocultar indicador de carga antes de las burbujas
    });

    // Mostrar animación de burbujas solo si se está marcando como favorito
    if (widget.showSplash && !widget.isFavorite) {
      if (_bubbles.isEmpty) {
        generateBubbles();
      }
      if (_controller.status == AnimationStatus.completed) {
        _controller.reset();
      }
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
