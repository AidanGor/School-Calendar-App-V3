// import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({Key? key}) : super(key: key);

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool isSignUpMode = false; // toggle between sign up / sign in

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign In')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _authenticate,
//               child: Text(isSignUpMode ? 'Sign Up' : 'Sign In'),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   isSignUpMode = !isSignUpMode;
//                 });
//               },
//               child: Text(isSignUpMode
//                   ? 'Already have an account? Sign In'
//                   : 'No account? Create one'),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   // Future<void> _authenticate() async {
//   //   final email = emailController.text.trim();
//   //   final password = passwordController.text.trim();

//   //   try {
//   //     if (isSignUpMode) {
//   //       // create user
//   //       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//   //         email: email,
//   //         password: password,
//   //       );
//   //     } else {
//   //       // sign in
//   //       await FirebaseAuth.instance.signInWithEmailAndPassword(
//   //         email: email,
//   //         password: password,
//   //       );
//   //     }
//   //     // If successful, authStateChanges will emit a User -> AuthGate -> Home
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text(e.toString())),
//   //     );
//   //   }
//   // }
// }