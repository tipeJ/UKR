String decodeExternalImageUrl(String url) => Uri.decodeComponent(url.replaceFirst("image://", ""));
