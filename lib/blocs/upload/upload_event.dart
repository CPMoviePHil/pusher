part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UploadToServer extends UploadEvent {}

class UploadBeforeToServer extends UploadEvent {}
