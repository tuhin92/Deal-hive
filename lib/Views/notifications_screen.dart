import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                [
                  Iconsax.discount_shape,
                  Iconsax.notification,
                  Iconsax.tag,
                  Iconsax.timer_1,
                  Iconsax.heart,
                ][index],
                color: Colors.blue,
              ),
            ),
            title: Text(
              [
                'New Deal Alert',
                'Deal Hive Update',
                'Discount Expires Soon',
                'Flash Sale Started',
                'Deal Saved For You',
              ][index],
            ),
            subtitle: Text('Tap to view more details about this notification.'),
            trailing: Text(
              '${index + 1}h ago',
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
