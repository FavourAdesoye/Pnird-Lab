import 'package:json_annotation/json_annotation.dart'; 

//used to create a new file where we store the json data from the database
part 'eventmodel.g.dart'; 

@JsonSerializable()
class Eventmodel { 
  String caption; 
  String titlepost; 
  // ignore: non_constant_identifier_names
  String image_url;

  // ignore: non_constant_identifier_names
  Eventmodel({required this.caption,required this.image_url, required this.titlepost}); 

  factory Eventmodel.fromJson(Map<String, dynamic> json) => _$EventmodelFromJson(json);
  
  Map<String, dynamic> toJson() => _$EventmodelToJson(this);
}