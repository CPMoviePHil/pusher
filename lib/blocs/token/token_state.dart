part of 'token_bloc.dart';

abstract class TokenState extends Equatable {
  const TokenState();
  @override
  List<Object> get props => [];
}

class TokenInitial extends TokenState {}

class TokenSetting extends TokenState {}

class TokenFinished extends TokenState {
  final String deviceToken;

  TokenFinished({this.deviceToken});
}
class TokenSetupCompleted extends TokenState {}