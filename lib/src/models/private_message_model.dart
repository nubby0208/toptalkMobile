//created by Hatem Ragap
import 'package:flutter/foundation.dart';

class PrivateMessageModel extends ChangeNotifier {

  String id;
  String message;
  int messageType;
  Object imgs;
  String senderId;
  String receiverId;
  int createdAt;
  String roomId;
  String sendTime;
  String sendDate;
  int isDeleted;

  PrivateMessageModel(
      {
      this.id,
      this.message,
        this.messageType,
      this.imgs,
      this.senderId,
        this.receiverId,
      this.createdAt,
        this.isDeleted,
      this.roomId, this.sendDate, this.sendTime});


  factory PrivateMessageModel.fromMap(Map<String, dynamic> map) {
    return   PrivateMessageModel(
      id: map['_id'] as String,
      message: map['message'] as String,
        messageType: map['message_type'] as int,
      imgs: map['imgs'] as Object,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      createdAt: map['created'] as int,
        isDeleted: map['isDeleted'] as int,
        roomId: map['room_id'] as String,
        sendDate: map['send_date'] as String,
        sendTime: map['send_time'] as String,
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
