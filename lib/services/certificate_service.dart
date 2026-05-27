import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/certificate_model.dart';
import '../models/course_progress_model.dart';

/// Serviço para gerenciar certificados
class CertificateService {
  static final CertificateService _instance = CertificateService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory CertificateService() {
    return _instance;
  }

  CertificateService._internal();

  // ============================================
  // VALIDAÇÃO
  // ============================================

  /// Verificar se o usuário completou o curso (100%)
  bool isCourseCertificable(CourseProgress progress) {
    return progress.progressPercentage >= 100 ||
        (progress.completedLessons == progress.totalLessons &&
            progress.totalLessons > 0);
  }

  /// Verificar se certificado já existe
  Future<bool> certificateExists(String userId, String courseId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar certificado existente: $e');
      return false;
    }
  }

  /// Gerar código de verificação único
  String _generateVerificationCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = const Uuid().v4().substring(0, 8).toUpperCase();
    final code = '${random}${timestamp.toString().substring(0, 6)}';
    return code;
  }

  // ============================================
  // GERAÇÃO DE CERTIFICADO
  // ============================================

  /// Gerar certificado automaticamente ao completar curso
  Future<Certificate?> generateCertificate({
    required String userId,
    required String courseId,
    required String courseTitle,
    required String userName,
    required String instructorName,
    required int workloadHours,
    required DateTime completionDate,
  }) async {
    try {
      // 1. Validar se certificado já existe
      final exists = await certificateExists(userId, courseId);
      if (exists) {
        print('⚠️ Certificado já existe para este curso');
        return null;
      }

      // 2. Gerar dados do certificado
      final certificateId = const Uuid().v4();
      final verificationCode = _generateVerificationCode();
      final issueDate = DateTime.now();

      final certificate = Certificate(
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
        status: CertificateStatus.generated,
      );

      // 3. Salvar no Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .doc(certificateId)
          .set(certificate.toFirestore());

      print('✅ Certificado gerado com sucesso: $certificateId');
      return certificate;
    } catch (e) {
      print('❌ Erro ao gerar certificado: $e');
      rethrow;
    }
  }

  // ============================================
  // RECUPERAÇÃO DE CERTIFICADOS
  // ============================================

  /// Obter certificado específico
  Future<Certificate?> getCertificate(
    String userId,
    String certificateId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .doc(certificateId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Certificate.fromFirestore(doc);
    } catch (e) {
      print('Erro ao obter certificado: $e');
      return null;
    }
  }

  /// Obter certificado de um curso específico
  Future<Certificate?> getCertificateByCourse(
    String userId,
    String courseId,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return Certificate.fromFirestore(query.docs.first);
    } catch (e) {
      print('Erro ao obter certificado do curso: $e');
      return null;
    }
  }

  /// Listar todos os certificados do usuário
  Future<List<Certificate>> getUserCertificates(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .orderBy('issueDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Certificate.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao listar certificados: $e');
      return [];
    }
  }

  /// Stream de certificados em tempo real
  Stream<List<Certificate>> watchUserCertificates(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('certificates')
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Certificate.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================
  // ATUALIZAÇÃO DE STATUS
  // ============================================

  /// Atualizar status do certificado
  Future<void> updateCertificateStatus(
    String userId,
    String certificateId,
    CertificateStatus newStatus,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .doc(certificateId)
          .update({
        'status': newStatus.name,
        'updatedAt': Timestamp.now(),
      });

      print('✅ Status do certificado atualizado para: ${newStatus.displayName}');
    } catch (e) {
      print('❌ Erro ao atualizar status: $e');
      rethrow;
    }
  }

  /// Marcar como baixado
  Future<void> markAsDownloaded(String userId, String certificateId) async {
    await updateCertificateStatus(
      userId,
      certificateId,
      CertificateStatus.downloaded,
    );
  }

  /// Marcar como compartilhado
  Future<void> markAsShared(String userId, String certificateId) async {
    await updateCertificateStatus(
      userId,
      certificateId,
      CertificateStatus.shared,
    );
  }

  // ============================================
  // VERIFICAÇÃO
  // ============================================

  /// Verificar certificado por código
  Future<Certificate?> verifyCertificate(String verificationCode) async {
    try {
      final query = await _firestore
          .collectionGroup('certificates')
          .where('verificationCode', isEqualTo: verificationCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return Certificate.fromFirestore(query.docs.first);
    } catch (e) {
      print('Erro ao verificar certificado: $e');
      return null;
    }
  }

  // ============================================
  // INTEGRAÇÃO COM PROGRESSO
  // ============================================

  /// Processar conclusão de curso e gerar certificado
  Future<Certificate?> onCourseCompletion({
    required String userId,
    required CourseProgress progress,
    required String courseTitle,
    required String userName,
    required String instructorName,
    required int workloadHours,
  }) async {
    try {
      // 1. Validar se curso está 100% completo
      if (!isCourseCertificable(progress)) {
        print('⚠️ Curso não está 100% completo');
        return null;
      }

      // 2. Verificar se certificado já existe
      final exists = await certificateExists(userId, progress.courseId);
      if (exists) {
        print('⚠️ Certificado já existe');
        return null;
      }

      // 3. Gerar certificado
      final certificate = await generateCertificate(
        userId: userId,
        courseId: progress.courseId,
        courseTitle: courseTitle,
        userName: userName,
        instructorName: instructorName,
        workloadHours: workloadHours,
        completionDate: DateTime.now(),
      );

      return certificate;
    } catch (e) {
      print('Erro ao processar conclusão do curso: $e');
      rethrow;
    }
  }

  // ============================================
  // LIMPEZA/TESTES
  // ============================================

  /// Deletar certificado (apenas para testes)
  Future<void> deleteCertificate(
    String userId,
    String certificateId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('certificates')
          .doc(certificateId)
          .delete();

      print('✅ Certificado deletado: $certificateId');
    } catch (e) {
      print('Erro ao deletar certificado: $e');
      rethrow;
    }
  }

  /// Deletar todos os certificados do usuário (apenas para testes)
  Future<void> deleteAllUserCertificates(String userId) async {
    try {
      final certificates = await getUserCertificates(userId);

      for (final cert in certificates) {
        await deleteCertificate(userId, cert.certificateId);
      }

      print('✅ Todos os certificados do usuário foram deletados');
    } catch (e) {
      print('Erro ao deletar certificados: $e');
      rethrow;
    }
  }
}
