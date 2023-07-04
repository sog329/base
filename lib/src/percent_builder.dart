import 'package:flutter/material.dart';

class PercentBuilder extends ImplicitlyAnimatedWidget {
  final double percent;
  final Widget Function(BuildContext ctx, double percent) builder;

  const PercentBuilder({
    super.key,
    required super.duration,
    required this.percent,
    required this.builder,
  });

  @override
  ImplicitlyAnimatedWidgetState<PercentBuilder> createState() => _AnimWidgetState();
}

class _AnimWidgetState extends ImplicitlyAnimatedWidgetState<PercentBuilder> {
  Tween<double>? _percent;
  late Animation<double> _animation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) => _percent =
      visitor(_percent, widget.percent, (dynamic value) => Tween<double>(begin: value as double)) as Tween<double>?;

  @override
  void didUpdateTweens() => _animation = animation.drive(_percent!);

  @override
  Widget build(BuildContext context) => PercentTransition(
        builder: widget.builder,
        percent: _animation,
      );
}

class PercentTransition extends AnimatedWidget {
  final Widget Function(BuildContext ctx, double percent) builder;
  final Animation<double> percent;

  const PercentTransition({
    super.key,
    required this.builder,
    required this.percent,
  }) : super(listenable: percent);

  @override
  Widget build(BuildContext context) => builder(context, percent.value);
}
