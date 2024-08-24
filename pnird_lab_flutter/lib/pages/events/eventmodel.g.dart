// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Eventmodel _$EventmodelFromJson(Map<String, dynamic> json) {
  return Eventmodel(
    caption: json['caption'] as String,
    image_url: json['image_url'] as String,
    titlepost: json['titlepost'] as String,
  );
}

Map<String, dynamic> _$EventmodelToJson(Eventmodel instance) => <String, dynamic>{
      'caption': instance.caption,
      'titlepost': instance.titlepost,
      'image_url': instance.image_url,
    };
