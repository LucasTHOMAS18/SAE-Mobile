class Review {
  final int idUser;
  final int idRestau;
  final int note;
  final String comment;

  Review({
    required this.idUser,
    required this.idRestau,
    required this.note,
    required this.comment,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      idUser: map['idUser'],
      idRestau: map['idRestau'],
      note: map['note'],
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'idRestau': idRestau,
      'note': note,
      'comment': comment,
    };
  }
}
