part of 'server_bloc.dart';

abstract class ServerEvent extends Equatable {
  const ServerEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ServerToManual extends ServerEvent {}

class ServerToDropDown extends ServerEvent {}