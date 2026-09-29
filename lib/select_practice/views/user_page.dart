import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/select_practice/providers/user_providers.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (kDebugMode) {
      print('UserPage rebuilt');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Practice')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Name: ${user.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text('Age: ${user.age}', style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 10),

            Text('Email: ${user.email}', style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                ref.read(userProvider.notifier).updateName('Ali');
              },
              child: const Text('Change Name'),
            ),

            ElevatedButton(
              onPressed: () {
                ref.read(userProvider.notifier).updateAge(30);
              },
              child: const Text('Change Age'),
            ),

            ElevatedButton(
              onPressed: () {
                ref.read(userProvider.notifier).updateEmail('ali@example.com');
              },
              child: const Text('Change Email'),
            ),
          ],
        ),
      ),
    );
  }
}
