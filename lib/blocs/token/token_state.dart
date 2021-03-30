part of 'token_bloc.dart';

abstract class TokenState extends Equatable {
  const TokenState();
  @override
  List<Object> get props => [];
}

class TokenInitial extends TokenState {}

class TokenSetting extends TokenState {}

class TokenSet extends TokenState {
  final String deviceToken;

  TokenSet({this.deviceToken});
}