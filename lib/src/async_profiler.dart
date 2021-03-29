part of async_profiler;

/// AsyncProfiler profiles an async function.
/// Reports the elapsed wall-clock duration for each async yield by tracking the entry/exit of this custom zone
class AsyncProfiler {
  static const _thisMember = 'AsyncProfiler.';
  static const _defaultStackDepth = 0;
  final int stackDepth;
  final List<StackFrame> _frames = [];
  final _st = Stopwatch();
  var _profiling = false;

  List<StackFrame> get frames => _frames;

  String get profileResults => frames.toString();

  /// Milliseconds since profile started
  int get elapsedMS => _st.elapsedMilliseconds;


  ///AsyncProfiler, optional stackDepth is how many stack frames before the current frame to report
  AsyncProfiler({this.stackDepth = _defaultStackDepth});

  ///Default Zone Specs binds this.registerCallback to the ZoneSpecification.registerCallback
  ZoneSpecification get defaultZoneSpec => ZoneSpecification(registerCallback: registerCallback);

  ///Profile the provided function. Accepts optional ZoneSpecification or use the defaultZoneSpec
  T profile<T>(T Function() f, {ZoneSpecification zoneSpec}) {
    if(_profiling){
      throw StateError('Already Profiling');
    }
    _profiling = true;
    _st.start();
    return runZoned<T>(f, zoneSpecification: (zoneSpec ?? defaultZoneSpec));
  }

  ///scheduleMicrotask Handler to profile scheduleMicrotask zone events
  void scheduleMicrotask(Zone self, ZoneDelegate parent, Zone zone, void Function() f){
    try {
      return parent.scheduleMicrotask(zone, f);
    } finally {
      _makeStackFrames(Trace.current(stackDepth));
    }
  }

  ///registerCallback Handler to profile registerCallback zone events
  ZoneCallback<R> registerCallback <R>(Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
    _makeStackFrames(Trace.current(stackDepth));
    return parent.registerCallback(zone, () {
      return f();
    });
  }

  ///registerUnaryCallback Handler to profile registerUnaryCallback zone events
  ZoneUnaryCallback<R, T> registerUnaryCallback<R, T>(Zone self, ZoneDelegate parent, Zone zone, R Function(T arg) f) {
    _makeStackFrames(Trace.current(stackDepth));
    return parent.registerUnaryCallback(zone, (arg) {
      return f(arg);
    });
  }

  ///runHandler Handler to profile runHandler zone events
  R runHandler<R>(Zone self, ZoneDelegate parent, Zone zone, R Function()f) {
    try {
      return parent.run(zone, f);
    } finally {
      _makeStackFrames(Trace.current(stackDepth));
    }
  }

  ///runHandlerBinary Handler to profile runHandlerBinary zone events
  R runHandlerBinary<R, T, T2>(Zone self, ZoneDelegate parent, Zone zone, R Function(T t, T2 t2)f, T arg, T2 arg2) {
    try {
      return parent.runBinary(zone, f, arg, arg2);
    } finally {
      _makeStackFrames(Trace.current(stackDepth));
    }
  }

  ///runHandlerUnary Handler to profile runHandlerUnary zone events
  R runHandlerUnary<R, T>(Zone self, ZoneDelegate parent, Zone zone, R Function(T t)f, T arg) {

    try {
      return parent.runUnary(zone, f, arg);
    } finally {
      _makeStackFrames(Trace.current(stackDepth));
    }
  }

  ///_makeStackFrames terseify Traces
  ///removes Core frames, frames without line numbers and frames that refer to this class.
  void _makeStackFrames(Trace t){
    var terseTrace = t.terse.frames
        .where((frame) => !frame.member.startsWith(_thisMember) && !frame.isCore && frame.line != null);
    if(terseTrace.isNotEmpty){
      _frames.add(StackFrame(terseTrace, _st.elapsedMilliseconds));
    }
  }
}