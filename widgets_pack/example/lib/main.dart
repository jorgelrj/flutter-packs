import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:widgets_pack/helpers/helpers.dart';
import 'package:widgets_pack/widgets/table/table.dart';
import 'package:widgets_pack/widgets/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: DragScrollBehavior(),
      home: const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _Table(),
          ),
        ),
      ),
    );
  }
}

class _Table extends StatefulWidget {
  const _Table();

  @override
  State<_Table> createState() => _TableState();
}

class User extends Equatable {
  final int id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email}';
  }
}

class _TableState extends State<_Table> {
  late final tableController = TableController<User>(
    loader: TablePaginatedLoader(
      (page, pageSize) async {
        return Future.delayed(
          const Duration(seconds: 3),
          () {
            return List.generate(
              pageSize,
              (index) => User(
                id: index * page + index,
                name: 'User $index',
                email: '$index@gmail.com',
              ),
            );
          },
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTable<User>(
            headerAction: AppButtonConfig.text(
              'Add',
              type: AppButtonType.tonal,
              onPressed: () {},
            ),
            onRowTap: print,
            filters: [
              AppTextFilter(
                label: 'Name',
                onChanged: (_) {},
              ),
              AppBooleanFilter(
                label: 'Active',
                onChanged: (_) {},
              ),
              AppTextFilter(
                label: 'Name',
                onChanged: (_) {},
              ),
              AppBooleanFilter(
                label: 'Active',
                onChanged: (_) {},
              ),
              AppTextFilter(
                label: 'Name',
                onChanged: (_) {},
              ),
              AppBooleanFilter(
                label: 'Active',
                onChanged: (_) {},
              ),
              AppTextFilter(
                label: 'Name',
                onChanged: (_) {},
              ),
              AppBooleanFilter(
                label: 'Active',
                onChanged: (_) {},
              ),
            ],
            controller: tableController,
            actions: (items) => [
              const TableAction(
                label: 'View',
                icon: Icon(Icons.remove_red_eye),
              ),
              TableActionDivider(),
              TableAction(
                label: 'Delete',
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  tableController.reload(keepOffset: true);
                },
              ),
            ],
            columns: [
              TextColumn(
                label: const Text('ID'),
                width: 50,
                value: (user) => user.id.toString(),
                fixed: true,
              ),
              TextColumn(
                label: const Text('Name'),
                value: (user) => user.name,
                width: 150,
                fixed: true,
              ),
              TextColumn(
                label: const Text('Email'),
                value: (user) => user.email,
                width: 150,
              ),
              TextColumn(
                label: const Text('Email'),
                value: (user) => user.email,
              ),
              TextColumn(
                label: const Text('Email'),
                value: (user) => user.email,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
