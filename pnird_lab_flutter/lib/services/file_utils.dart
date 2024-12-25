
// This function checks if the file has a valid type (PNG or JPEG)
void checkFileType(String filePath) {
  final fileExtension = filePath.split('.').last.toLowerCase();

  // Valid file types (image/png, image/jpeg)
  if (!['jpg', 'jpeg', 'png'].contains(fileExtension)) {
    throw Exception("Unsupported file type: $fileExtension");
  }
  print('File type is valid: $fileExtension');
}
