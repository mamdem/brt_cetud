import 'package:brt_mobile/error/sync_logger.dart';
import 'package:flutter/material.dart';

class SyncLogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logs = SyncLogger.getLogs();

    return Scaffold(
      appBar: AppBar(
        title: Text("Journal de Synchronisation"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Supprimer les logs
              SyncLogger.clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Tous les journaux ont été supprimés."),
              ));
              // Rafraîchir l'interface
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SyncLogPage()),
              );
            },
          ),
        ],
      ),
      body: logs.isEmpty
          ? Center(
        child: Text(
          "Aucun journal disponible.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            leading: Icon(
              _getIconForStatus(log['status']),
              color: _getColorForStatus(log['status']),
            ),
            title: Text(log['message'] ?? ''),
            subtitle: Text(log['timestamp'] ?? ''),
          );
        },
      ),
    );
  }

  // Méthodes pour gérer les icônes et les couleurs
  IconData _getIconForStatus(String? status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getColorForStatus(String? status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
