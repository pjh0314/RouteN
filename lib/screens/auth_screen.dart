import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:route_n_firebase/screens/home_screen.dart';

//import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; //variable for managing loading status
  bool _isPasswordVisible = false; // variable for password visibility
  String? _errorMessage; // variable for store error message

  @override
  void dispose() {
    // clear controller for preventing leak of memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // helper function for wrapping auth-related operation
  Future<void> _authenticate(
    Future<UserCredential> Function() authFunction,
  ) async {
    setState(() {
      _isLoading = true; // loading start
      _errorMessage = null; // clear prev error message
    });

    try {
      UserCredential userCredential = await authFunction();
      debugPrint('Authentication Success: ${userCredential.user?.email}');
      // After certification move to Searchscreen
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(), // move to HomeScreen
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Firebase Authentication Exceptions
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'email-already-in-use':
          message = 'Email Already In Use';
          break;
        case 'user-not-found':
          message = 'User Not Found';
          break;
        case 'wrong-password':
          message = 'Wrong Password';
          break;
        case 'invalid-email':
          message = 'Invalid Email';
          break;
        default:
          message = 'Certification Error: ${e.message}';
          break;
      }
      setState(() {
        _errorMessage = message;
      });
      debugPrint('Authentication Failed: ${e.code} - ${e.message}');
    } catch (e) {
      // Unknown Error
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unkown Error: ${e.toString()}';
      });
      debugPrint('Authentication Failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Finish Loading
        });
      }
    }
  }

  Future<void> _signUp() async {
    await _authenticate(
      () => FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  Future<void> _signIn() async {
    await _authenticate(
      () => FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteN Authentication'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        foregroundColor: Colors.white,
      ),
      body: Center(
        // Add Widet for center alignment
        child: SingleChildScrollView(
          // Prevent overflow when move on to keyboard
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to RouteN!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    // Add visibility of Password toggle
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible, // obscure password
              ),
              const SizedBox(height: 30),
              // when isLoading show CircularProgressIndicator
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _signUp,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              // Error Message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
