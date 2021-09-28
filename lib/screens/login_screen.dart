import 'package:firebase_flutter_notes/utilities/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_flutter_notes/constants/colors.dart';
import 'package:firebase_flutter_notes/components/google_signin_button.dart';
import '../networking/google_auth.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Image.asset(
                            'assets/logo.png',
                            height: 160,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'My Easy',
                          style: TextStyle(

                            fontSize: 40,
                          ),
                        ),
                        Text(
                          'Note',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                    future:
                    GAuthentication.initializeFirebase(context: context),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error initializing Firebase');
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return GoogleSignInButton();
                      }
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Palette.orange,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
