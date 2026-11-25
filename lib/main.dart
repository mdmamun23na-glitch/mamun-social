import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

const purple = Color(0xFF8B5CF6);
const dark = Color(0xFF09090F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MamunSocial());
}

class MamunSocial extends StatelessWidget {
  const MamunSocial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MAMUN SOCIAL',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool showPassword = false;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty ||
        (!isLogin && name.isEmpty)) {
      message('সব তথ্য পূরণ করো');
      return;
    }

    if (!email.contains('@')) {
      message('সঠিক Email Address দাও');
      return;
    }

    if (password.length < 6) {
      message('Password কমপক্ষে ৬ অক্ষরের হতে হবে');
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await result.user?.updateDisplayName(name);
      }
    } on FirebaseAuthException catch (e) {
      String error = 'কাজটি সম্পন্ন হয়নি';

      switch (e.code) {
        case 'email-already-in-use':
          error = 'এই Email দিয়ে আগে অ্যাকাউন্ট খোলা হয়েছে';
          break;
        case 'invalid-email':
          error = 'Email Address সঠিক নয়';
          break;
        case 'weak-password':
          error = 'Password আরও শক্তিশালী করো';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          error = 'Email অথবা Password ভুল';
          break;
        case 'network-request-failed':
          error = 'ইন্টারনেট সংযোগ পরীক্ষা করো';
          break;
      }

      message(error);
    } catch (e) {
      message('সমস্যা হয়েছে: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Widget inputField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool password = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: password && !showPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: purple),
          suffixIcon: password
              ? IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: purple,
                  ),
                  onPressed: () {
                    setState(() => showPassword = !showPassword);
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF171722),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [purple, Color(0xFF3B0764)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.35),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'MS',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'MAMUN SOCIAL',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect • Share • Discover',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 35),
                Text(
                  isLogin ? 'Welcome Back!' : 'Create Account',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                if (!isLogin)
                  inputField(
                    'Your Name',
                    Icons.person_outline,
                    nameController,
                  ),
                inputField(
                  'Email Address',
                  Icons.email_outlined,
                  emailController,
                ),
                inputField(
                  'Password',
                  Icons.lock_outline,
                  passwordController,
                  password: true,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            isLogin ? 'LOGIN' : 'SIGN UP',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin
                          ? "Don't have an account?"
                          : 'Already have an account?',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => isLogin = !isLogin);
                      },
                      child: Text(
                        isLogin ? 'Sign Up' : 'Login',
                        style: const TextStyle(
                          color: purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                const Text(
                  '© 2026 MAMUN SOCIAL',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1,
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MAMUN SOCIAL',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 90,
              color: purple,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to MAMUN SOCIAL!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.displayName ?? 'User'),
            const SizedBox(height: 5),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 25),
            const Text(
              'Connect • Share • Discover',
              style: TextStyle(color: purple),
            ),
          ],
        ),
      ),
    );
  }
}
