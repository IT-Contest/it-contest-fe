import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsDetailScreen extends StatefulWidget {
  final String title;
  final String url;

  const TermsDetailScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<TermsDetailScreen> createState() => _TermsDetailScreenState();
}

class _TermsDetailScreenState extends State<TermsDetailScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final String baseUrl = "https://ssuchaehwa.duckdns.org";
    final String fullUrl = widget.url.startsWith("https")
        ? widget.url
        : "$baseUrl${widget.url}";

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // ✅ 기존 스타일 제거 후 강제 리렌더링
            await controller.runJavaScript('''
              // 기존 style 및 meta 제거
              document.querySelectorAll('style').forEach(s => s.remove());
              const metas = document.querySelectorAll('meta[name="viewport"]');
              metas.forEach(m => m.remove());
              
              // 새로운 meta 추가
              const meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0';
              document.head.appendChild(meta);

              // CSS 강제 적용
              const style = document.createElement('style');
              style.innerHTML = `
                html, body {
                  max-width: 100% !important;
                  width: 100% !important;
                  margin: 0 !important;
                  padding: 20px 16px 60px 16px !important;
                  box-sizing: border-box;
                  overflow-x: hidden !important;
                  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                  line-height: 1.7;
                  font-size: 16px;
                  color: #222;
                  background-color: #fff;
                  word-break: keep-all;
                }
                h1, h2, h3, h4 {
                  color: #4C1FFF;
                  font-weight: 700;
                  margin-top: 28px;
                  margin-bottom: 12px;
                }
                p, li {
                  margin-bottom: 10px;
                }
                ol, ul {
                  padding-left: 20px;
                }
                strong {
                  color: #000;
                }
              `;
              document.head.appendChild(style);
            ''');
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(fullUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF7958FF)),
            ),
        ],
      ),
    );
  }
}
