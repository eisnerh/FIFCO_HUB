import 'package:flutter/material.dart';
import '../models/shortcut.dart';

class ShortcutTile extends StatelessWidget {
  final Shortcut shortcut;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final bool isAdminMode;

  const ShortcutTile({
    super.key,
    required this.shortcut,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.isAdminMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                                           Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(
                               begin: Alignment.topLeft,
                               end: Alignment.bottomRight,
                               colors: [
                                 Color(0xFF1E3A8A), // Azul oscuro FIFCO
                                 Color(0xFF0EA5E9), // Azul claro FIFCO
                               ],
                             ),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.language,
                             color: Colors.white,
                             size: 20,
                           ),
                         ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shortcut.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (shortcut.isDefault)
                                                                   Container(
                                       padding: const EdgeInsets.symmetric(
                                         horizontal: 8,
                                         vertical: 4,
                                       ),
                                       decoration: BoxDecoration(
                                         gradient: const LinearGradient(
                                           begin: Alignment.topLeft,
                                           end: Alignment.bottomRight,
                                           colors: [
                                             Color(0xFF1E3A8A), // Azul oscuro FIFCO
                                             Color(0xFF0EA5E9), // Azul claro FIFCO
                                           ],
                                         ),
                                         borderRadius: BorderRadius.circular(12),
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           const Icon(
                                             Icons.star,
                                             size: 14,
                                             color: Colors.white,
                                           ),
                                           const SizedBox(width: 4),
                                           const Text(
                                             'Predeterminado',
                                             style: const TextStyle(
                                               fontSize: 10,
                                               fontWeight: FontWeight.w500,
                                               color: Colors.white,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shortcut.url,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isAdminMode) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!shortcut.isDefault)
                      IconButton(
                        icon: Icon(
                          Icons.star_border,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: onSetDefault,
                        tooltip: 'Marcar como predeterminado',
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}