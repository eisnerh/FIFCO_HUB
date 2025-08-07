import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {
          setState(() {
            isLoading = true;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            isLoading = false;
          });
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
                   appBar: AppBar(
               title: Row(
                 children: [
                   // Logo FIFCO simplificado
                   Container(
                     padding: const EdgeInsets.all(6),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(6),
                       border: Border.all(color: Colors.white, width: 1),
                     ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         RichText(
                           text: const TextSpan(
                             style: TextStyle(
                               fontSize: 14,
                               fontWeight: FontWeight.bold,
                               letterSpacing: 0.3,
                             ),
                             children: [
                               TextSpan(
                                 text: 'FIF',
                                 style: TextStyle(color: Color(0xFF1E3A8A)),
                               ),
                               TextSpan(
                                 text: 'CO',
                                 style: TextStyle(color: Color(0xFF0EA5E9)),
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(width: 6),
                         Container(
                           width: 16,
                           height: 16,
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                               colors: [
                                 Color(0xFF1E3A8A),
                                 Color(0xFF7C3AED),
                                 Color(0xFF0EA5E9),
                               ],
                             ),
                             borderRadius: BorderRadius.circular(3),
                           ),
                           child: const Center(
                             child: Text(
                               '®',
                               style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 6,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(width: 8),
                   const Text(
                     'Navegador',
                     style: TextStyle(
                       fontWeight: FontWeight.w600,
                       color: Colors.white,
                     ),
                   ),
                 ],
               ),
               backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro FIFCO
               foregroundColor: Colors.white,
               elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.reload(),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progreso
                           if (isLoading)
                   LinearProgressIndicator(
                     backgroundColor: Colors.grey.shade200,
                     valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)), // Azul oscuro FIFCO
                   ),
          
          // Barra de navegación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                                           icon: Icon(
                           Icons.arrow_back,
                           color: canGoBack ? const Color(0xFF1E3A8A) : Colors.grey, // Azul oscuro FIFCO
                         ),
                  onPressed: canGoBack ? () async {
                    if (await controller.canGoBack()) {
                      await controller.goBack();
                      _updateNavigationState();
                    }
                  } : null,
                  tooltip: 'Atrás',
                ),
                IconButton(
                                           icon: Icon(
                           Icons.arrow_forward,
                           color: canGoForward ? const Color(0xFF1E3A8A) : Colors.grey, // Azul oscuro FIFCO
                         ),
                  onPressed: canGoForward ? () async {
                    if (await controller.canGoForward()) {
                      await controller.goForward();
                      _updateNavigationState();
                    }
                  } : null,
                  tooltip: 'Adelante',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.url,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // WebView
          Expanded(
            child: WebViewWidget(controller: controller),
          ),
        ],
      ),
    );
  }

  void _updateNavigationState() async {
    final back = await controller.canGoBack();
    final forward = await controller.canGoForward();
    setState(() {
      canGoBack = back;
      canGoForward = forward;
    });
  }
}