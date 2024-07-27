//imports the GetX library, which provides functionality for state management
import 'package:get/get.dart'; 

//creates a new class that extends GetXcontroller 
class ButtonController extends GetxController { 
//this variable holds the current post type
  String _postType = 'event_post';  

//a getter method is defined to access the value of postype from outside the class
  String get postType => _postType;  
//the setter method is created to update the value of postType
    void setPostType(String type) { 
      _postType = type; 
      update();

  }
}