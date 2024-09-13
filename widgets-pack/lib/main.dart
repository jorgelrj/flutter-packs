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

typedef User = (String name, String lastName, int age, String email);

class _MyAppState extends State<MyApp> {
  DateTime date = DateTime.now();

  final data = <User>[
    ('John', 'Doe', 30, 'john@test.com'),
    ('Jane', 'Doe', 25, 'jane@test.com'),
    ('Alice', 'Smith', 35, 'alice@test.com'),
    ('Bob', 'Brown', 40, 'bob@test.com'),
  ];

  late final controller = AppTableViewListController(
    items: data,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AppTableView<User>(
                        config: AppTableViewConfig(
                          actionType: TableActionsType.single,
                          pageSize: 100,
                          showActionsAsTrailingIcon: true,
                          actions: (users) {
                            return [
                              AppAction(
                                label: 'Testing',
                                icon: Icon(Icons.ac_unit),
                                onPressed: () => print('Testing'),
                              ),
                              AppAction(
                                label: 'Testing 2',
                                icon: Icon(Icons.ac_unit),
                                onPressed: () => print('Testing 2'),
                              ),
                            ];
                          },
                        ),
                        controller: controller,
                        columns: [
                          TextColumn(label: Text('Name'), value: (user) => user.$1),
                          TextColumn(label: Text('Last Name'), value: (user) => user.$2),
                          NumberColumn(label: Text('Age'), value: (user) => user.$3),
                          TextColumn(label: Text('Email'), value: (user) => user.$4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
