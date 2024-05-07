import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recaptcha_enterprise/app_config.dart';
import 'package:recaptcha_enterprise/recaptcha_repository.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_enterprise.dart';

Future<void> main({String? env}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await AppConfig.forEnvironment(env);

  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  const MyApp({required this.config, super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(config: config),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final AppConfig config;

  const MyHomePage({required this.config, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _clientState = "NOT INITIALIZED";
  String _token = "NO TOKEN";
  String siteKey = '';
  RecaptchaRepository recaptchaRepository = RecaptchaRepository();

  void initClient() async {
    siteKey = Platform.isAndroid ? widget.config.androidSiteKey : widget.config.iosSiteKey;

    var result = false;
    var errorMessage = "failure";

    try {
      result = await RecaptchaEnterprise.initClient(siteKey, timeout: 10000);
    } on PlatformException catch (err) {
      debugPrint('Caught platform exception on init: $err');
      errorMessage = 'Code: ${err.code} Message ${err.message}';
    } catch (err) {
      debugPrint('Caught exception on init: $err');
      errorMessage = err.toString();
    }

    setState(() {
      _clientState = result ? "ok" : errorMessage;
    });
  }

  void verify({required String siteKey}) async {
    String result = '';
    try {
      final token = await RecaptchaEnterprise.execute(RecaptchaAction.LOGIN());
      final response = await recaptchaRepository.verify(token: token, siteKey: siteKey);
      result = response ? 'Success' : 'Failure';
    } on PlatformException catch (err) {
      debugPrint('Caught platform exception on execute: $err');
      result = 'Code: ${err.code} Message ${err.message}';
    } catch (err) {
      debugPrint('Caught exception on execute: $err');
      result = err.toString();
    }

    setState(() {
      _token = result;
    });
  }

  @override
  void initState() {
    super.initState();
    initClient();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('reCAPTCHA Example'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            const Text('reCAPTCHA Client:\n '),
            Text(_clientState, key: const Key('clientState')),
          ]),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Text('reCAPTCHA Token:\n '),
          SizedBox(
            width: 300,
            child: Text(_token,
                textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 12, key: const Key('token')),
          ),
        ]),
        TextButton(
          onPressed: () => verify(siteKey: siteKey),
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: const Text(
              'Verify reCAPTCHA',
              style: TextStyle(color: Colors.white, fontSize: 13.0),
            ),
          ),
        ),
      ]),
    ));
  }
}
