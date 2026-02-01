import 'package:flutter/material.dart';
import 'package:lg_connection/components/connection_flag.dart';
import 'package:lg_connection/connections/ssh.dart';
import 'package:lg_connection/screens/help_screen.dart';

bool connectionStatus = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SSH ssh;

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    if (mounted) {
      setState(() {
        connectionStatus = result ?? false;
      });
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required double fontSize,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    // Use MediaQuery.size to reliably determine orientation
    final size = MediaQuery.of(context).size;
    final isPortrait = size.width < size.height;

    final actions = [
      _buildActionButton(
        icon: Icons.satellite_alt,
        label: 'SEND LOGO',
        onPressed: () => ssh.sendLogo(),
        fontSize: 18,
      ),
      _buildActionButton(
        icon: Icons.delete_forever,
        label: 'CLEAR LOGO',
        onPressed: () => ssh.clearLogo(),
        fontSize: 18,
      ),
      _buildActionButton(
        icon: Icons.view_in_ar,
        label: 'SEND PYRAMID',
        onPressed: () => ssh.sendPyramid(),
        fontSize: 18,
      ),
      _buildActionButton(
        icon: Icons.layers_clear,
        label: 'CLEAN KML',
        onPressed: () => ssh.clearKML(),
        fontSize: 18,
      ),
      _buildActionButton(
        icon: Icons.flight_takeoff,
        label: 'FLY TO MYSORE PALACE',
        onPressed: () => ssh.flyToMysorePalace(),
        fontSize: 18,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LG Controller',
          style: TextStyle(color: Colors.white), // Make title text white
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white), // Add help icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white), // Add settings icon and make it white
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _connectToLG();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true, // Make body go behind app bar
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top + 16), // Space for app bar and status bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConnectionFlag(status: connectionStatus),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isPortrait
                  ? _buildPortraitLayout(actions)
                  : _buildLandscapeLayout(actions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(List<Widget> actions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return Container(
          height: 140, // Generous height for touch targets
          margin: const EdgeInsets.only(bottom: 16),
          child: actions[index],
        );
      },
    );
  }

  Widget _buildLandscapeLayout(List<Widget> actions) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8, // Adjusted for better landscape visuals
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        // This logic is to center the last item if there's an odd number of items.
        if (actions.length.isOdd && index == actions.length - 1) {
          return GridTile(
            child: Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: actions[index],
              ),
            ),
          );
        }
        return actions[index];
      },
    );
  }
}
