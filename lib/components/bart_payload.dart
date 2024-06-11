class BartPayload {
  String? sequence;
  List<String>? labels;
  List<double>? scores;

  BartPayload({this.sequence, this.labels, this.scores});

  BartPayload.fromJson(Map<String, dynamic> json) {
    sequence = json['sequence'];
    labels = json['labels'].cast<String>();
    scores = json['scores'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sequence'] = this.sequence;
    data['labels'] = this.labels;
    data['scores'] = this.scores;
    return data;
  }
}
