
import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/setting/notifications.dart';
import 'package:pnirdlab/pages/setting/privacy.dart';
import 'package:pnirdlab/pages/setting/profile.dart';



class SettingsPage extends StatelessWidget {
  // final User user;

  //const SettingsPage({super.key, required this.user});

  const SettingsPage({ super.key});
  @override
  Widget build(BuildContext context) { 
    return const MaterialApp( home: _SettingsPage());
  //  return  _SettingsPage(user: user,);
  }
}
class _SettingsPage extends StatefulWidget {
 // final User user;

//  const _SettingsPage({required this.user}); 

const _SettingsPage();


  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.black,
      appBar: AppBar( 
        backgroundColor: Colors.black,
        title: const Center(child: Text('Settings', style: TextStyle(color: Colors.white))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
             const SizedBox(height: 24),
            const Text(
              'Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ), 
           
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white),
              title: const Text('Privacy Policy', style:TextStyle(color:Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Privacypage())
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ), 
            
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white),
              title: const Text('Profile', style:TextStyle(color:Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profilepage())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none_outlined, color: Colors.white),
              title: const Text('Notifications', style:TextStyle(color:Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Notificationspage())
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none_outlined, color: Colors.white),
              title: const Text('Log Out', style:TextStyle(color:Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // Navigate to notifications page 
                
              },
            ), 

             ListTile(
              leading: const Icon(Icons.notifications_none_outlined, color: Colors.white),
              title: const Text('Delete Account', style: TextStyle(color:Colors.white),),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () {
                // Navigate to notifications page
              },
            ),
            const SizedBox(height: 24),
            
          ],
        ),
      ),
    );
  }
}
