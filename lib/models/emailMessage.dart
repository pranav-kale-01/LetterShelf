import 'package:intl/intl.dart';

class EmailMessage {
  final String msgId;
  final String image;
  final String subject;
  late DateTime date;
  late String emailId;
  late String from;
  bool unread;
  bool starred;
  bool important;

  EmailMessage( {required this.msgId, required String from, required this.image, required this.subject, required date, this.unread = true, this.starred = false, this.important = false }) {
    int index = from.indexOf( '<' );

    // in some cases the from field only has the address of the send and not the name
    // "Amazon.in" <shipment-tracking@amazon.in>
    // <cbssbi.cas@sbi.co.in>
    if( index == 0 ) {
      this.from = from.substring(index+1, from.indexOf('@') );
    }
    else if( index == -1 ) {
      this.from = from;
    }
    else {
      this.from = from.substring(0, index-1);
    }

    emailId = from.substring( index+1, from.length - 1 );

    if( date.runtimeType == DateTime ) {
      this.date = date;
    }
    else {
      List<String> formatString = ['EEE, d MMM y H:m:s', 'd MMM y H:m:s', 'EEE,  d MMM y H:m:s'];
      int count =0;

      while( true ) {
        try {
          final dateFormat =  DateFormat( formatString[count] );
          this.date = dateFormat.parse( date );
          break;
        }
        catch( e, stacktrace ) {
          count+=1;
          continue;
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    return { 'msgId' : msgId, 'image': image, 'subject': subject, 'date': date, 'emailId': emailId, 'from' : from, 'unread': unread };
  }
}