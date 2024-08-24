// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutternativesplash/components/allowbutton.dart';
import 'package:flutternativesplash/pages/createpost/share_post.dart';

//class ViewImage extends StatefulWidget {
//  const ViewImage({super.key});

//  @override
//  ViewImage1 createState() => ViewImage1();

//  Widget build(BuildContext){
//    return MaterialApp(
//     home: ViewImage1()
//   );
//  }

//}

class ViewImage extends StatelessWidget {
  final File? image;

  const ViewImage({super.key, this.image});

  @override
  Widget build(context) {
    return const MaterialApp(home: ViewImagePage());
  }
}

// ignore: must_be_immutable
class ViewImagePage extends StatelessWidget {
  final File? image;

  const ViewImagePage({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    return Scaffold(
        //  home: Scaffold(
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
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (image != null)
                        const Text(
                          "New Post",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                      Center(
                        child: Image.file(image!),
                      ),
                      const SizedBox(height: 70),
                      //  Row(
                      //    mainAxisAlignment: MainAxisAlignment.start,
                      //    children: [
                      //      ElevatedButton(
                      //        onPressed: () { Navigator.pop(context);},
                      //        child: Image.asset(
                      //           'flutternativesplash/assets/Close.png'),
                      //      ),
                      //    ],
                      //  ),
                      AllowBtn(
                        btnText: 'Next',
                        btnFun: () => Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (context) => SharePost(image: image)),
                        ),
                      ),

                      //  Row(
                      //    mainAxisAlignment: MainAxisAlignment.start,
                      //    children: [ElevatedButton(onPressed: null,
                      //    child: Image.asset('')) ]),

                      //  NextBtn(btnnext: () => null,
                      //  nextText: 'Next')
                    ]))));

    //  );
  }
}
