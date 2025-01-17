import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> connectivityStream() {
    // Return the onConnectivityChanged stream, which is of type Stream<ConnectivityResult>
    return _connectivity.onConnectivityChanged;
  }
}