import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;
import 'package:hive/hive.dart';
import 'package:letter_shelf/utils/hive_services.dart';

import '../utils/OAuthClient.dart';
import '../utils/Utils.dart';

class ProfileCard extends StatefulWidget {
  final double bottomPadding;
  final gmail.GmailApi gmailApi;
  final people.PeopleServiceApi peopleApi;

  const ProfileCard(
      {Key? key,
      required this.bottomPadding,
      required this.gmailApi,
      required this.peopleApi})
      : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with AutomaticKeepAliveClientMixin {
  String userName = "";
  String userEmail = "";
  Image? profilePhoto;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    try {
      HiveServices hiveService = HiveServices();

      userEmail = await OAuthClient.getCurrentUserNameFromApi(widget.gmailApi);

      // checking if email messages are already cached
      bool exists = await hiveService.isExists(boxName: "profile_data" + userEmail);
      // exists = false;

      // checking if user has internet connection
      bool hasInternet = await Utils.hasNetwork();

      if ( (Utils.firstProfileScreenLoad && !hasInternet && exists) || (!Utils.firstProfileScreenLoad && exists)) {
        Map<dynamic, dynamic> result = (await hiveService.getBoxes("profile_data" + userEmail ))[0];

        setState(() {
          userEmail = result['email'];
          userName = result['username'];
          profilePhoto = Image.memory(result['photo']);
        });
      }
      else {
        Utils.firstProfileScreenLoad = false;

        // getting username from People api
        people.Person person = await widget.peopleApi.people.get('people/me', personFields: 'names,photos');

        // setting user's profile Photo
        List<people.Photo>? photos = person.photos;

        Uint8List bytes =
            (await NetworkAssetBundle(Uri.parse(photos![0].url.toString()))
                .load(photos[0].url.toString()))
                .buffer
                .asUint8List();

        // clearing previous data from the boxes
        Box _box = await Hive.openBox("profile_data" + userEmail );

        _box.deleteAll(_box.keys);

        // adding data to box
        hiveService.addBoxes([
          {
            'username': person.names![0].displayName,
            'email': userEmail,
            'photo': bytes,
          }
        ], "profile_data" + userEmail );

        setState(() {
          profilePhoto = Image.memory(bytes);
          userName = person.names![0].displayName!;
        });
      }
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.34 - widget.bottomPadding > 190 ? MediaQuery.of(context).size.height * 0.34 - widget.bottomPadding  : 190,
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.06,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: profilePhoto ?? Container( color: Colors.grey,),
                ),
              ),
            ),


            Container(
              padding: const EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
             
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.center,
                    child: Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(

                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 20, top: 5, left: 10),
                    child: Text(
                      userEmail,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      strutStyle: const StrutStyle(
                        height: 1,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
