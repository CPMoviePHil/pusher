part of 'application_bloc.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetApplicationEvent extends ApplicationEvent {}

class BeforeGetApplicationEvent extends ApplicationEvent {}