import 'package:riverpod/legacy.dart';

import '../models/player.dart';
import 'game_session_provider.dart';

final playerOneNameProvider = StateProvider<String>((ref) => '');
final playerTwoNameProvider = StateProvider<String>((ref) => '');

final playerOneDirectionProvider = StateProvider<LanguageDirection>(
  (ref) => LanguageDirection.greekToCatalan,
);
final playerTwoDirectionProvider = StateProvider<LanguageDirection>(
  (ref) => LanguageDirection.catalanToGreek,
);

final selectedGameTypesProvider = StateProvider<List<GameType>>(
  (ref) => [...defaultGameOrder],
);
