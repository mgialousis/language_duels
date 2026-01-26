import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player.dart';

final playerOneNameProvider = StateProvider<String>((ref) => '');
final playerTwoNameProvider = StateProvider<String>((ref) => '');

final playerOneDirectionProvider = StateProvider<LanguageDirection>(
  (ref) => LanguageDirection.greekToCatalan,
);
final playerTwoDirectionProvider = StateProvider<LanguageDirection>(
  (ref) => LanguageDirection.catalanToGreek,
);
