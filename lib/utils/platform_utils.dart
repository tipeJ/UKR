import 'dart:io';

bool isDesktop() => Platform.isLinux || Platform.isMacOS || Platform.isWindows;

bool isMobile() => Platform.isIOS || Platform.isAndroid;
