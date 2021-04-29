import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/coordinator/routes_coordinator.dart';

final detailsCollectionId = ScopedProvider<String>(null);

class CollectionDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: Center(
        child: TextButton(
          onPressed: () {
            final id = context.read(detailsCollectionId);
            readCoordinator(context).navigateToCollectionExecution(id);
          },
          child: const Text('Iniciar Execução'),
        ),
      ),
    );
  }
}
