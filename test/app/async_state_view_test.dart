import 'package:cucocare/app/theme/app_theme.dart';
import 'package:cucocare/app/widgets/states/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fast loads skip the skeleton', (tester) async {
    final handle = _Handle();
    await tester.pumpWidget(_app(handle));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('skeleton'), findsNothing);

    handle.state.set(const AsyncData(4));
    await tester.pump();
    expect(find.text('data 4'), findsOneWidget);
    expect(find.text('skeleton'), findsNothing);
  });

  testWidgets('a slow load keeps the skeleton for at least 400 ms', (
    tester,
  ) async {
    final handle = _Handle();
    await tester.pumpWidget(_app(handle));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('skeleton'), findsOneWidget);

    handle.state.set(const AsyncData(2));
    await tester.pump();
    expect(find.text('skeleton'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 399));
    expect(find.text('skeleton'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('data 2'), findsOneWidget);
  });

  testWidgets('refresh keeps content and shows a slim progress bar', (
    tester,
  ) async {
    final handle = _Handle(const AsyncData(7));
    await tester.pumpWidget(_app(handle));
    await tester.pump();
    expect(find.text('data 7'), findsOneWidget);

    handle.state.set(
      // Riverpod only exposes the previous-value link as an internal helper.
      // ignore: invalid_use_of_internal_member
      const AsyncLoading<int>().copyWithPrevious(const AsyncData(7)),
    );
    await tester.pump();
    expect(find.text('data 7'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('skeleton'), findsNothing);
  });

  testWidgets('a failed refresh keeps content and shows a banner', (
    tester,
  ) async {
    final handle = _Handle(const AsyncData(3));
    await tester.pumpWidget(_app(handle));
    await tester.pump();

    handle.state.set(
      // ignore: invalid_use_of_internal_member
      AsyncError<int>(Exception('nope'), StackTrace.empty).copyWithPrevious(
        const AsyncData(3),
      ),
    );
    await tester.pump();

    expect(find.text('data 3'), findsOneWidget);
    expect(find.textContaining("Couldn't update"), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('a load that never finishes ends in the error state', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Handle()));
    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('retry runs the load again', (tester) async {
    var tries = 0;
    await tester.pumpWidget(_app(_Handle(), onRetry: () => tries++));
    await tester.pump(const Duration(seconds: 8));
    await tester.tap(find.text('Try again'));
    expect(tries, 1);
  });
}

Widget _app(_Handle handle, {VoidCallback? onRetry}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: _Host(handle: handle, onRetry: onRetry),
    ),
  );
}

class _Handle {
  _Handle([this.initial = const AsyncLoading()]);

  final AsyncValue<int> initial;
  late _HostState state;
}

class _Host extends StatefulWidget {
  const _Host({required this.handle, this.onRetry});

  final _Handle handle;
  final VoidCallback? onRetry;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late AsyncValue<int> value = widget.handle.initial;

  @override
  void initState() {
    super.initState();
    widget.handle.state = this;
  }

  void set(AsyncValue<int> next) {
    setState(() => value = next);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncStateView<int>(
      value: value,
      skeleton: const Text('skeleton'),
      error: (_, _) => TextButton(
        onPressed: widget.onRetry,
        child: const Text('Try again'),
      ),
      builder: (n) => Text('data $n'),
    );
  }
}
