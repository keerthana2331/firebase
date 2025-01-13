import 'package:fire_base/login_page.dart';
import 'package:fire_base/signup.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _particleController;
  bool _isHoveringLogin = false;
  bool _isHoveringSignup = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
     appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
  automaticallyImplyLeading: false,  // Add this line
),
      body: Stack(
        children: [
          // Dynamic Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Animated gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          HSVColor.fromAHSV(
                            1.0,
                            360 * _controller.value,
                            0.7,
                            0.9,
                          ).toColor(),
                          HSVColor.fromAHSV(
                            1.0,
                            360 * (_controller.value + 0.3) % 360,
                            0.8,
                            0.8,
                          ).toColor(),
                          HSVColor.fromAHSV(
                            1.0,
                            360 * (_controller.value + 0.6) % 360,
                            0.7,
                            0.9,
                          ).toColor(),
                        ],
                      ),
                    ),
                  ),
                  // Animated particle effect
                  CustomPaint(
                    painter: ParticleEffectPainter(
                      animation: _particleController.value,
                      particleColor: Colors.white.withOpacity(0.3),
                    ),
                    size: Size.infinite,
                  ),
                  // Animated wave overlay
                  CustomPaint(
                    painter: WaveOverlayPainter(
                      animation: _controller.value,
                      waveColor: Colors.white.withOpacity(0.1),
                    ),
                    size: Size.infinite,
                  ),
                  // Glowing orbs effect
                  ...List.generate(5, (index) {
                    final random = math.Random(index);
                    return Positioned(
                      left: MediaQuery.of(context).size.width * random.nextDouble(),
                      top: MediaQuery.of(context).size.height * random.nextDouble(),
                      child: AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          final scale = 0.5 + 0.5 * math.sin(
                            _particleController.value * math.pi * 2 +
                                index * math.pi / 2,
                          );
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        4 * math.sin(_controller.value * math.pi * 2),
                      ),
                      child: Transform.rotate(
                        angle: 0.05 * math.sin(_controller.value * math.pi * 2),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 60,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Welcome Text
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Colors.black38,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Please log in or sign up to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1,
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Buttons
                _buildEnhancedButton(
                  context,
                  label: 'LOGIN',
                  icon: Icons.login_rounded,
                  gradient: [Colors.blue.shade400, Colors.blue.shade600],
                  isHovering: _isHoveringLogin,
                  onHoverChanged: (value) => setState(() => _isHoveringLogin = value),
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 20),
                _buildEnhancedButton(
                  context,
                  label: 'SIGN UP',
                  icon: Icons.person_add_rounded,
                  gradient: [Colors.teal.shade300, Colors.teal.shade500],
                  isHovering: _isHoveringSignup,
                  onHoverChanged: (value) => setState(() => _isHoveringSignup = value),
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required bool isHovering,
    required Function(bool) onHoverChanged,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isHovering ? 240 : 220,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withOpacity(0.4),
                blurRadius: isHovering ? 15 : 10,
                offset: Offset(0, isHovering ? 6 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticleEffectPainter extends CustomPainter {
  final double animation;
  final Color particleColor;

  ParticleEffectPainter({
    required this.animation,
    required this.particleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = particleColor
      ..style = PaintingStyle.fill;

    final particleCount = 50;
    final random = math.Random(42);

    for (var i = 0; i < particleCount; i++) {
      final x = size.width * (random.nextDouble() + animation) % size.width;
      final y = size.height * (random.nextDouble() + animation) % size.height;
      final radius = 2.0 + random.nextDouble() * 3.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) =>
      animation != oldDelegate.animation;
}

class WaveOverlayPainter extends CustomPainter {
  final double animation;
  final Color waveColor;

  WaveOverlayPainter({
    required this.animation,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final waveCount = 3;
    final heightFactor = size.height / 10;

    for (var i = 0; i < waveCount; i++) {
      final phase = animation * math.pi * 2 + (i * math.pi / waveCount);
      path.moveTo(0, size.height / 2);

      for (var x = 0.0; x <= size.width; x += 5) {
        final y = size.height / 2 +
            math.sin(x / 50 + phase) * heightFactor +
            math.cos(x / 30 + phase) * heightFactor;
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveOverlayPainter oldDelegate) =>
      animation != oldDelegate.animation;
}