import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsDetailScreen extends StatelessWidget {
  final String title;
  final String url;

  const TermsDetailScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "https://ssuchaehwa.duckdns.org";
    final String fullUrl = url.startsWith("http") ? url : "$baseUrl$url";

    // 먼저 controller 선언
    final controller = WebViewController();

    // controller 설정
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            // ✅ 선언 이후에 참조 가능
            await controller.runJavaScript('''
              if(!document.querySelector("meta[name=viewport]")) {
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0';
                document.getElementsByTagName('head')[0].appendChild(meta);
              }
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(fullUrl));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
