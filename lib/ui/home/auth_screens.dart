import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_flutter/sync/sync_helper.dart';
import 'package:notes_flutter/ui/home/auth_profile_screen.dart';
import 'package:notes_flutter/ui/home/auth_signin_screen.dart';
import 'package:provider/provider.dart';

class AuthScreenContainer extends StatefulWidget {
  final AuthScreen authScreen;
  const AuthScreenContainer(this.authScreen , {super.key,});

  @override
  State<AuthScreenContainer> createState() => _AuthScreenContainerState();
}

class _AuthScreenContainerState extends State<AuthScreenContainer> {
  late SyncHelper _syncHelper;
  late AuthScreen authScreen;
  bool showSignInSelection = false;
  bool showSignOutSelection = false;

  @override
  void initState() {
    super.initState();
    authScreen = widget.authScreen;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _syncHelper = Provider.of<SyncHelper>(context, listen: false);
        _syncHelper.pause();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _syncHelper.resume();
  }

  @override
  Widget build(BuildContext context) {

    Widget child = switch (authScreen) {
      AuthScreen.profile => AuthProfileScreen(_onSignOut),
      AuthScreen.signIn => AuthSignInScreen(_onSignIn)
    };

    return Container(
      color: Theme.of(context).canvasColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > constraints.maxHeight) {
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (!showSignInSelection && !showSignOutSelection) {
                      Navigator.pop(context);
                    }
                  },
                ),
                Expanded(child: child)
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(child: child)
              ],
            );
          }
        },
      ),
    );
  }

  void _onSignIn(User? user) {
    if (user == null || !user.emailVerified) {
      Navigator.pop(context);
    } else {
      setState(() {
        showSignInSelection = true;
        authScreen = AuthScreen.profile;
      });
    }
  }

  void _onSignOut() {
    showSignOutSelection = true;
    _syncHelper.cleanLocalSyncStates().then((_) {
      if (context.mounted) Navigator.of(context).pop();
    });
  }
}

enum AuthScreen {
  profile,
  signIn,
}
