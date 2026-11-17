import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MamunSocialApp());
}

class MamunSocialApp extends StatelessWidget {
  const MamunSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAMUN SOCIAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101010),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6AD55),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171717),
          foregroundColor: Color(0xFFD6AD55),
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF202020),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
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
        return snapshot.data == null ? const LoginPage() : const FeedPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool isRegister = false;
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      showMessage('ইমেইল দিন এবং পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের করুন।');
      return;
    }
    setState(() => busy = true);
    try {
      if (isRegister) {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(credential.user!.uid)
            .set({
          'displayName': name.text.trim().isEmpty
              ? 'নতুন ব্যবহারকারী'
              : name.text.trim(),
          'email': email.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'অ্যাকাউন্টে প্রবেশ করা যায়নি।');
    } catch (e) {
      showMessage('সমস্যা হয়েছে: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.people_alt_rounded,
                    size: 76, color: Color(0xFFD6AD55)),
                const SizedBox(height: 12),
                const Text(
                  'MAMUN SOCIAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD6AD55),
                  ),
                ),
                const SizedBox(height: 28),
                if (isRegister) ...[
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'আপনার নাম'),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'ইমেইল'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'পাসওয়ার্ড'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: busy ? null : submit,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: busy
                        ? const CircularProgressIndicator()
                        : Text(isRegister ? 'অ্যাকাউন্ট তৈরি করুন' : 'লগইন'),
                  ),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () => setState(() => isRegister = !isRegister),
                  child: Text(isRegister
                      ? 'আগে থেকেই অ্যাকাউন্ট আছে? লগইন'
                      : 'নতুন অ্যাকাউন্ট খুলুন'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final postController = TextEditingController();
  bool posting = false;

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  Future<void> addPost() async {
    final text = postController.text.trim();
    if (text.isEmpty) return;
    setState(() => posting = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('Posts').add({
        'text': text,
        'uid': user.uid,
        'displayName': user.email?.split('@').first ?? 'ব্যবহারকারী',
        'createdAt': FieldValue.serverTimestamp(),
      });
      postController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('পোস্ট করা যায়নি: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAMUN SOCIAL'),
        actions: [
          IconButton(
            tooltip: 'লগআউট',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: postController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'আপনার মনের কথা লিখুন...',
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: posting ? null : addPost,
                  icon: const Icon(Icons.send),
                  label: Text(posting ? 'পোস্ট হচ্ছে...' : 'পোস্ট করুন'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('পোস্ট লোড করা যায়নি। Firestore সেটআপ দেখুন।'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return const Center(child: Text('এখনো কোনো পোস্ট নেই।'));
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final data = posts[index].data();
                    final date = data['createdAt'] as Timestamp?;
                    return Card(
                      color: const Color(0xFF1C1C1C),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['displayName'] ?? 'ব্যবহারকারী',
                              style: const TextStyle(
                                color: Color(0xFFD6AD55),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(data['text'] ?? ''),
                            if (date != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                date.toDate().toLocal().toString(),
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11),
                              ),
                            ],
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
