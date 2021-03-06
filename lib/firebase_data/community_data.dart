import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/event.dart';

import 'webblen_notification_data.dart';

class CommunityDataService {
  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference locRef = Firestore.instance.collection("locations");
  final CollectionReference eventRef = Firestore.instance.collection("events");
  final CollectionReference usersRef = Firestore.instance.collection("webblen_user");
  final CollectionReference communityNewsDataRef = Firestore.instance.collection("community_news");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<String> createCommunity(Community community, String areaName, String uid) async {
    String error = "";
    Map<dynamic, dynamic> userComs;
    List userAreaComs;
    DocumentSnapshot userDoc = await usersRef.document(uid).get();
    userComs = userDoc.data['d']['communities'];
    userAreaComs = userComs[areaName] != null ? userComs[areaName].toList(growable: true) : [];
    userAreaComs.add(community.name);
    userComs[areaName] = userAreaComs;
    await locRef.document(areaName).collection('communities').document(community.name).setData(community.toMap()).whenComplete(() {}).catchError((e) {
      error = e.details.toString();
    });
    await usersRef.document(uid).updateData({'d.communities': userComs}).whenComplete(() {}).catchError((e) {
          error = e.details;
        });
    return error;
  }

  Future<String> getCommunityImageURL(String areaName, String comName) async {
    String imageURL;
    DocumentSnapshot comDoc = await locRef.document(areaName).collection('communities').document(comName).get();
    if (comDoc.exists) {
      if (comDoc.data['comImage'] != null) {
        imageURL = comDoc.data['comImage'];
      }
    }
    return imageURL;
  }

  Future<Null> setCommunityImageURL(String areaName, String comName, String imageURL) async {
    locRef.document(areaName).collection('communities').document(comName).updateData(({'comImage': imageURL}));
  }

  Future<Community> getCommunityByName(String areaName, String comName) async {
    Community com;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getCommunityByName');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': modifiedComName});
    if (result.data != null) {
      Map<String, dynamic> comMap = Map<String, dynamic>.from(result.data);
      com = Community.fromMap(comMap);
    }
    return com;
  }

  Future<List<Community>> getUserCommunities(String uid) async {
    List<Community> coms = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserCommunities');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> comMap = Map<String, dynamic>.from(resultMap);
        Community com = Community.fromMap(comMap);
        coms.add(com);
      });
    }
    return coms;
  }

  Future<List<Community>> getNearbyCommunities(double lat, double lon) async {
    List<Community> coms = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getNearbyCommunities');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'lat': lat, 'lon': lon});
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> comMap = Map<String, dynamic>.from(resultMap);
        Community com = Community.fromMap(comMap);
        coms.add(com);
      });
    }
    return coms;
  }

  Future<List<Event>> getUpcomingCommunityEvents(String areaName, String comName) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUpcomingCommunityEvents');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': comName});
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> eventMap = Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(eventMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<RecurringEvent>> getRecurringCommunityEvents(String areaName, String comName) async {
    List<RecurringEvent> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getRecurringCommunityEvents');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': comName});
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> eventMap = Map<String, dynamic>.from(resultMap);
        RecurringEvent event = RecurringEvent.fromMap(eventMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<bool> checkIfCommunityExists(String areaName, String comName) async {
    bool exists = false;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'checkIfCommunityExists');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': modifiedComName});
    if (result.data != null) {
      exists = result.data;
    }
    return exists;
  }

  Future<bool> updateCommunityFollowers(String areaName, String comName, String uid) async {
    bool success = false;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'updateCommunityFollowers');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': modifiedComName, 'uid': uid});
    if (result.data != null) {
      success = result.data;
    }
    return success;
  }

  Future<bool> updateCommunityMembers(String areaName, String comName, String uid) async {
    bool success = false;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'updateCommunityMembers');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': modifiedComName, 'uid': uid});
    if (result.data != null) {
      success = result.data;
    }
    return success;
  }

  Future<bool> leaveCommunity(String areaName, String comName, String uid) async {
    bool success = false;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'leaveCommunity');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': modifiedComName, 'uid': uid});
    if (result.data != null) {
      success = result.data;
    }
    return success;
  }

  Future<bool> joinCommunity(String areaName, String comName, String uid) async {
    bool success = false;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'joinCommunity');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'areaName': areaName, 'comName': modifiedComName, 'uid': uid});
    if (result.data != null) {
      success = result.data;
    }
    return success;
  }

  Future<List<CommunityNewsPost>> getPostsFromCommunity(String areaName, String communityName) async {
    List<CommunityNewsPost> posts = [];
    QuerySnapshot querySnapshot =
        await communityNewsDataRef.where("areaName", isEqualTo: areaName).where("communityName", isEqualTo: communityName).getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.forEach((newsDoc) {
        CommunityNewsPost newsPost = CommunityNewsPost.fromMap(newsDoc.data);
        posts.add(newsPost);
      });
    }
    return posts;
  }

  Future<List<Event>> getEventsFromCommunities(String areaName, String communityName) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await eventRef
        .where("communityAreaName", isEqualTo: areaName)
        .where("communityName", isEqualTo: communityName)
        .where('recurrence', isEqualTo: 'none')
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.forEach((eventDoc) {
        Event event = Event.fromMap(eventDoc.data);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Community>> searchForCommunityByName(String searchTerm, String areaName) async {
    List<Community> communities = [];
    String modifiedSearchTerm = searchTerm.contains("#") ? searchTerm : "#$searchTerm";
    DocumentSnapshot docSnap = await locRef.document(areaName).collection('communities').document(modifiedSearchTerm).get();
    if (docSnap.exists && docSnap.data['status'] == "active") {
      Community com = Community.fromMap(docSnap.data);
      communities.add(com);
    }
    return communities;
  }

  Future<List<Community>> searchForCommmunityByTag(String searchTerm, String areaName) async {
    List<Community> communities = [];
    QuerySnapshot querySnapshot = await locRef.document(areaName).collection('communities').where("subtags", arrayContains: searchTerm).getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.forEach((docSnap) {
        if (docSnap.data['status'] == "active") {
          Community com = Community.fromMap(docSnap.data);
          communities.add(com);
        }
      });
    }
    return communities;
  }

  Future<String> uploadNews(File newsImage, CommunityNewsPost communityNews) async {
    String error = "";
    final String postID = "${Random().nextInt(999999999)}";
    String fileName = "$postID.jpg";
    communityNews.postID = postID;
    if (newsImage != null) {
      String downloadUrl = await uploadNewsImage(newsImage, fileName);
      communityNews.imageURL = downloadUrl;
    }
    await Firestore.instance.collection("community_news").document(postID).setData(communityNews.toMap()).whenComplete(() {}).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> uploadNewsImage(File eventImage, String fileName) async {
    StorageReference ref = storageReference.child("community_news").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(eventImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  Future<String> updateCommunityEventActivity(List tags, String areaName, String comName) async {
    String error = "";
    List comTags = [];
    List newTagList;
    int activityCount = 0;
    int eventCount = 0;
    DocumentSnapshot comDoc = await locRef.document(areaName).collection('communities').document(comName).get();
    comTags = comDoc.data['subtags'] == null ? [] : comDoc.data['subtags'];
    activityCount = comDoc.data['activityCount'] == null ? 0 : comDoc.data['activityCount'];
    eventCount = comDoc.data['eventCount'] == null ? 0 : comDoc.data['eventCount'];
    activityCount += 1;
    eventCount += 1;
    newTagList = List.from(comTags)..addAll(tags);
    List uniqueTags = newTagList.toSet().toList();
    await locRef
        .document(areaName)
        .collection("communities")
        .document(comName)
        .updateData({"subtags": uniqueTags, "activityCount": activityCount, "eventCount": eventCount})
        .whenComplete(() {})
        .catchError((e) {
          error = e.toString();
        });
    return error;
  }

  Future<CommunityNewsPost> getPost(String postID) async {
    CommunityNewsPost newPost;
    DocumentSnapshot comDoc = await communityNewsDataRef.document(postID).get();
    if (comDoc.exists) {
      newPost = CommunityNewsPost.fromMap(comDoc.data);
    }
    return newPost;
  }

  Future<String> deletePost(String postID, String areaName, String comName) async {
    String error = "";
    await WebblenNotificationDataService().deletePostNotifications(postID, areaName, comName);
    await communityNewsDataRef.document(postID).delete();
    await storageReference.child("community_news").child('$postID.jpg').delete();
    return error;
  }

  Future<Null> mergeMembersAndFollowers() async {
    QuerySnapshot locQuery = await locRef.getDocuments();
    locQuery.documents.forEach((locDoc) async {
      QuerySnapshot comQuery = await locRef.document(locDoc.documentID).collection('communities').getDocuments();
      comQuery.documents.forEach((comDoc) async {
        List members = [];
        List followers = [];
        if (comDoc.data['memberIDs'] != null) {
          members = comDoc.data['memberIDs'].toList(growable: true);
        }
        if (comDoc.data['followers'] != null) {
          followers = comDoc.data['followers'].toList(growable: true);
        }
        List mergedMembersList = List.from(members)..addAll(followers);
        List newMembersList = mergedMembersList.toSet().toList(growable: true);
        await locRef.document(locDoc.documentID).collection('communities').document(comDoc.documentID).updateData({'memberIDs': newMembersList});
      });
    });
  }

  Future<Null> updateUserMemberships() async {
    QuerySnapshot locQuery = await locRef.getDocuments();
    locQuery.documents.forEach((locDoc) async {
      QuerySnapshot comQuery = await locRef.document(locDoc.documentID).collection('communities').getDocuments();
      comQuery.documents.forEach((comDoc) async {
        List members = [];
        List followers = [];
        if (comDoc.data['memberIDs'] != null) {
          members = comDoc.data['memberIDs'].toList(growable: true);
        }
        members.forEach((uid) async {
          DocumentSnapshot userDoc = await usersRef.document(uid).get();
          Map<dynamic, dynamic> userData = userDoc.data['d'];
          Map<dynamic, dynamic> userComs = userData['communities'];
          if (userComs[locDoc.documentID] != null) {
            List userAreaComs = userComs[locDoc.documentID].toList(growable: true);
            if (!userAreaComs.contains(comDoc.documentID)) {
              userAreaComs.add(comDoc.documentID);
              userComs[locDoc.documentID] = userAreaComs;
              await usersRef.document(uid).updateData({'d.communities': userComs});
            }
          }
        });
      });
    });
  }
}
