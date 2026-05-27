import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certificate_model.dart';
import '../services/certificate_service.dart';

/// ============================================
/// PÁGINA DE CONCLUSÃO DO CURSO
/// ============================================
/// 
/// Fluxo:
/// 1. Usuário conclui última aula (100%)
/// 2. Sistema exibe página de conclusão
/// 3. Usuário vê botão "Emitir Certificado"
/// 4. Clica e certificado é gerado
/// 5. Pode baixar, compartilhar, ou retornar ao curso
/// 
class CourseCompletionPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String instructorName;
  final int workloadHours;
  final int totalLessons;
  final int completedLessons;
  final double progressPercentage;
  final String userId;
  final String userName;

  const CourseCompletionPage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.instructorName,
    required this.workloadHours,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercentage,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<CourseCompletionPage> createState() => _CourseCompletionPageState();
}

class _CourseCompletionPageState extends State<CourseCompletionPage> {
  final CertificateService _certificateService = CertificateService();
  bool _isGenerating = false;
  Certificate? _certificate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingCertificate();
  }

  /// ============================================
  /// VERIFICAR SE CERTIFICADO JÁ EXISTE
  /// ============================================
  Future<void> _checkExistingCertificate() async {
    try {
      final cert = await _certificateService.getCertificate(
        widget.userId,
        widget.courseId,
      );

      if (cert != null) {
        setState(() {
          _certificate = cert;
        });
      }
    } catch (e) {
      print('Erro ao verificar certificado: $e');
    }
  }

  /// ============================================
  /// EMITIR CERTIFICADO
  /// ============================================
  Future<void> _emitCertificate() async {
    try {
      setState(() {
        _isGenerating = true;
        _errorMessage = null;
      });

      // Verificar elegibilidade
      final isEligible = _certificateService.isCertificateEligible(
        progressPercentage: widget.progressPercentage,
        completedLessons: widget.completedLessons,
        totalLessons: widget.totalLessons,
      );

      if (!isEligible) {
        setState(() {
          _errorMessage =
              'Você precisa completar 100% do curso para emitir o certificado.';
          _isGenerating = false;
        });
        return;
      }

      // Gerar certificado
      final certificate = await _certificateService.generateCertificate(
        userId: widget.userId,
        courseId: widget.courseId,
        courseTitle: widget.courseTitle,
        userName: widget.userName,
        instructorName: widget.instructorName,
        workloadHours: widget.workloadHours,
        progressPercentage: widget.progressPercentage,
        completedLessons: widget.completedLessons,
        totalLessons: widget.totalLessons,
      );

      if (certificate != null) {
        setState(() {
          _certificate = certificate;
          _isGenerating = false;
        });

        // Mostrar confirmação
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Certificado emitido com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao emitir certificado: $e';
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // HEADER - CONFETTI/CELEBRAÇÃO
            // ==========================================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0066CC), // Azul iFono
                    Color(0xFF0052A3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  // Ícone de celebração
                  Text(
                    '🎉',
                    style: TextStyle(fontSize: 80),
                  ),
                  SizedBox(height: 20),

                  // Título
                  Text(
                    'Parabéns!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Subtítulo
                  Text(
                    'Você completou o curso com sucesso!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // INFORMAÇÕES DO CURSO
            // ==========================================
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card com resumo
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome do curso
                          Text(
                            'Curso Concluído',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.courseTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Progresso
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoColumn('Progresso', '100%', Colors.green),
                              _buildInfoColumn(
                                'Aulas',
                                '${widget.completedLessons}/${widget.totalLessons}',
                                Color(0xFF0066CC),
                              ),
                              _buildInfoColumn(
                                'Carga Horária',
                                '${widget.workloadHours}h',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // ==========================================
                  // CERTIFICADO
                  // ==========================================

                  if (_certificate == null) ...[
                    // Ainda não tem certificado
                    Text(
                      'Seu Certificado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Descrição
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(0xFF0066CC),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📜 Emita seu Certificado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066CC),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Você completou todos os requisitos para receber um certificado oficial de conclusão. Clique no botão abaixo para emitiá-lo.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Botão de emitir certificado
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _emitCertificate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0066CC),
                          disabledBackgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isGenerating
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.card_membership),
                                  SizedBox(width: 12),
                                  Text(
                                    'Emitir Certificado',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Mensagem de erro
                    if (_errorMessage != null) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    // Certificado já existe
                    _buildCertificateCard(_certificate!),
                  ],

                  SizedBox(height: 30),

                  // ==========================================
                  // BOTÕES DE AÇÃO
                  // ==========================================

                  if (_certificate != null) ...[
                    Text(
                      'Ações',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Botão: Baixar PDF
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implementar download do PDF
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '📥 Funcionalidade em desenvolvimento',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Color(0xFF0066CC),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text('Baixar PDF'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Botão: Compartilhar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implementar compartilhamento
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '📤 Funcionalidade em desenvolvimento',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Compartilhar'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Botão: Ver Certificado
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Abrir visualizador de certificado
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '👁️ Funcionalidade em desenvolvimento',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.blue,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('Ver Certificado'),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 20),

                  // Botão: Voltar aos Cursos
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Voltar aos Cursos'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET: Coluna de Informação
  /// ============================================
  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET: Card de Certificado
  /// ============================================
  Widget _buildCertificateCard(Certificate certificate) {
    return Card(
      elevation: 4,
      color: Color(0xFFFFFAE6),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Text(
                  'Certificado Emitido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildCertificateInfo('Código de Verificação:', certificate.verificationCode),
            SizedBox(height: 8),
            _buildCertificateInfo(
              'Data de Emissão:',
              certificate.issueDate.toLocal().toString().split(' ')[0],
            ),
            SizedBox(height: 8),
            _buildCertificateInfo('Status:', certificate.status.displayName),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET: Informação do Certificado
  /// ============================================
  Widget _buildCertificateInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
