import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathlib;
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imagelib;

class EditPost extends StatefulWidget {
  final File? image;

  const EditPost({super.key, required this.image});

  @override
  // ignore: library_private_types_in_public_api
  _EditPostState createState() => _EditPostState();
}

class EditPost1 extends StatelessWidget {
  final File? image;

  const EditPost1({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return EditPost(image: image); // Correctly pass the image to EditPost;
  }
}

class _EditPostState extends State<EditPost> {
  late String fileName;
  File? image;
  dynamic imageFile;

  @override
  void initState() {
    super.initState();
    image = widget.image;
    if (image != null) {
      imageFile = image;
    }
  }

  List<Filter> filters = presetFiltersList;

  Future<void> getImage(BuildContext context) async {
    if (imageFile == null) return;
    // if (decodedImage != null) {
    fileName = pathlib.basename(imageFile!.path);
    var decodedImage = imagelib.decodeImage(imageFile!.readAsBytesSync());
    //decodedImage = imagelib.copyResize(decodedImage!, width: 600);
    Map imagefile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoFilterSelector(
          title: const Text("Photo Filter Example"),
          image: decodedImage ?? imagelib.Image(50, 50),
          filters: presetFiltersList,
          filename: fileName,
          loader: const Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
      });
      print(imageFile.path);
    } else {
      print("Error decoding the image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Filter Example'),
      ),
      body: Center(
        child: Container(
          child: imageFile == null
              ? const Center(
                  child: Text('No image selected.'),
                )
              : Image.file(imageFile!),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'editpost_fab',
        onPressed: () => getImage(context),
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
