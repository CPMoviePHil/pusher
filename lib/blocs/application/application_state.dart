part of 'application_bloc.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();
  @override
  List<Object> get props => [];
}

class ApplicationInitial extends ApplicationState {}

class ApplicationSetting extends ApplicationState {}

class ApplicationSetupCompleted extends ApplicationState {}
