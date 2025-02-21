import 'dart:async';

import 'package:bmprogresshud/progresshud.dart';
import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter/services.dart';
import 'package:iproov_api_client/iproov_api_client.dart';
import 'package:iproov_flutter/iproov_flutter.dart';

import '../../../credentials.dart';

part 'controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with HomeController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ETC iProov Example')),
      body: ProgressHud(
        isGlobalHud: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(controller: userIdController),
              ListTile(
                title: const Text('AssuranceType'),
                subtitle: Text(assuranceType.stringValue),
                trailing: Switch(
                  value:
                      assuranceType == AssuranceType.genuinePresenceAssurance,
                  onChanged: (value) {
                    setState(() {
                      assuranceType = value
                          ? AssuranceType.genuinePresenceAssurance
                          : AssuranceType.livenessAssurance;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('ClaimType'),
                subtitle: Text(claimType.stringValue),
                trailing: Switch(
                  value: claimType == ClaimType.enrol,
                  onChanged: (value) {
                    setState(() {
                      claimType = value ? ClaimType.enrol : ClaimType.verify;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Camera'),
                subtitle: Text(camera.stringValue),
                trailing: Switch(
                  value: camera == Camera.front,
                  onChanged: (value) {
                    setState(() {
                      camera = value ? Camera.front : Camera.external;
                    });
                  },
                ),
              ),
              TextButton(
                child: const Text(
                  '🚀 Launch',
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: _scanInProgress
                    ? null
                    : () => _getTokenAndLaunchIProov(
                          assuranceType,
                          claimType,
                          userIdController.text,
                        ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
