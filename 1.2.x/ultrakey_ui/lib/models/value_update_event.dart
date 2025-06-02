import 'dart:async';

class ValueUpdateEvent {
  ValueUpdateEvent({
    required this.callback,
  });

  final void Function() callback;

  void call() {
    callback.call();
  }
}

class ValueUpdateStream {
  StreamController updateStream =
      StreamController<ValueUpdateEvent>.broadcast();

  void push(
    void Function() callback,
  ) {
    updateStream.add(ValueUpdateEvent(callback: callback));
  }

  StreamSubscription<ValueUpdateEvent> listen({
    required void Function(ValueUpdateEvent) onData,
  }) {
    return updateStream.stream.listen((data) => onData(data))
        as StreamSubscription<ValueUpdateEvent>;
  }
}
