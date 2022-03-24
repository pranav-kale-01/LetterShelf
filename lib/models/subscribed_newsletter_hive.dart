import 'package:hive/hive.dart';

part 'subscribed_newsletter_hive.g.dart';

@HiveType( typeId: 0)
class SubscribedNewsletterHive {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String email;

  @HiveField(2)
  bool enabled;

  SubscribedNewsletterHive( {required this.name, required this.email, this.enabled = false } );
}