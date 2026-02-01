import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );

      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    } catch (e) {
      print('An error occurred during connection: $e');
      return false;
    }
  }

  Future<SSHSession?> _execute(String command) async {
    try {
      if (_client == null) {
        bool? connected = await connectToLG();
        if (connected != true) return null;
      }
      return await _client!.execute(command);
    } on SSHStateError {
      print('Connection lost, reconnecting...');
      bool? connected = await connectToLG();
      if (connected != true) return null;
      try {
        return await _client!.execute(command);
      } catch (e) {
        print('Command failed on second attempt: $e');
        return null;
      }
    } catch (e) {
      print('An error occurred during execution: $e');
      return null;
    }
  }

  Future<void> _sendKML(String kml, String fileName) async {
    // Robustly write multi-line KML content using a heredoc.
    await _execute("cat <<'EOF' > /var/www/html/kml/$fileName\n$kml\nEOF");
  }

  Future<void> flyTo(String lookAt) async {
    await _execute('echo "flytoview=$lookAt" > /tmp/query.txt');
  }

  Future<void> flyToMysorePalace() async {
    // Home City: Mysore, India.
    String lookAt = '<LookAt><longitude>76.6551</longitude><latitude>12.3051</latitude><altitude>0</altitude><heading>0</heading><tilt>45</tilt><range>1200</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>';
    await flyTo(lookAt);
  }

  Future<void> sendLogo() async {
    // Send logo to the left screen (slave_1.kml in a standard 3-rig system)
    String logoKML = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
    <ScreenOverlay>
      <name>Liquid Galaxy Logo</name>
      <Icon>
        <href>https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png</href>
      </Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.05" y="0.95" xunits="fraction" yunits="fraction"/>
      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <size x="0.4" y="0.2" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
</Document>
</kml>''';
    await _sendKML(logoKML, 'slave_1.kml');
  }

  Future<void> sendPyramid() async {
    // Moving to an open area SE of the palace to avoid 3D building intersection
    final double lat = 12.3020;
    final double lon = 76.6590;
    final double size = 0.0008; // Base width (~88m)
    final double height = 180.0; // Pyramid height

    // Formatter for lon,lat,alt triples
    String c(double ln, double lt, double h) => 
        "${ln.toStringAsFixed(7)},${lt.toStringAsFixed(7)},${h.toStringAsFixed(1)}";

    // Defining points with a 10m base elevation to prevent ground clamping
    final String apex = c(lon, lat, height + 10);
    final String p1 = c(lon - size, lat - size, 10);
    final String p2 = c(lon + size, lat - size, 10);
    final String p3 = c(lon + size, lat + size, 10);
    final String p4 = c(lon - size, lat + size, 10);

    String pyramidKML = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <name>Coloured Pyramid</name>
  <Style id="red"><PolyStyle><color>ff0000ff</color><fill>1</fill><outline>1</outline></PolyStyle></Style>
  <Style id="green"><PolyStyle><color>ff00ff00</color><fill>1</fill><outline>1</outline></PolyStyle></Style>
  <Style id="blue"><PolyStyle><color>ffff0000</color><fill>1</fill><outline>1</outline></PolyStyle></Style>
  <Style id="yellow"><PolyStyle><color>ff00ffff</color><fill>1</fill><outline>1</outline></PolyStyle></Style>
  
  <Placemark>
    <styleUrl>#red</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>$p1 $p2 $apex $p1</coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>
  <Placemark>
    <styleUrl>#green</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>$p2 $p3 $apex $p2</coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>
  <Placemark>
    <styleUrl>#blue</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>$p3 $p4 $apex $p3</coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>
  <Placemark>
    <styleUrl>#yellow</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>$p4 $p1 $apex $p4</coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>
</Document>
</kml>''';

    await _sendKML(pyramidKML, 'master.kml');
    
    // Position the camera to view the 3D structure clearly across all screens.
    String lookAt = '<LookAt><longitude>${lon.toStringAsFixed(7)}</longitude><latitude>${lat.toStringAsFixed(7)}</latitude><altitude>0</altitude><heading>45</heading><tilt>70</tilt><range>600</range><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>';
    await flyTo(lookAt);
  }

  Future<void> clearKML() async {
    String emptyKML = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
    await _sendKML(emptyKML, 'master.kml');
  }

  Future<void> clearLogo() async {
    String emptyKML = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
    // Clearing logos from potential slave screens
    await _sendKML(emptyKML, 'slave_1.kml');
    await _sendKML(emptyKML, 'slave_2.kml');
    await _sendKML(emptyKML, 'slave_3.kml');
  }

  Future<void> rebootLG() async {
    int rigs = int.parse(_numberOfRigs);
    for (var i = 1; i <= rigs; i++) {
      await _execute('sshpass -p $_passwordOrKey ssh -t lg@lg$i "sudo reboot"');
    }
  }
}
