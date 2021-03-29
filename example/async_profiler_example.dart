import 'package:async_profiler/async_profiler.dart';

void main() async {
  final asyncProfiler = AsyncProfiler();
  var stopWatch = await asyncProfiler.profile<Future<Stopwatch>>(() async {
    final st = Stopwatch()..start();
    await Future.delayed(Duration(seconds: 1));
    await Future.forEach(List.generate(10, (i) => i), (_) async {
      await Future<int>.delayed(Duration(milliseconds: 100));
    });
    return st..stop();
  });
  print(asyncProfiler.profileResults);
  print(stopWatch.elapsedMilliseconds);
}
