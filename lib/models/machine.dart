class Machine {
  int id;
  String name;
  String type;
  int qr;
  String date;
  String imagepath;

  Machine({this.id, this.name, this.type, this.qr, this.date, this.imagepath});

  Machine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    qr = json['qr'];
    date = json['date'];
    imagepath = json['imagepath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['qr'] = this.qr;
    data['date'] = this.date;
    data['imagepath'] = this.imagepath;
    return data;
  }
}