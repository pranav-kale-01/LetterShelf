import 'package:intl/intl.dart';

class EmailMessage {
  final String msgId;
  final String image;
  final String subject;
  late DateTime date;
  late String emailId;
  late String from;
  bool unread;

  EmailMessage( {required this.msgId, required String from, required this.image, required this.subject, required date, this.unread = true }) {
    int index = from.indexOf( '<' );

    this.from = from.substring( 0, index-1 );
    emailId = from.substring( index+1, from.length - 1 );

    if( date.runtimeType == DateTime ) {
      this.date = date;
    }
    else {
      final dateFormat =  DateFormat( 'EEE, d MMM y H:m:s' );
      this.date = dateFormat.parse( date );
    }
  }

  Map<String, dynamic> toJson() {
    return { 'msgId' : msgId, 'image': image, 'subject': subject, 'date': date, 'emailId': emailId, 'from' : from, 'unread': unread };
  }
}