import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final postController = TextEditingController();
  bool posting = false;

  Future<void> createPost() async {
    final caption = postController.text.trim();
    if (caption.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => posting = true);

    try {
      await FirebaseFirestore.instance.collection('Posts').add({
        'caption': caption,
        'uid': user.uid,
        'userName': user.displayName ?? 'User',
        'userEmail': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
      });

      postController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => posting = false);
    }
  }

  Future<void> toggleLike(String postId, List likes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('Posts')
        .doc(postId);

    try {
      if (likes.contains(user.uid)) {
        await ref.update({
          'likes': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        await ref.update({
          'likes': FieldValue.arrayUnion([user.uid]),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Like failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MAMUN SOCIAL',
          style: TextStyle(
            color: purple,
            fontWeight: FontWeight.bold,
          ),
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
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: purple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(user?.displayName ?? 'Welcome!'),
              subtitle: const Text('What is on your mind?'),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: purple, size: 32),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Create Post'),
                      content: TextField(
                        controller: postController,
                        maxLines: 5,
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          hintText: 'Write something...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: posting ? null : createPost,
                          child: posting
                              ? const CircularProgressIndicator()
                              : const Text('Publish'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NEWS FEED',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: purple),
                  );
                }

                final posts = snapshot.data?.docs ?? [];

                if (posts.isEmpty) {
                  return const Center(
                    child: Text('No posts yet. Be the first to post!'),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final doc = posts[index];
                    final data = doc.data();
                    final likes = List<dynamic>.from(data['likes'] ?? []);
                    final liked = likes.contains(user?.uid);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: purple,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    data['userName'] ?? 'User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              data['caption'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Divider(height: 25),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => toggleLike(doc.id, likes),
                                  icon: Icon(
                                    liked ? Icons.favorite : Icons.favorite_border,
                                    color: liked ? Colors.red : purple,
                                  ),
                                ),
                                Text('${likes.length} Likes'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
