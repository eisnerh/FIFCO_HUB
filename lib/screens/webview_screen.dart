import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

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
      ..setBackgroundColor(Colors.white)
      // Configuración para modo incógnito
      ..enableZoom(false) // Deshabilitar zoom para mejor experiencia
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
        // Prevenir navegación a sitios no seguros
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('http://') && !request.url.startsWith('https://')) {
            // Mostrar advertencia para conexiones no seguras
            _showSecurityWarning(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  void _showSecurityWarning(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Advertencia de Seguridad'),
          ],
        ),
        content: Text(
          'Estás intentando acceder a una conexión no segura:\n\n$url\n\n'
          'Por seguridad, se recomienda usar conexiones HTTPS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Permitir la navegación después de la advertencia
              controller.loadRequest(Uri.parse(url));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar datos de navegación al cerrar la pantalla
    _clearAllWebViewData();
    super.dispose();
  }

  Future<void> _clearAllWebViewData() async {
    try {
      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Limpiando datos de navegación...'),
            ],
          ),
        ),
      );

      // En modo incógnito, limpiar datos adicionales que puedan persistir
      await controller.clearCache();
      debugPrint('🗑️ Cache del WebView limpiado');

      // Limpiar datos de formularios usando JavaScript
      await controller.runJavaScript('''
        // Limpiar todos los formularios
        var forms = document.getElementsByTagName('form');
        for (var i = 0; i < forms.length; i++) {
          forms[i].reset();
        }
        // Limpiar campos de entrada
        var inputs = document.querySelectorAll('input, textarea, select');
        for (var i = 0; i < inputs.length; i++) {
          inputs[i].value = '';
          inputs[i].checked = false;
        }
        // Limpiar cualquier dato almacenado en la sesión actual
        if (window.sessionStorage) {
          sessionStorage.clear();
        }
      ''');
      debugPrint('📝 Datos de formularios y sesión limpiados');

      // Cerrar el diálogo de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Datos de navegación eliminados correctamente',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      debugPrint('✅ Datos de navegación eliminados correctamente');

    } catch (e) {
      // Cerrar el diálogo de progreso si hay error
      if (mounted) Navigator.of(context).pop();
      
      debugPrint('❌ Error limpiando datos de navegación: $e');
      
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error al limpiar datos: $e',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    bool shouldPop = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Advertencia'),
          ],
        ),
        content: Text(
          'Si sales ahora, se perderán todos los datos de navegación. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              shouldPop = true;
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Salir'),
          ),
        ],
      ),
    );
    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
            Flexible(
              child: Text(
                'Navegador',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro FIFCO
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _clearAllWebViewData,
            tooltip: 'Limpiar datos de navegación',
          ),
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
          
          // WebView
          Expanded(
            child: WebViewWidget(controller: controller),
          ),
        ],
      ),
    ),
    );
  }
}