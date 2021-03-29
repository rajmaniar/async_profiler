part of async_profiler;

/// StackFrame is produced for each async event loop yield
class StackFrame {
  final Iterable<Frame> lines;
  final int elapsed;

  StackFrame(this.lines, this.elapsed);

  Map<String, dynamic> toMap(){
    return {
      'st':lines,
      'time':{'elapsed':elapsed, 'unit':'ms'}
    };
  }

  @override
  String toString() {
    return {
      'st':lines.map((e) => e.toString()),
      'time':{'elapsed':elapsed, 'unit':'ms'}
    }.toString();
  }
}