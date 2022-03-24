import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis/people/v1.dart' as people;

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

class _ProfileCardState extends State<ProfileCard> {
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
      // getting user email from gmail api
      gmail.Profile userProfile = await widget.gmailApi.users.getProfile('me');

      // getting username from People api
      people.Person person = await widget.peopleApi.people
          .get('people/me', personFields: 'names,photos');

      // setting user's profile Photo
      List<people.Photo>? photos = person.photos;

      setState(() {
        profilePhoto = Image.network(photos![0].url.toString());
        userEmail = userProfile.emailAddress!;
        userName = person.names![0].displayName!;
      });
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22 - widget.bottomPadding,
      child: Card(
        elevation: 3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.05,
                child: ClipRRect( borderRadius: BorderRadius.circular(50), child: profilePhoto, ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.59,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 15, bottom: 5, left: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
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
}
