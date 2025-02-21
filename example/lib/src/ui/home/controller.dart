part of 'page.dart';

mixin HomeController on State<MyHomePage> {
  var _scanInProgress = false;

  var assuranceType = AssuranceType.genuinePresenceAssurance;
  var claimType = ClaimType.enrol;
  var camera = Camera.front;
  final userIdController = TextEditingController(text: "ETC-Anhlp-1");

  var flagTime = 0;

  // This code is for demo purposes only. Do not make API calls from the device
  // in production!
  final _apiClient = const ApiClient(
      baseUrl: 'https://$hostname/api/v2', apiKey: apiKey, secret: secret);

  void _getTokenAndLaunchIProov(
      AssuranceType assuranceType, ClaimType claimType, String userId) async {
    flagTime = DateTime.now().millisecondsSinceEpoch;
    setState(() => _scanInProgress = true);
    ProgressHud.show(ProgressHudType.loading, 'Getting token...');

    String token;

    try {
      token = await _apiClient.getToken(
        assuranceType: assuranceType,
        claimType: claimType,
        userId: userId,
      );
    } catch (e) {
      setState(() => _scanInProgress = false);
      ProgressHud.dismiss();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );

      return;
    }

    // TODO: Customize your options here
    final options = Options(
      camera: camera,
      disableExteriorEffects: true,
      orientation: Orientation.reversePortrait,
      enableScreenshots: true,
      filter: const NaturalFilter(style: NaturalFilterStyle.clear),
      // filter: const LineDrawingFilter(
      //     style: LineDrawingFilterStyle.shaded,
      //     foregroundColor: Colors.black,
      //     backgroundColor: Colors.white
      // ),
    );

    _launchIProov(token, options, userId);
  }

  StreamSubscription? subscription;

  void _launchIProov(String token, Options options, String userId) {
    final stream = IProov.launch(
        streamingUrl: 'wss://$hostname/ws', token: token, options: options);

    subscription = stream.listen((event) {
      if (event.isFinal) {
        setState(() => _scanInProgress = false);
      }

      if (event is IProovEventConnecting) {
        ProgressHud.show(ProgressHudType.loading, 'Connecting...');
      } else if (event is IProovEventConnected) {
        ProgressHud.dismiss();
      } else if (event is IProovEventProcessing) {
        ProgressHud.show(ProgressHudType.progress, event.message);
        ProgressHud.updateProgress(event.progress, event.message);
      } else if (event is IProovEventCanceled) {
        ProgressHud.showAndDismiss(
            ProgressHudType.success, 'Canceled by ${event.canceler.name}');
      } else if (event is IProovEventSuccess) {
        ProgressHud.showAndDismiss(ProgressHudType.success, 'Success!');
        getValidateInfo(token: token, userId: userId);
      } else if (event is IProovEventFailure) {
        ProgressHud.showAndDismiss(ProgressHudType.error, event.reason);
        getValidateInfo(token: token, userId: userId);
      } else if (event is IProovEventError) {
        ProgressHud.showAndDismiss(ProgressHudType.error, event.error.title);
      }


    });
  }

  Future<void> getValidateInfo(
      {required String token, required String userId}) async {
    await _apiClient.validate(token: token, userId: userId);
    print(
        "Time-------------------------: ${DateTime.now().millisecondsSinceEpoch - flagTime}");
    subscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}
