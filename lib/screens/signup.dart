import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login.dart';
// import 'home/home_screen.dart';

class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedValue = value.trim();

    if (!_emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }

    final lowerValue = trimmedValue.toLowerCase();
    if (lowerValue.endsWith('.con') || lowerValue.endsWith('.cim')) {
      return 'Did you mean .com?';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _onSignupPressed() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    // Use Riverpod notifier for signup
    await ref
        .read(authNotifierProvider.notifier)
        .signUp(name: name, email: email, password: pass);
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state
    final authState = ref.watch(authNotifierProvider);

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.requiresVerification && next.user != null) {
        // Show verification message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please verify your email. Check your inbox for the verification link.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'lib/images/logo.png',
                    width: 500,
                    height: 210,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          "Register to Kigali City Directory",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border(
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                          child: const Text(
                            "Join Kigali City Directory - Create your account to discover local businesses, services, and opportunities in Kigali",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                validator: _validateName,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _hidePassword,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.green.shade700,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _hideConfirmPassword,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade700,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.green.shade700,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _hideConfirmPassword =
                                          !_hideConfirmPassword,
                                    ),
                                    icon: Icon(
                                      _hideConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                                validator: _validateConfirmPassword,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      Colors.green,
                                    ),
                                  ),
                                  onPressed: authState.isLoading
                                      ? null
                                      : _onSignupPressed,
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Register",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already have an account? "),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Login(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
