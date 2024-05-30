class Batches {
  int batchid;
  String batchname;
  String batchfees;

  Batches({required this.batchid, required this.batchname, required this.batchfees});

  factory Batches.fromMap(Map<String, dynamic> map) {
    return Batches(
      batchid: map['batchid'],
      batchname: map['batchname'],
      batchfees: map['batchfees'],
    );
  }
}