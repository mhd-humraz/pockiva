
import 'package:flutter/material.dart';

class PockivaSplashScreen extends StatelessWidget {
  final Widget nextScreen;

  const PockivaSplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  Widget build(BuildContext context) {
    return _SplashGate(nextScreen: nextScreen);
  }
}

class _SplashGate extends StatefulWidget {
  final Widget nextScreen;

  const _SplashGate({required this.nextScreen});

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF063B2C);
    const accent = Color(0xFF9BEA69);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Logo1.png',
                width: 112,
                height: 112,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 24),

              const Text(
                'Pockiva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'Set a Goal. Make it Happen.',
                style: TextStyle(
                  color: Color(0xFFD4E5DB),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 36),

              Container(
                width: 42,
                height: 3,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Text(
            'TARGET  •  SAVE  •  ACHIEVE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9BEA69),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
