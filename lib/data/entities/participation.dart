class Participation {
  const Participation({
    required this.id,
    required this.missionTitle,
    required this.status,
    required this.createdAt,
    this.photoUrl,
    this.rejectionReason,
    this.stampUrl,
  });

  final String id;
  final String missionTitle;
  final String status;
  final DateTime createdAt;
  final String? photoUrl;
  final String? rejectionReason;
  final String? stampUrl;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'] as String,
      missionTitle: json['mission_title'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      photoUrl: json['photo_url'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      stampUrl: json['stamp_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mission_title': missionTitle,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'photo_url': photoUrl,
      'rejection_reason': rejectionReason,
      'stamp_url': stampUrl,
    };
  }
}
