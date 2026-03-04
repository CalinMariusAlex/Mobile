import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileService();
    final authUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: StreamBuilder(
        stream: profile.watchMyProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No profile found in Firestore for this user.'),
            );
          }

          final data = snapshot.data!.data()!;
          final displayName = (data['displayName'] ?? '') as String;
          final role = (data['role'] ?? '') as String;
          final email = (data['email'] ?? authUser?.email ?? '') as String;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Icon(Icons.account_circle, size: 80),
              const SizedBox(height: 12),
              Text(
                displayName.isEmpty ? 'No display name' : displayName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(email, textAlign: TextAlign.center),
              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Role'),
                  subtitle: Text(role.isEmpty ? '-' : role),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('UID'),
                  subtitle: Text(authUser?.uid ?? '-'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}