//created by Rizwan
import 'package:flutter/foundation.dart';

class numbermodel extends ChangeNotifier {

  String id;
  String number;
  bool isAssigned;
  int created;


  numbermodel(
      {
        this.id,
        this.number,
        this.created,
        this.isAssigned,

     });


  factory numbermodel.fromMap(Map<String, dynamic> map) {
    return   numbermodel(
        id: map['_id'] as String,
        number: map['number'] as String,
        created: map['created'] ,
        isAssigned: map['isAssigned'],


    );
  }

// Map<String, dynamic> toMap() {
//   // ignore: unnecessary_cast
//   return {
//     'id':  id,
//     'message':  message,
//     'messageType':  messageType,
//     'isDeleted':  isDeleted,
//     'senderId':  senderId,
//     'img':  img,
//     'receiverId':  receiverId,
//     'userName': userName,
//     'userImg':  userImg,
//     '_playerText':  _playerText,
//     'currentIcon':  currentIcon,
//   } as Map<String, dynamic>;
// }
}
