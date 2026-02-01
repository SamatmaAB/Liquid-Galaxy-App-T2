import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey.shade800.withOpacity(0.5),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade300, size: 40),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 32),
          children: <Widget>[
            _buildSectionTitle(context, 'How It Works'),
            _buildInfoCard(
              context,
              icon: Icons.cast_connected,
              title: 'Connection',
              subtitle: 'Go to the Connection Settings page from the home screen to input your Liquid Galaxy credentials and establish a connection.',
            ),
            _buildInfoCard(
              context,
              icon: Icons.public,
              title: 'Send KML Content',
              subtitle: 'Use the buttons on the home screen to send logos, 3D models (like the pyramid), and fly-to commands to the rig.',
            ),
            _buildInfoCard(
              context,
              icon: Icons.cleaning_services,
              title: 'Clear Actions',
              subtitle: 'Use the \'CLEAR LOGO\' and \'CLEAN KML\' buttons to remove content from the screens independently.',
            ),

            _buildSectionTitle(context, 'Credits & Acknowledgements'),
             _buildInfoCard(
              context,
              icon: Icons.people,
              title: 'Project Mentors',
              subtitle: 'This project was guided by the mentors of the Liquid Galaxy project.',
            ),
            _buildInfoCard(
              context,
              icon: Icons.code,
              title: 'Contributors & Development',
              subtitle: 'Developed by [Your Name] for Google Summer of Code.',
            ),
             _buildInfoCard(
              context,
              icon: Icons.business,
              title: 'Liquid Galaxy Lab',
              subtitle: 'Special thanks to the Lleida Liquid Galaxy LAB for their support and resources.',
            ),

            _buildSectionTitle(context, 'Contact & Resources'),
            _buildInfoCard(
              context,
              icon: Icons.link,
              title: 'GitHub Repository',
              subtitle: 'Find the source code, report issues, or contribute to the project on GitHub.',
            ),
          ],
        ),
      ),
    );
  }
}
