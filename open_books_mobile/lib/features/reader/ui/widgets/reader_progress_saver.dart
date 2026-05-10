import '../../logic/cubit/reader_cubit.dart';
import '../widgets/scroll_controller_registry.dart';

class ReaderProgressSaver {
  ReaderProgressSaver._();
  static Future<void> saveProgress(
    ReaderCubit readerCubit,
    ScrollControllerRegistry scrollControllerRegistry,
    ReaderState state,
  ) async {
    if (state is! ReaderLoaded) return;

    final controller = scrollControllerRegistry.controller(state.currentChapterIndex);
    if (controller != null && controller.hasClients && controller.position.maxScrollExtent > 0) {
      final scrollFraction = controller.position.pixels / controller.position.maxScrollExtent;
      await readerCubit.saveProgress(scrollFraction, chapterIndex: state.currentChapterIndex);
    } else if (state.scrollPosition > 0) {
      // If no controller or no extent, save the current state's scroll position just in case
      await readerCubit.saveProgress(state.scrollPosition, chapterIndex: state.currentChapterIndex);
    } else {
      await readerCubit.saveProgress(0.0, chapterIndex: state.currentChapterIndex);
    }
  }
}