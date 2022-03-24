class SubscribedNewsletter {
  final String name;
  final String email;
  bool enabled;

  SubscribedNewsletter( {required this.name, required this.email, this.enabled = true } );

  Map<String,dynamic> toJson() {
    return {"name" : name, "email" : email, "enabled": enabled  };
  }
}