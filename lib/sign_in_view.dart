import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './auth.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key, required this.authService, this.onSignedIn});

  final AuthService authService;
  final ValueChanged<GoogleSignInAccount?>? onSignedIn;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isBusy = widget.authService.isSigningIn;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth > 560;
            final Widget art = _HeroArt(controller: _controller);
            final Widget panel = _SignInPanel(
              isBusy: isBusy,
              onPressed: () async {
                GoogleSignInAccount? user;
                try {
                  user = await widget.authService.signIn();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sign-in not supported here. ${e.toString()}',
                        ),
                      ),
                    );
                  }
                }
                if (!mounted) return;
                widget.onSignedIn?.call(user);
              },
            );

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: isWide
                      ? Row(
                          children: <Widget>[
                            Expanded(child: art),
                            const SizedBox(width: 32),
                            Expanded(child: panel),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            art,
                            const SizedBox(height: 32),
                            panel,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final Animation<double> fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    final Animation<double> slide = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: slide,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, slide.value),
            child: child,
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
                Theme.of(context).colorScheme.secondary.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FittedBox(
                      alignment: Alignment.bottomLeft,
                      fit: BoxFit.contain,
                      child: Text(
                        'Gym Stats',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.8),
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInPanel extends StatelessWidget {
  const _SignInPanel({required this.isBusy, required this.onPressed});

  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to add your workout entries to Google Sheets.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
            _GoogleButton(isBusy: isBusy, onPressed: onPressed),
          ],
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isBusy, required this.onPressed});

  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isBusy ? null : onPressed,
        icon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(Icons.login, color: scheme.primary, size: 20),
        ),
        label: isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Continue with Google'),
      ),
    );
  }
}
