import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return _buildMobileFooter();
          }
          return _buildDesktopFooter();
        },
      ),
    );
  }

  Widget _buildDesktopFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        'logo.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.movie_filter,
                            color: Color(0xFF00BCD4),
                            size: 50,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'CINECHILL',
                        style: TextStyle(
                          color: Color(0xFF00BCD4),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Học tiếng Anh qua phim ảnh',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: _buildFooterSection('Liên kết nhanh', [
                'Phim',
                'Danh sách của tôi',
                'Duyệt theo thể loại',
                'Phim mới',
              ]),
            ),
            Expanded(
              child: _buildFooterSection('Tài nguyên', [
                'Cách sử dụng',
                'Câu hỏi thường gặp',
                'Blog',
                'Hỗ trợ',
              ]),
            ),
            Expanded(
              child: _buildFooterSection('Pháp lý', [
                'Điều khoản dịch vụ',
                'Chính sách bảo mật',
                'Chính sách Cookie',
                'Liên hệ',
              ]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Color(0xFF2A2A2A)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '© 2025 CineChill',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Row(
              children: [
                _buildSocialIcon(Icons.facebook, size: 18),
                const SizedBox(width: 12),
                _buildSocialIcon(Icons.message, size: 18),
                const SizedBox(width: 12),
                _buildSocialIcon(Icons.language, size: 18),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.network(
              'logo.png',
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.movie_filter,
                  color: Color(0xFF00BCD4),
                  size: 40,
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'CINECHILL',
              style: TextStyle(
                color: Color(0xFF00BCD4),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '© 2024 CineChill',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            Row(
              children: [
                _buildSocialIcon(Icons.facebook, size: 16),
                const SizedBox(width: 10),
                _buildSocialIcon(Icons.message, size: 16),
                const SizedBox(width: 10),
                _buildSocialIcon(Icons.language, size: 16),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () {
                // Điều hướng tới các trang tương ứng - sẽ implement sau
              },
              child: Text(
                item,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, {double size = 16}) {
    return InkWell(
      onTap: () {
        // Mở link mạng xã hội - sẽ implement sau
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
