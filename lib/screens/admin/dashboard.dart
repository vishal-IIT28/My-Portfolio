import 'package:flutter/material.dart';
import 'package:portfolio_website/constants/app_constants.dart';
import 'package:portfolio_website/services/database_service.dart';
import 'package:portfolio_website/screens/admin/tabs/projects_tab.dart';
import 'package:portfolio_website/screens/admin/tabs/skills_experience_tab.dart';
import 'package:portfolio_website/screens/admin/tabs/education_tab.dart';
import 'package:portfolio_website/screens/admin/tabs/journey_tab.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppConstants.bgDeep,
        appBar: AppBar(
          backgroundColor: AppConstants.bgGlass,
          title: const Text('Jensen Omega Admin'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await SupabaseService().signOutAdmin();
                // AdminGate handles the state update
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppConstants.gold,
            labelColor: AppConstants.gold,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.work), text: 'Projects'),
              Tab(icon: Icon(Icons.code), text: 'Skills & Exp'),
              Tab(icon: Icon(Icons.school), text: 'Education'),
              Tab(icon: Icon(Icons.timeline), text: 'Journey'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProjectsTab(),
            SkillsExperienceTab(),
            EducationTab(),
            JourneyTab(),
          ],
        ),
      ),
    );
  }
}
