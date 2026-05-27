import 'package:cloud_firestore/cloud_firestore.dart';

class Certificate {
  final String certificateId;
  final String userId;
  final String courseId;
  final String courseTitle;
  final String userName;
  final String instructorName;
  final int workloadHours;
  final DateTime issueDate;
  final DateTime? completionDate;
  final String verificationCode;
  final String? certificateUrl;
  final CertificateStatus status;
  final String? s3Key; // Para futuros armazenamentos em S3

  Certificate({
    required this.certificateId,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.userName,
    required this.instructorName,
    required this.workloadHours,
    required this.issueDate,
    this.completionDate,
    required this.verificationCode,
    this.certificateUrl,
    this.status = CertificateStatus.generated,
    this.s3Key,
  });

  /// Converter para JSON para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'certificateId': certificateId,
      'userId': userId,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'userName': userName,
      'instructorName': instructorName,
      'workloadHours': workloadHours,
      'issueDate': Timestamp.fromDate(issueDate),
      'completionDate': completionDate != null ? Timestamp.fromDate(completionDate!) : null,
      'verificationCode': verificationCode,
      'certificateUrl': certificateUrl,
      'status': status.name,
      's3Key': s3Key,
      'createdAt': Timestamp.now(),
    };
  }

  /// Converter do Firestore para modelo
  factory Certificate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Certificate(
      certificateId: data['certificateId'] ?? '',
      userId: data['userId'] ?? '',
      courseId: data['courseId'] ?? '',
      courseTitle: data['courseTitle'] ?? '',
      userName: data['userName'] ?? '',
      instructorName: data['instructorName'] ?? 'iFono',
      workloadHours: data['workloadHours'] ?? 0,
      issueDate: (data['issueDate'] as Timestamp).toDate(),
      completionDate: data['completionDate'] != null 
        ? (data['completionDate'] as Timestamp).toDate()
        : null,
      verificationCode: data['verificationCode'] ?? '',
      certificateUrl: data['certificateUrl'],
      status: CertificateStatus.values.byName(
        data['status'] ?? CertificateStatus.generated.name,
      ),
      s3Key: data['s3Key'],
    );
  }

  /// Criar cópia com campos modificados
  Certificate copyWith({
    String? certificateUrl,
    CertificateStatus? status,
    String? s3Key,
  }) {
    return Certificate(
      certificateId: certificateId,
      userId: userId,
      courseId: courseId,
      courseTitle: courseTitle,
      userName: userName,
      instructorName: instructorName,
      workloadHours: workloadHours,
      issueDate: issueDate,
      completionDate: completionDate,
      verificationCode: verificationCode,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      status: status ?? this.status,
      s3Key: s3Key ?? this.s3Key,
    );
  }

  @override
  String toString() {
    return 'Certificate(id: $certificateId, course: $courseTitle, user: $userName, status: $status)';
  }
}

enum CertificateStatus {
  generated,
  downloaded,
  shared,
  verified,
  archived,
}

/// Extensão para formatar status
extension CertificateStatusExtension on CertificateStatus {
  String get displayName {
    switch (this) {
      case CertificateStatus.generated:
        return 'Gerado';
      case CertificateStatus.downloaded:
        return 'Baixado';
      case CertificateStatus.shared:
        return 'Compartilhado';
      case CertificateStatus.verified:
        return 'Verificado';
      case CertificateStatus.archived:
        return 'Arquivado';
    }
  }

  String get icon {
    switch (this) {
      case CertificateStatus.generated:
        return '✨';
      case CertificateStatus.downloaded:
        return '📥';
      case CertificateStatus.shared:
        return '📤';
      case CertificateStatus.verified:
        return '✅';
      case CertificateStatus.archived:
        return '📦';
    }
  }
}
