import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final Env _instance = Env._internal();
  factory Env() => _instance;
  Env._internal();

  late String apiBaseUrl;
  late int apiTimeout;
  late String signalrUrl;

  Future<void> init() async {
    await dotenv.load(fileName: '.env');

    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'https://localhost:7080';
    apiTimeout = int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
    signalrUrl =
        dotenv.env['SIGNALR_URL'] ??
        'https://localhost:7080/Hub/NotificacionesHub';
  }

  String get fullApiUrl => apiBaseUrl;
  String get fullSignalrUrl => signalrUrl;
}
