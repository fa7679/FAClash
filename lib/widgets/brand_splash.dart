import 'package:flutter/material.dart';

/// 品牌启动门：原生启动屏之后的第一帧品牌画面。
/// 渐变底 + 白色闪电 +「星火，也可以燎原」，淡入停留后淡出交给主页。
class BrandSplashGate extends StatefulWidget {
  const BrandSplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<BrandSplashGate> createState() => _BrandSplashGateState();
}

class _BrandSplashGateState extends State<BrandSplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.14, curve: Curves.easeOut),
  );

  late final Animation<double> _fadeOut = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.72, 1, curve: Curves.easeInOut),
  );

  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _done = true);
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_done)
          FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.0).animate(_fadeOut),
            child: _BrandSplash(fadeIn: _fadeIn),
          ),
      ],
    );
  }
}

class _BrandSplash extends StatelessWidget {
  const _BrandSplash({required this.fadeIn});

  final Animation<double> fadeIn;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width > 700;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF191C3A), Color(0xFF4331D8)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: FadeTransition(
                opacity: fadeIn,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/brand_mark.png',
                      width: wide ? 128.0 : 104.0,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(height: 30),
                    SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.16),
                        end: Offset.zero,
                      ).animate(fadeIn),
                      child: Text(
                        '星火，也可以燎原',
                        style: TextStyle(
                          fontSize: wide ? 21.0 : 18.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          letterSpacing: 3,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: FadeTransition(
                opacity: fadeIn,
                child: Text(
                  'by fa7679',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
