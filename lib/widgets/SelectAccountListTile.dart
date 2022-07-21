import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:hive/hive.dart';
import 'package:letter_shelf/utils/OAuthClient.dart';
import 'package:letter_shelf/utils/hive_services.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/Utils.dart';

class SelectAccountListTile extends StatefulWidget {
  final String username;

  const SelectAccountListTile(
      {Key? key,
      required this.username,})
      : super(key: key);

  @override
  _SelectAccountListTileState createState() => _SelectAccountListTileState();
}

class _SelectAccountListTileState extends State<SelectAccountListTile> {
  late gmail.GmailApi gmailApi;
  late people.PeopleServiceApi peopleApi;

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

      userEmail = widget.username;

      OAuthClient client = OAuthClient(username: widget.username);
      AutoRefreshingAuthClient _authClient =  await client.getClient();

      // loading the Google's Gmail API
      gmailApi = client.getGmailApi(_authClient);

      // loading the Google's People API
      peopleApi = client.getPeopleApi(_authClient);

      // checking if email messages are already cached
      Hive.init((await getApplicationDocumentsDirectory()).path);
      bool exists = await hiveService.isExists(boxName: "profile_data" + userEmail);

      if (exists) {
        Map<dynamic, dynamic> result = (await hiveService.getBoxes("profile_data" + userEmail))[0];

        setState(() {
          userEmail = result['email'];
          userName = result['username'];
          profilePhoto = Image.memory(result['photo']);
        });
      } else {
        Utils.firstProfileScreenLoad = false;

        // getting username from People api
        people.Person person = await peopleApi.people
            .get('people/me', personFields: 'names,photos');

        // setting user's profile Photo
        List<people.Photo>? photos = person.photos;

        Uint8List bytes = (await NetworkAssetBundle(Uri.parse(photos![0].url.toString()))
                    .load(photos[0].url.toString()))
                .buffer
                .asUint8List();

        // clearing previous data from the boxes
        Box _box = await Hive.openBox("profile_data" + userEmail);

        _box.deleteAll(_box.keys);

        // adding data to box
        hiveService.addBoxes([
          {
            'username': person.names![0].displayName,
            'email': userEmail,
            'photo': bytes,
          }
        ], "profile_data" + userEmail);

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
    return Card(
      elevation: 9,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: SizedBox(

            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: profilePhoto ?? Container( color: Colors.grey,),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 4.0,),
            child: Text(
              userName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
              ),
            ),
          ),
          subtitle: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
            child: Text(
              userEmail,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          trailing: GestureDetector(
            onTap: () {

            },
            child: Container(
              width: 30,
              child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 30,
                ),
            ),
          ),
        ),
      ),
    );
  }
}
