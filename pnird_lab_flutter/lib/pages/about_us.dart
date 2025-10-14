import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/chatbot/main_chatbot.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          title: const Text('About us Page'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child:
                  Icon(Icons.android), // Robot-like icon similar to your image
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/pnird_group_photo.jpg',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // Text Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Get To Know Us',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Our Vision
                    Text(
                      'Our Vision',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'STC is a fully integrated growth focused pioneer of highly engineered advanced materials delivering',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    // Our Mission
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'STC is a fully integrated growth focused pioneer of highly engineered advanced materials delivering',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    // Our Capabilities
                    Text(
                      'Our Capabilities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'STC is a fully integrated growth focused pioneer of highly engineered advanced materials delivering',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ), 
                     
                  ],
                  
                ),
              ), 
                Card(
            color: const Color.fromARGB(255, 245, 207, 40),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Chathome()),
                );
              },
              child: const SizedBox(
                width: 300,
                height: 50,
                child: Center(
                  child: Text(
                    'Chat with AI',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
            ],
          ),
        ));
  }
}
