import 'package:flutter/material.dart';

class DeviceProfile {
  const DeviceProfile(this.name, this.size);

  final String name;
  final Size size;
}

/// Window sizes used by the dev preview and the layout tests.
const deviceProfiles = <DeviceProfile>[
  DeviceProfile('Small phone', Size(320, 568)),
  DeviceProfile('Older phone', Size(360, 640)),
  DeviceProfile('Standard phone', Size(360, 800)),
  DeviceProfile('Standard phone 393', Size(393, 852)),
  DeviceProfile('Standard phone 412', Size(412, 915)),
  DeviceProfile('Large phone', Size(480, 1000)),
  DeviceProfile('Foldable', Size(673, 841)),
  DeviceProfile('Small tablet', Size(600, 960)),
  DeviceProfile('Tablet', Size(800, 1280)),
  DeviceProfile('Landscape phone', Size(640, 360)),
  DeviceProfile('Landscape phone 800', Size(800, 360)),
  DeviceProfile('Landscape phone 915', Size(915, 412)),
  DeviceProfile('Landscape tablet', Size(1280, 800)),
  DeviceProfile('Landscape tablet 1024', Size(1024, 768)),
  DeviceProfile('Split narrow', Size(320, 400)),
  DeviceProfile('Split short', Size(411, 300)),
];
