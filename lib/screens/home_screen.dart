import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'citizen/home_screen.dart';
import 'driver/driver_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isCitizen) {
          return const CitizenHomeScreen();
        } else if (authProvider.isDriver) {
          return const DriverHomeScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Unknown user role'),
            ),
          );
        }
      },
    );
  }
}
