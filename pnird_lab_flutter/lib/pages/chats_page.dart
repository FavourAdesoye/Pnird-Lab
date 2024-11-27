// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnirdlab/widgets/user_avatar.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 60, left: 5, right: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            )),
                        UserAvatar(
                          filename: 'drKeen.jpg',
                        ),
                      ]))
            ],
          ),
          Positioned(
              top: 110,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 21, 21, 21),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.amber),
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.only(right: 20, left: 20)),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                      side: BorderSide(color: Colors.red)))),
                          onPressed: () {},
                          child: Text(
                            "Messages",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Color.fromARGB(255, 52, 52, 52)),
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.only(right: 20, left: 20)),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.amber),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ))),
                          onPressed: () {},
                          child: Text(
                            "Notifications",
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ]),
                  Expanded(
                      child: ListView(
                    padding: EdgeInsets.only(left: 10, top: 25),
                    children: [
                      Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 52, 52, 52),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const UserAvatar(filename: 'drKeen.jpg'),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Alexis Morris",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Hello Dr. keen",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 169, 169, 169)),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              Column(children: const [
                                Text(
                                  '16:35',
                                  style: TextStyle(fontSize: 10),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                CircleAvatar(
                                  radius: 7,
                                  backgroundColor: Colors.amber,
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                )
                              ])
                            ],
                          ))
                    ],
                  ))
                ]),
              ))
        ],
      ),
    );
  }
}
