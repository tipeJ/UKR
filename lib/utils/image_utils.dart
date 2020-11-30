import 'package:UKR/models/models.dart';

String decodeExternalImageUrl(String url) => Uri.decodeComponent(url.replaceFirst("image://", ""));
