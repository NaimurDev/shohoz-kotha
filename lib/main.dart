
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shohoj_kotha_2/firebase_options.dart';
import 'package:shohoj_kotha_2/screens/chat_screens.dart';
import 'package:shohoj_kotha_2/screens/login_screen.dart';
import 'package:shohoj_kotha_2/screens/registration_screen.dart';
import 'screens/welcome_screen.dart';

late FirebaseApp app;
late FirebaseAuth auth;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instanceFor(app: app);
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id : (context)=>WelcomeScreen(),
        LoginScreen.id : (context)=>LoginScreen(),
        RegistrationScreen.id: (context)=>RegistrationScreen(),
        ChatScreen.id : (context)=>ChatScreen(),
      },
    );
  }
}