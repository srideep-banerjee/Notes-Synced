import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_flutter/firebase/auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:notes_flutter/firebase_options.dart';
import 'package:provider/provider.dart';

class ProfileIcon extends StatefulWidget {
  const ProfileIcon({super.key});

  @override
  State<ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  Stream<User?>? _userStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _userStream = Provider.of<Authenticator>(context, listen: false).getUserStream();
      });
    });
  }



  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      initialData: null,
      stream: _userStream,

      builder: (context, snapshot) {
        User? user = snapshot.data;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              user == null ?
              _signInPageRout(context) :
              _profileScreenPageRout(context),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 32.0,
              height: 32.0,
              child: user == null
                  ? const DefaultProfileIconImage()
                  : TextProfileIconImage(user.email),
            ),
          ),
        );
      },
    );
  }

  MaterialPageRoute _signInPageRout(BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => SignInScreen(
        providers: [
          EmailAuthProvider(),
          GoogleProvider(
            clientId: DefaultFirebaseOptions.webClientId,
          )
        ],
        actions: [
          AuthStateChangeAction((context, state) {
            if (state is AuthFailed) {
              PlatformException pe = (state.exception as PlatformException);
              print(
                  "////////////////////////${pe.code} , ${pe.message}///////////////////////");
              print(pe.stacktrace);
            }
          })
        ],
      ),
    );
  }

  MaterialPageRoute _profileScreenPageRout(BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => const ProfileScreen(
        actions: [],
      ),
    );
  }
}

class DefaultProfileIconImage extends StatelessWidget {
  const DefaultProfileIconImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimary,
          width: 2.0,
        )
      ),
      child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary),
    );
  }
}

class TextProfileIconImage extends StatelessWidget {
  final String text;

  const TextProfileIconImage(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(
          color: _borderColor,
          width: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          text.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  Color get _color {
    return HSLColor.fromAHSL(
      1.0,
      (_customHash % 361).toDouble(),
      1.0,
      0.35,
    ).toColor();
  }

  Color get _borderColor {
    return HSLColor.fromAHSL(
      1.0,
      (_customHash % 361).toDouble(),
      1.0,
      0.25,
    ).toColor();
  }

  int get _customHash {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash += (i + 1) * text.codeUnitAt(i);
    }
    return hash;
  }
}
