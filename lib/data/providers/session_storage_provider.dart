import 'package:riverpod/riverpod.dart';

import '../repositories/session_storage.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage();
});
