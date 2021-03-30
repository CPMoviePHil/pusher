part of 'resource_bloc.dart';

abstract class ResourceState extends Equatable {
  const ResourceState();
  @override
  List<Object> get props => [];
}

class ResourceInitial extends ResourceState {}

class ResourceSuccess extends ResourceState {
  final List<SerialNumber> devices;
  ResourceSuccess({this.devices});
}

class ResourceFailed extends ResourceState {}

class ResourceLoading extends ResourceState {}
