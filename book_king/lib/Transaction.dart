import 'dart:convert';

Transaction bookFromJson(String str) => Transaction.fromJson(json.decode(str));
String bookToJson(Transaction data) => json.encode(data.toJson());

class Transaction {
  String id;
  String state;
  String uidreciever;
  String uidproposer;
  String bookreciever;
  String bookproposer;

  Transaction({
    this.id,
    this.state,
    this.uidreciever,
    this.uidproposer,
    this.bookreciever,
    this.bookproposer
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
      id: json["id"],
      state: json["state"],
      uidreciever: json["uidreciever"],
      uidproposer: json["uidproposer"],
      bookreciever: json["bookreciver"],
      bookproposer: json["bookproposer"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "state": state,
    "uidreciever": uidreciever,
    "uidproposer": uidproposer,
    "bookreciver": bookreciever,
    "bookproposer": bookproposer
  };
}