import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pnirdlab/components/button_controller.dart';
import 'package:http/http.dart' as http;
import "config.dart";

class SharePost extends StatelessWidget {
  final File? image;

  const SharePost({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return SharepostPage(
      image: image,
    );
  }
}

class SharepostPage extends StatefulWidget {
  final File? image;

  // ignore: prefer_const_constructors_in_immutables
  SharepostPage({super.key, this.image});

  @override
  // ignore: library_private_types_in_public_api
  _SharepostPageState createState() => _SharepostPageState();
}

class _SharepostPageState extends State<SharepostPage> {
  TextEditingController titlepost = TextEditingController();
  TextEditingController caption = TextEditingController();
  bool _isNotValidate = false;

  Map<String, Function> postTypeMap = {};

  @override
  void initState() {
    super.initState();
    print("initState called, initializing postTypeMap");
    postTypeMap = {
      'event_post': registerEventPost,
      'profile_post': registerProfilePost,
      'study_post': registerStudyPost,
    };
  }

//sends event post to the backend
  void registerEventPost() async {
    print("Entered registerEventpost");
    if (titlepost.text.isNotEmpty && caption.text.isNotEmpty) {
      print("Titlepost and caption: $titlepost $caption ");
      var reqBody = {
        "image_url": widget.image?.path ?? "",
        "caption": caption.text,
        "titlepost": titlepost.text,
        "date_time": DateTime.now().toIso8601String(),
      };

      print("This is the $reqBody");
      //Perform the HTTP request
      // Perform the HTTP request
      try {
        print("Sending HTTP request...");
        final response = await http.post(
          Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );

        // Check if the response is successful
        if (response.statusCode == 200) {
          print("Event Post Response: ${response.statusCode} ${response.body}");
        } else {
          print(
              "Failed to post event: ${response.statusCode} ${response.body}");
        }
      } catch (e) {
        print("Error during HTTP request: $e");
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
      print("Validation failed: titlepost or caption is empty");
    }
  }

  void registerProfilePost() async {
    if (titlepost.text.isNotEmpty && caption.text.isNotEmpty) {
      var reqBody = {
        "image_url": widget.image?.path ?? "",
        "caption": caption,
        "titlepost": titlepost,
      };

      //Perform the HTTP request
      final response = await http.post(Uri.parse(registration1),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));
      print("Profile Post Response: ${response.statusCode} ${response.body}");
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  void registerStudyPost() async {
    if (titlepost.text.isNotEmpty && caption.text.isNotEmpty) {
      var reqBody = {
        "image_url": widget.image?.path ?? "",
        "caption": caption,
        "titlepost": titlepost,
      };
      //Perform the HTTP request
      var response = await http.post(Uri.parse(registration2),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      print("Error registering study post: $response");
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  //Map to associate the post types with their functions

  void registerPost(ButtonController buttonController) {
    print("Registering post of type: ${buttonController.postType}");
    print("postTypeMap: $postTypeMap");
    final postFunction = postTypeMap[buttonController.postType];
    if (postFunction != null) {
      print("Found function for post type: ${buttonController.postType}");
      postFunction();
    } else {
      print("Unknown post type");
    }
    //Map to associate the post types with their functions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.image != null) ...[
                  const Text(
                    "New Post",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: Image.file(widget.image!),
                  ),
                  const SizedBox(height: 70),
                  TextFormField(
                    controller: titlepost,
                    decoration: const InputDecoration(
                      labelText: 'Title of Post',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),

                  TextFormField(
                    controller: caption,
                    decoration: const InputDecoration(
                      labelText: 'Write a caption....',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  // Row(
                  //  children: [
                  //    ElevatedButton(
                  //      onPressed: () {
                  //        Navigator.pop(context);
                  //      },
                  //      child: const Icon(Icons.account_circle_outlined),
                  //     ),
                  //]),

                  GetBuilder<ButtonController>(
                      init: ButtonController(),
                      builder: (buttonController) {
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child:
                                    const Icon(Icons.account_circle_outlined),
                              ),
                              GestureDetector(
                                onTap: () {
                                  buttonController.setPostType('event_post');
                                },
                                child: Icon(
                                  Icons.library_books,
                                  color: buttonController.postType ==
                                          'event_post'
                                      ? const Color.fromARGB(255, 70, 69, 60)
                                      : Colors.white,
                                  size: 40,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  buttonController.setPostType('profile_post');
                                },
                                child: Icon(
                                  Icons.calendar_month,
                                  color: buttonController.postType ==
                                          'profile_post'
                                      ? const Color.fromARGB(255, 70, 69, 60)
                                      : Colors.white,
                                  size: 40,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  buttonController.setPostType('study_post');
                                },
                                child: Icon(
                                  Icons.account_circle_outlined,
                                  color: buttonController.postType ==
                                          'study_post'
                                      ? const Color.fromARGB(255, 70, 69, 60)
                                      : Colors.white,
                                  size: 40,
                                ),
                              ),
                            ]);
                      }),

                  const SizedBox(height: 30),
                  ElevatedButton(
                      onPressed: () {
                        final buttonController = Get.find<ButtonController>();
                        registerPost(buttonController);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 245, 207, 40),
                        backgroundColor: Colors.black,
                      ),
                      child: const Text('Share')),
                ],
              ],
            ),
          ),
        ));
  }
}
