import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

class MessageBody extends StatefulWidget {
  final String messageId;
  final String messageSubject;
  final gmail.GmailApi api;

  const MessageBody(
      {Key? key,
      required this.api,
      required this.messageId,
      required this.messageSubject})
      : super(key: key);

  @override
  _MessageBodyState createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
  final Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
  late Future<void> myFuture;
  late String messageBody;

  @override
  void initState() {
    super.initState();
    myFuture = init();
  }

  Future<void> init() async {
    messageBody = await _getMessageBody();
  }

  Future<String> _getMessageBody() async {
    gmail.Message msg = await widget.api.users.messages.get('me', widget.messageId, format: 'full');

    // checking if file is a multipart or is a simple text/html file..
    if (msg.payload?.mimeType == 'text/html' || msg.payload?.mimeType == 'text/plain') {
      String decodedString =
          stringToBase64Url.decode("${msg.payload?.body?.data}");

      return decodedString;
    }
    else {
      // the message is a multipart message
      List<gmail.MessagePart>? parts = msg.payload?.parts;

      String decodedString = "";

      for (gmail.MessagePart part in parts!) {
        if (part.mimeType == 'text/html') {
          decodedString += stringToBase64Url.decode("${part.body?.data}");
        }
      }
  
      return decodedString;
    }
  }
  
  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
      future: myFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done ) {
          
            return WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: 'about:blank',
              onWebViewCreated: (WebViewController webViewController) {
                webViewController.loadHtmlString(messageBody);
              },
              zoomEnabled: true,
          );
        } else if (snapshot.hasError) {
          return Card(
            elevation: 10,
            child: Container(
              alignment: Alignment.center,
              child: Text(snapshot.error.toString()),
            ),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.messageSubject),
        elevation: 1,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: buildFutureBuilder(),
    );
  }
}
