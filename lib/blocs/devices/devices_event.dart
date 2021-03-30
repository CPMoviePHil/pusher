part of 'devices_bloc.dart';

abstract class DevicesEvent extends Equatable {
  const DevicesEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class DevicesToManual extends DevicesEvent {}

class DevicesToDropDown extends DevicesEvent {}