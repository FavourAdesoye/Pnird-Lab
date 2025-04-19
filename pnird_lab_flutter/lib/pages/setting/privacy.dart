import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/setting/settings.dart'; 

class Privacypage extends StatelessWidget { 
  const Privacypage({super.key}); 

  @override
  Widget build(BuildContext context) { 
        return const MaterialApp(  home: _Privacypage());
  }
} 

class _Privacypage extends StatefulWidget { 
  
  const _Privacypage(); 

  @override
  _PrivacypageState createState() => _PrivacypageState();
} 

class _PrivacypageState extends State<_Privacypage> { 
    @override
    Widget build(BuildContext context) { 
      return  Scaffold( 
        backgroundColor: Colors.black,  
        appBar: AppBar( 
          
          backgroundColor: Colors.black, 
          title: const Align(alignment:Alignment.centerRight, child:  Text("Privacy Policy",style: TextStyle(color: Colors.white),)),
           leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
             Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage())
                );
          },
        ),
         ), 
          
        body:  const Center( child: CardExample())
      );
    }
} 

class CardExample extends StatelessWidget { 
  const CardExample({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Center( 
      child: Column( 
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [ 
          Card( 
             color:  Color.fromARGB(255, 245, 207, 40), 
              clipBehavior: Clip.hardEdge, 
              child: InkWell( 
                child: SizedBox( 
                  width: 1000, 
                  height: 700,  
                  child: SingleChildScrollView(
                   child: Center( 
                    child: Column(  
                      mainAxisAlignment: MainAxisAlignment.center, 
                        children:  [Text(
                            'Privacy Policy',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                              ),  SizedBox(height: 12),

                              Text(
                                'This privacy policy applies to the Pnird Lab app ("Application") created by the Service Provider as a Free service. This service is intended for use AS IS.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Information Collection and Use', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'The Application collects information when you download and use it, including your IP address, pages visited, time and date, time spent, and your operating system.',
                              style: TextStyle(color: Colors.black),
                              ),
                              Text(
                              'The Application does not gather precise location information of your mobile device.',
                              style: TextStyle(color: Colors.black),
                              ),
                              Text(
                              'The Service Provider may use the information to contact you with important information, notices, or marketing promotions.',
                              style: TextStyle(color: Colors.black),
                              ),
                              Text(
                              'The Service Provider may require personally identifiable information. This will be retained and used as described in this policy.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Third Party Access', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'Aggregated, anonymized data may be transmitted to external services to improve the Application. Information may be shared as described in this policy.',
                              style: TextStyle(color: Colors.black),
                              ),
                              Text(
                              'Information may be disclosed: to comply with legal processes; to protect rights, safety, or investigate fraud; with trusted providers bound by this policy.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Opt-Out Rights', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'You can stop information collection by uninstalling the Application using standard processes on your device or app store.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Data Retention Policy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'User data is retained while you use the Application and for a reasonable time thereafter. For deletion, contact atiliaa.thomas@gmail.com.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Children', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'The Service Provider does not knowingly collect data from children under 13. Parents should monitor childrens' ' internet usage. If data was provided by a child, contact atiliaa.thomas@gmail.com.',
                              style: TextStyle(color: Colors.black),
                              ),
                              Text(
                              'Users must be at least 16 to consent to data processing, or have consent from a parent/guardian.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Security', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'The Service Provider uses physical, electronic, and procedural safeguards to protect your information.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Changes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'This Privacy Policy may be updated periodically. Changes will be reflected on this page. Continued use constitutes acceptance of changes.',
                              style: TextStyle(color: Colors.black),
                              ),
                              Text(
                              'Effective date: 2025-01-10',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Your Consent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'By using the Application, you consent to the processing of your information as described in this Privacy Policy.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                              Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(
                              'If you have questions about privacy, contact atiliaa.thomas@gmail.com.',
                              style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 12),
                            Text(
                            'This privacy policy page was generated by App Privacy Policy Generator.',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                              )    ,
                    ])))

                )
              )

          )
        ],
      )
    ) 
    );
  }

}