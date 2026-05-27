import 'package:flutter/material.dart';
import '../models/certificate_model.dart';
import 'package:intl/intl.dart';

/// ============================================
/// WIDGET: Card do Certificado
/// ============================================
/// 
/// Exibir certificado em lista ou grid
/// Mostrar informações principais
/// 
class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onView;
  final VoidCallback? onDelete;

  const CertificateCard({
    Key? key,
    required this.certificate,
    required this.onDownload,
    required this.onShare,
    required this.onView,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    final formattedDate = dateFormatter.format(certificate.issueDate);

    return Card(
      margin: EdgeInsets.all(12),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // HEADER - TÍTULO E STATUS
          // ==========================================
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0066CC),
                  Color(0xFF0052A3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate.courseTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'De: ${certificate.instructorName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(certificate.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        certificate.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // BODY - INFORMAÇÕES
          // ==========================================
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do aluno
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Aluno',
                  value: certificate.userName,
                ),
                SizedBox(height: 12),

                // Carga horária
                _buildInfoRow(
                  icon: Icons.schedule,
                  label: 'Carga Horária',
                  value: '${certificate.workloadHours}h',
                ),
                SizedBox(height: 12),

                // Data de emissão
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Data de Emissão',
                  value: formattedDate,
                ),
                SizedBox(height: 12),

                // Código de verificação
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF0066CC),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Código de Verificação',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            certificate.verificationCode,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0066CC),
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: Color(0xFF0066CC)),
                        onPressed: () {
                          // TODO: Copiar para clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Código copiado para clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // FOOTER - AÇÕES
          // ==========================================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão: Visualizar
                Expanded(
                  child: TextButton(
                    onPressed: onView,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility, size: 18),
                        SizedBox(width: 4),
                        Text('Visualizar'),
                      ],
                    ),
                  ),
                ),

                // Divisor
                SizedBox(
                  height: 24,
                  child: VerticalDivider(color: Colors.grey[300]),
                ),

                // Botão: Baixar
                Expanded(
                  child: TextButton(
                    onPressed: onDownload,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 18),
                        SizedBox(width: 4),
                        Text('Baixar'),
                      ],
                    ),
                  ),
                ),

                // Divisor
                SizedBox(
                  height: 24,
                  child: VerticalDivider(color: Colors.grey[300]),
                ),

                // Botão: Compartilhar
                Expanded(
                  child: TextButton(
                    onPressed: onShare,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, size: 18),
                        SizedBox(width: 4),
                        Text('Compartilhar'),
                      ],
                    ),
                  ),
                ),

                // Botão: Mais opções
                if (onDelete != null)
                  Expanded(
                    child: TextButton(
                      onPressed: onDelete,
                      child: Icon(Icons.more_vert, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET: Linha de Informação
  /// ============================================
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFF0066CC)),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ============================================
  /// HELPER: Cor do Status
  /// ============================================
  Color _getStatusColor(CertificateStatus status) {
    switch (status) {
      case CertificateStatus.generated:
        return Colors.amber;
      case CertificateStatus.downloaded:
        return Colors.blue;
      case CertificateStatus.shared:
        return Colors.green;
      case CertificateStatus.verified:
        return Colors.teal;
      case CertificateStatus.archived:
        return Colors.grey;
    }
  }
}

/// ============================================
/// WIDGET: Minimal Certificate Card
/// ============================================
/// 
/// Versão compacta para listas
/// 
class CertificateCompactCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;

  const CertificateCompactCard({
    Key? key,
    required this.certificate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.card_membership,
        color: Color(0xFF0066CC),
      ),
      title: Text(
        certificate.courseTitle,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${certificate.instructorName} • ${certificate.workloadHours}h',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          certificate.status.icon,
          style: TextStyle(fontSize: 14),
        ),
      ),
      onTap: onTap,
    );
  }
}

/// ============================================
/// WIDGET: Empty State
/// ============================================
/// 
/// Quando o usuário não tem certificados
/// 
class NoCertificatesWidget extends StatelessWidget {
  final VoidCallback onContinueLearning;

  const NoCertificatesWidget({
    Key? key,
    required this.onContinueLearning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_membership,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 24),
          Text(
            'Nenhum Certificado Ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Complete um curso para emitir seu certificado',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onContinueLearning,
            child: Text('Voltar aos Cursos'),
          ),
        ],
      ),
    );
  }
}
