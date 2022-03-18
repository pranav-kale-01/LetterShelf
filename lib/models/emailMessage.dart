import 'package:intl/intl.dart';

class EmailMessage {
  final String msgId;
  final String image;
  final String subject;
  late DateTime date;
  late String emailId;
  late String from;
  bool unread = true;

  EmailMessage( {required this.msgId, required String from, required this.image, required this.subject, required date }) {
    int index = from.indexOf( '<' );

    this.from = from.substring( 0, index-1 );
    emailId = from.substring( index+1, from.length - 1 );

    final dateFormat =  DateFormat( 'EEE, d MMM y H:m:s' );

    this.date = dateFormat.parse( date );

    // var timeZoneOffset = DateTime.now().timeZoneOffset;

    // print( this.date );
    //
    // print( '${this.date.hour}:${this.date.minute}');
    // print( this.date.add(timeZoneOffset).millisecondsSinceEpoch / 1000 );
    // print( this.subject );
  }
}