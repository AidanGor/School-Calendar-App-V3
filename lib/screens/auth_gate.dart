// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'sign_in_screen.dart';      // <--- Your existing sign_in_screen.dart
// import 'home_screen.dart'; 
// import '../models/full_schedule.dart';
//    // <--- We'll create this file next

// class AuthGate extends StatelessWidget {
//   final FullSchedule fullSchedule;
//   const AuthGate({Key? key, required this.fullSchedule}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           // user is signed in -> show home
//           return HomeScreen(fullSchedule: fullSchedule);
//         } else {
//           // not signed in -> show sign in
//           return const SignInScreen();
//         }
//       },
//     );
//   }
// }