# Profiles Async function

Profile async function call stack.

## Usage

A simple usage example:

```dart
import 'package:async_profiler/async_profiler.dart';

main() async {
  asyncProfiler = AsyncProfiler();
  await asyncProfiler.profile(() {
    //Your Async Code
  });

  asyncProfiler.profileResults; //String representation of frames collected per function call.
  asyncProfiler.elapsedMilliseconds; //Total time the profiler has been running.
  asyncProfiler.frames; //All StackFrame objects.
}
```

## Features and bugs

* Profiles an async function
* Reports the total elapsed time after each call
* Produces a terse stack trace for each function call. _NB: stack traces are slow to be careful in high load environments_

## Improvements

* Custom call backs for collecting samples other than time.