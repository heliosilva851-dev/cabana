import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/certificate_model.dart';

class CertificatePdfGenerator {
  /// ============================================
  /// GERAR PDF DO CERTIFICADO
  /// ============================================
  /// 
  /// Design profissional similar a:
  /// - Coursera
  /// - Hotmart
  /// - Udemy
  /// 
  static Future<pw.Document> generateCertificatePdf(
    Certificate certificate,
  ) async {
    final pdf = pw.Document();

    // Formatar datas
    final dateFormatter = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR');
    final issueDate = dateFormatter.format(certificate.issueDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // ==========================================
              // HEADER - LOGO E DECORAÇÃO
              // ==========================================
              pw.Column(
                children: [
                  // Logo iFono (placeholder)
                  pw.Container(
                    height: 60,
                    child: pw.Text(
                      'iFono',
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF0066CC), // Azul iFono
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(
                    height: 2,
                    color: PdfColor.fromInt(0xFF0066CC),
                  ),
                ],
              ),

              // ==========================================
              // CONTEÚDO PRINCIPAL
              // ==========================================
              pw.Column(
                children: [
                  // Título do certificado
                  pw.Text(
                    'CERTIFICADO DE CONCLUSÃO',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF1a1a1a),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Decoração
                  pw.Container(
                    width: 100,
                    height: 3,
                    color: PdfColor.fromInt(0xFFFFB300), // Amarelo destaque
                  ),
                  pw.SizedBox(height: 30),

                  // Texto de certificação
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Certificamos que ',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.TextSpan(
                          text: certificate.userName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF0066CC),
                          ),
                        ),
                        pw.TextSpan(
                          text: ' completou com êxito o curso ',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.TextSpan(
                          text: certificate.courseTitle.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF0066CC),
                          ),
                        ),
                        pw.TextSpan(
                          text: ' com carga horária de ',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.TextSpan(
                          text: '${certificate.workloadHours} horas',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.TextSpan(
                          text: '.',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 40),

                  // Informações do certificado
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      // Data
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Data de Emissão',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF666666),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            issueDate,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      // Código de verificação
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Código de Verificação',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF666666),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColor.fromInt(0xFF0066CC),
                                width: 1,
                              ),
                            ),
                            child: pw.Text(
                              certificate.verificationCode,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF0066CC),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ID do Certificado
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'ID do Certificado',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF666666),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            certificate.certificateId.substring(0, 8).toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // ==========================================
              // ASSINATURA E RODAPÉ
              // ==========================================
              pw.Column(
                children: [
                  pw.Divider(
                    height: 2,
                    color: PdfColor.fromInt(0xFF0066CC),
                  ),
                  pw.SizedBox(height: 20),

                  // Assinatura e nome do instrutor
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 100,
                            height: 40,
                          ), // Espaço para assinatura
                          pw.Text(
                            '_' * 25,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            certificate.instructorName,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Instrutor',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromInt(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'iFono',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromInt(0xFF0066CC),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Plataforma de Educação Online',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromInt(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// ============================================
  /// CONVERTER PARA BYTES (para salvar/compartilhar)
  /// ============================================
  static Future<List<int>> generateCertificateBytes(
    Certificate certificate,
  ) async {
    final pdf = await generateCertificatePdf(certificate);
    return await pdf.save();
  }

  /// ============================================
  /// GERAR NOME DO ARQUIVO
  /// ============================================
  static String generateFileName(Certificate certificate) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final date = dateFormatter.format(certificate.issueDate);
    return 'Certificado_${certificate.courseTitle.replaceAll(' ', '_')}_$date.pdf';
  }
}
