import 'package:esg_mobile/core/utils/get_image_link.dart';

class Stamp {
  const Stamp({
    this.bucket,
    this.folderPath,
    this.fileName,
  });

  final String? bucket;
  final String? folderPath;
  final String? fileName;

  factory Stamp.fromJson(Map<String, dynamic> json) {
    return Stamp(
      bucket: json['bucket'] as String?,
      folderPath: json['folder_path'] as String?,
      fileName: json['file_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bucket': bucket,
      'folder_path': folderPath,
      'file_name': fileName,
    };
  }

  String? get url {
    if (bucket != null && fileName != null) {
      return getImageLink(bucket!, fileName!, folderPath: folderPath);
    }
    return null;
  }
}
