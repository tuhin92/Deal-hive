import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [IconButton(icon: Icon(Iconsax.setting), onPressed: () {})],
      ),
      body: SingleChildScrollView(
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final Color? textColor;

  const ProfileMenuTile({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    this.textColor,
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
      onTap: () {},
    );
  }
}
