part of 'token_bloc.dart';

abstract class TokenEvent extends Equatable {

  const TokenEvent();

  @override
  // TODO: implement props
  List<Object> get props => [];
}
class ToSetToken extends TokenEvent {}

class SetToken extends TokenEvent {}