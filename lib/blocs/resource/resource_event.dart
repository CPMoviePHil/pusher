part of 'resource_bloc.dart';

abstract class ResourceEvent extends Equatable {
  const ResourceEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}
class ResourceToInit extends ResourceEvent {}

class ResourceBeforeFetch extends ResourceEvent {}

class ResourceFetch extends ResourceEvent {}