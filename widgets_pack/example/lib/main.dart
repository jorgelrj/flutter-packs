import 'package:equatable/equatable.dart';
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
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AppDropDownFormField<User>(
                  fetcher: AppLocalItemsFetcher([
                    ...List.generate(
                      10,
                      (index) => User(
                        id: index,
                        email: '$index',
                        name: 'User $index',
                      ),
                    ),
                  ]),
                  handler: AppSingleItemHandler((_) {}),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
