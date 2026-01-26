import 'package:equatable/equatable.dart';

enum LanguageDirection { greekToCatalan, catalanToGreek }

class Player extends Equatable {
  final String name;
  final LanguageDirection direction;

  const Player({required this.name, required this.direction});

  String get sourceCode =>
      direction == LanguageDirection.greekToCatalan ? 'el' : 'ca';

  String get targetCode =>
      direction == LanguageDirection.greekToCatalan ? 'ca' : 'el';

  @override
  List<Object?> get props => [name, direction];
}
