/// Request a smaller Cloudinary rendition for on-screen display.
/// Non-Cloudinary URLs are returned unchanged.
String cloudinaryDisplayUrl(String url, {int width = 800}) {
  if (url.isEmpty) return url;

  const marker = '/image/upload/';
  final index = url.indexOf(marker);
  if (index == -1 || !url.contains('res.cloudinary.com')) {
    return url;
  }

  final rest = url.substring(index + marker.length);
  // Already transformed.
  if (rest.startsWith('w_') || rest.startsWith('c_') || rest.startsWith('q_')) {
    return url;
  }

  final safeWidth = width.clamp(64, 1600);
  return '${url.substring(0, index + marker.length)}'
      'w_$safeWidth,c_limit,q_auto,f_auto/$rest';
}
