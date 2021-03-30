part of 'token_bloc.dart';

abstract class TokenEvent extends Equatable {

  const TokenEvent();

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class NeedToSetToken extends TokenEvent {}

class ToSetToken extends TokenEvent {}

class CompletedToken extends TokenEvent {
  final String deviceToken;

  CompletedToken({this.deviceToken});
}