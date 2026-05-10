import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/index.dart';
import '../../logic/cubit/libro_detalle_cubit.dart';
import '../widgets/review_dialog.dart';
import '../widgets/denuncia_resena_dialog.dart';
import '../widgets/share_book_qr_widget.dart';
import '../../../../shared/core/session/session_cubit.dart';
import '../../../../shared/core/session/session_state.dart';

void showReviewDialog(BuildContext context, int libroId) {
  final cubit = context.read<LibroDetalleCubit>();
  showDialog(
    context: context,
    builder: (dialogContext) => ReviewDialog(
      libroId: libroId,
      onSubmit: (texto) {
        cubit.escribirResena(texto);
      },
    ),
  );
}

void showDescripcionCompleta(BuildContext context, String descripcion) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Descripción'),
      content: SingleChildScrollView(child: Text(descripcion)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('cerrar'),
        ),
      ],
    ),
  );
}

void showQrDialog(BuildContext context, int libroId, String titulo, String autor) {
  showDialog(
    context: context,
    builder: (dialogContext) => ShareBookQrDialog(
      libroId: libroId,
      titulo: titulo,
      autor: autor,
    ),
  );
}

void showDenunciaResenaDialog(BuildContext context, Resena resena) {
  final sessionState = context.read<SessionCubit>().state;
  if (sessionState is! SessionAuthenticated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debes iniciar sesión para denunciar una reseña')),
    );
    return;
  }

  if (sessionState.userId == resena.usuarioId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No puedes denunciar tu propia reseña')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (dialogContext) => DenunciaResenaDialog(
      resena: resena,
      onSubmit: (motivo, comentario) {
        context.read<LibroDetalleCubit>().denunciarResena(
          idDenunciante: sessionState.userId,
          idDenunciado: resena.usuarioId,
          idResena: resena.id,
          motivo: motivo,
          comentario: comentario,
        );
      },
    ),
  );
}