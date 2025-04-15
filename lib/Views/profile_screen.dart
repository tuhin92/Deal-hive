import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // For demo purposes, we'll use a simple bool to simulate auth state
  final bool isLoggedIn = false; // Change this to true to see the profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoggedIn ? 'My Profile' : 'Account'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions:
            isLoggedIn
                ? [IconButton(icon: Icon(Iconsax.setting), onPressed: () {})]
                : null,
      ),
      body:
          isLoggedIn
              ? _buildProfileContent(context)
              : _buildSignInContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'John Doe',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ProfileMenuTile(
              icon: Iconsax.heart,
              title: 'Saved Deals',
              trailing: '12',
            ),
            ProfileMenuTile(
              icon: Iconsax.clock,
              title: 'Deal History',
              trailing: '24',
            ),
            ProfileMenuTile(
              icon: Iconsax.notification,
              title: 'Notification Settings',
            ),
            ProfileMenuTile(
              icon: Iconsax.security_safe,
              title: 'Privacy & Security',
            ),
            ProfileMenuTile(
              icon: Iconsax.info_circle,
              title: 'About Deal Hive',
            ),
            ProfileMenuTile(
              icon: Iconsax.logout,
              title: 'Log Out',
              textColor: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Iconsax.user, size: 100, color: Colors.grey),
          SizedBox(height: 24),
          Text(
            'Sign in to access your profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Track your deals, manage your account, and more',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Sign In', style: TextStyle(fontSize: 16)),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final Color? textColor;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    this.textColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black,
        ),
      ),
      trailing:
          trailing != null
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(trailing!),
              )
              : Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      onTap: onTap ?? () {},
    );
  }
}
