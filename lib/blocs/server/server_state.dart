part of 'server_bloc.dart';

abstract class ServerState extends Equatable {
  const ServerState();
  @override
  List<Object> get props => [];
}

class ServerInitial extends ServerState {}

class ServerFromField extends ServerState {}