import 'package:flutter/widgets.dart';

/// 品牌启动门：原生启动屏之后的第一帧品牌画面。
/// 全屏品牌原画（星空闪电 · fa7679 作），淡入停留后淡出交给主页。
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

/// 品牌原画铺屏（横竖两版均为 fa7679 原稿）。竖版底部对齐——上缘留白星空可裁，
/// 山脊线、文案与署名都在下缘必须保留；横版居中铺满。
class _BrandSplash extends StatelessWidget {
  const _BrandSplash({required this.fadeIn});

  final Animation<double> fadeIn;

  static const _fallback = Color(0xFF091152);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width > size.height;
    return DecoratedBox(
      decoration: const BoxDecoration(color: _fallback),
      child: FadeTransition(
        opacity: fadeIn,
        child: Image.asset(
          landscape
              ? 'assets/images/splash_art_landscape.jpg'
              : 'assets/images/splash_art.jpg',
          fit: BoxFit.cover,
          alignment: landscape ? Alignment.center : Alignment.bottomCenter,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
