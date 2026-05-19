import 'package:flutter/material.dart';
import 'package:portfolio_website/services/database_service.dart';
import 'package:portfolio_website/screens/admin/login_screen.dart';
import 'package:portfolio_website/screens/admin/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminGate extends StatefulWidget {
  const AdminGate({super.key});

  @override
  State<AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<AdminGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    
    // Listen to auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _isAuthenticated = data.session != null;
        });
      }
    });
  }

  Future<void> _checkAuth() async {
    final isAuthenticated = SupabaseService().isAuthenticated;
    if (mounted) {
      setState(() {
        _isAuthenticated = isAuthenticated;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_isAuthenticated) {
      return const AdminDashboard();
    } else {
      return const LoginScreen();
    }
  }
}
