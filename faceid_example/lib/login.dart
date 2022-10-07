// ignore_for_file: use_build_context_synchronously

import 'package:faceid_example/cross_platform.dart';
import 'package:faceid_example/custom_button.dart';
import 'package:faceid_example/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  bool isFingerId = true;
  bool isFaceId = true;
  bool isInit = true;
  @override
  void initState() {
    super.initState();
    initAuthentication();
  }

  Future<void> initAuthentication() async {
    print("init");
    bool isSupported = await auth.isDeviceSupported();
    bool canAuthicationWithBiometrics = await auth.canCheckBiometrics;
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();
    print("init2");
    print(availableBiometrics);
    setState(() {
      _supportState =
          isSupported ? _SupportState.supported : _SupportState.unsupported;

      isFingerId = availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong);
      isFaceId = availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.weak);
      isInit = false;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
            stickyAuth: true, biometricOnly: true, sensitiveTransaction: false),
      );
      if (authenticated) {
        CrossPlatform.transitionToPage(context, const WebViewScreen());
        // CrossPlatform.showErrorSnackbar(context, "Authentication Success");
      }
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
              fit: FlexFit.tight,
              flex: 1,
              child: SvgPicture.asset("assets/aegona_logo.svg")),
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Please login with FingerID or FaceID\nto discover our amazing service!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                            onTap: () {
                              // if (!isInit && !_isAuthenticating && isFingerId) {
                              //   _authenticateWithBiometrics();
                              // }
                              _authenticateWithBiometrics();
                            },
                            label: "FingerID",
                            color: isFingerId
                                ? const Color.fromRGBO(150, 30, 60, 1)
                                : const Color.fromRGBO(150, 30, 60, 0.5)),
                        CustomButton(
                            onTap: () {
                              if (isFaceId && !isInit && !_isAuthenticating) {
                                _authenticateWithBiometrics();
                              }
                            },
                            label: "FaceID",
                            color: isFaceId
                                ? const Color.fromRGBO(150, 30, 60, 1)
                                : const Color.fromRGBO(150, 30, 60, 0.5))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(deviceSupported),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  String get deviceSupported {
    if (isInit) {
      return "This device supports: ...";
    } else {
      if (_supportState == _SupportState.supported) {
        return "This device supports: ${isFingerId ? "Finger ID" : ""} ${isFaceId ? "Face ID" : ""}";
      } else {
        return " This device doesn't support Biometric Authentication";
      }
    }
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
