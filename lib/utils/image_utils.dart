import 'package:UKR/models/models.dart';

String decodeExternalImageUrl(String url) => Uri.decodeComponent(url.replaceFirst("image://", ""));

String getKodiInternalImageUrl(String source, Player player) {
    final newUrl = Uri.decodeComponent(source.replaceFirst("image://", ""));
    return "http://${player.address}:${player.port}/images/image://$newUrl";
}
