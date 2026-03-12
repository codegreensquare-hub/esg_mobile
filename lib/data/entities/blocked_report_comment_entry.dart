/// A comment that the current user has either blocked or reported, for history screens.
class BlockedReportCommentEntry {
  const BlockedReportCommentEntry({
    required this.commentId,
    required this.maskedName,
    required this.date,
    required this.commentText,
    required this.isBlocked,
  });

  final String commentId;
  final String maskedName;
  final String date;
  final String commentText;
  /// True if this is from block history (can unblock), false if from report history.
  final bool isBlocked;
}
