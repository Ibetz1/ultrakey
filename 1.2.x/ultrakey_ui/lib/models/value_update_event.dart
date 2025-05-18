import 'dart:async';

class ValueUpdateEvent {
  ValueUpdateEvent({
    required this.id,
    required this.value,
  });

  final String id;
  final dynamic value;

  // static StreamController updateStream =
  //     StreamController<ValueUpdateEvent>.broadcast();

  // static void push({
  //   required String id,
  //   required dynamic value,
  // }) {
  //   updateStream.add(
  //     ValueUpdateEvent(id: id, value: value),
  //   );
  // }

  // static StreamSubscription<ValueUpdateEvent> listen({
  //   required void Function(ValueUpdateEvent) onData,
  // }) {
  //   return updateStream.stream.listen((data) => onData(data))
  //       as StreamSubscription<ValueUpdateEvent>;
  // }
}

class ValueUpdateStream {
  StreamController updateStream =
      StreamController<ValueUpdateEvent>.broadcast();

  void push({
    required String id,
    required dynamic value,
  }) {
    updateStream.add(
      ValueUpdateEvent(id: id, value: value),
    );
  }

  StreamSubscription<ValueUpdateEvent> listen({
    required void Function(ValueUpdateEvent) onData,
  }) {
    return updateStream.stream.listen((data) => onData(data))
        as StreamSubscription<ValueUpdateEvent>;
  }
}
