import 'package:extensions_pack/extensions_pack.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/widgets_pack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AppDaysPicker(
                      // enabled: false,
                      handler: AppSingleItemHandler((date) {}),
                      firstDate: DateTime(2021),
                      lastDate: DateTime(2025),
                      selectedDisplayRange: DateTimeRange(
                        start: DateTime(2024, 8, 3),
                        end: DateTime(2024, 9, 15),
                      ),
                      onDateChanged: (_) {},
                      dayBuilder: (child) {
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
            ),
          );
        },
      ),
    );
  }
}
