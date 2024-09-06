import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final data = {
      'teste',
      'teste1',
      'teste2',
    };

    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  AppButton.text(
                      onPressed: () {
                        setState(() {
                          date = DateTime(2024);
                        });
                      },
                      child: const Text('Change date', style: TextStyle(color: Colors.black))),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: AppDaysPicker(
                          key: const Key('test'),
                          // selectedDisplayRange: DateTimeRange(
                          //   start: DateTime(2024, 8, 3),
                          //   end: DateTime(2024, 9, 15),
                          // ),
                          handler: AppSingleItemHandler((date) {}),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2500),
                          initialDate: date,
                          // onDisplayedMonthChanged: (date) {
                          //   print(date);
                          // },
                          // onDateChanged: (date) {
                          //   print(date);
                          // },
                          dayBuilder: (child, [date]) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                child,
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List<Widget>.generate(3, (_) {
                                    return Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                    );
                                  }).addSpacingBetween(mainAxisSpacing: 2),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
