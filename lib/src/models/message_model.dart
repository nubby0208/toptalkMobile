//created by Hatem Ragap
import 'package:flutter/foundation.dart';

class MessageModel extends ChangeNotifier {

  String id;
  String messageId;
  String message;
  String img;
  Object imgs;
  String senderId;
  String senderName;
  String coverage;
  String distance;
  String distanceUnit;
  String email;
  String nickname;
  String gender;
  int like;
  int dislike;
  String credit;
  bool online;
  String avatarUrl;
  String timeDiff;
  int createdAt;
  String roomId;
  String timeUnit;

  MessageModel(
      {
      this.id,
      this.messageId,
      this.message,
      this.img,
      this.imgs,
      this.senderId,
      this.senderName,
      this.email,
      this.coverage,
      this.distance,
      this.distanceUnit,
      this.nickname,
        this.gender,
      this.like,
      this.credit,
      this.dislike,
      this.online,
      this.avatarUrl,
      this.timeDiff,
      this.createdAt,
      this.roomId,this.timeUnit

      });


  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return   MessageModel(
      id: map['_id'] as String,
      messageId: map['_id'] as String,
      message: map['message'] as String,
      img: map['img'] as String,
      imgs: map['imgs'] as Object,
      senderId: map['sender_id'] as String,
      senderName: map['nickname'] as String,
      email: map['email'] as String,
      coverage: map['coverage'] as String,
      distance: map['distance'] as String,
      distanceUnit: map['distance_unit'] as String,
      nickname: map['nickname'] as String,
      gender: map['gender'].toString(),
      like: map['like'] as int,
      dislike: map['dislike'] as int,
      credit: map['credit'] as String,
      online: map['online'] as bool,
      avatarUrl: map['avatarUrl'] as String,
      timeDiff: map['timeDiff'] as String,
        timeUnit: map['timeUnit'] as String,

        createdAt: map['createdAt'] as int,
        roomId: map['room_id'] as String
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
