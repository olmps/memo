// This is a temporary constants file related to all strings
//
// Even if the v1 for memo will only be available in ptBR, splitting random strings throughout the code will make it
// hard when we decide to support multiple locales.
//
// Also, when new locales are added to the application, we can still maintain a single point of entry for all strings
// just like this file, but we have to consider that we will possibly need access to the BuildContext, as this is where
// the runtime locale is determined.

import 'package:memo/domain/enums/memo_difficulty.dart';

const collectionsNavigationTab = 'Coleções';
const progressNavigationTab = 'Progresso';

const collectionsExploreTab = 'Explorar';
const collectionsReviewTab = 'Revisar';

const collectionsSectionHeaderSeeAll = 'Ver todos';
const collectionsMemoryStability = 'Estabilidade da Memória';
String collectionsCompletionProgress({required int current, required int target}) =>
    '$current / $target memos completados';

const progressTotalStudyTime = 'Horas totais de estudos';
const progressTotalMemos = 'Memos completados';

String progressTotalCompletedMemos(MemoDifficulty difficulty) => 'Memos marcados como ${_rawDifficulty(difficulty)}';
String progressIndicatorLabel(MemoDifficulty difficulty) =>
    'Indicador circular demonstrando o percentual de memos respondidos como ${_rawDifficulty(difficulty)}';

String progressDifficultyEmoji(MemoDifficulty difficulty) {
  switch (difficulty) {
    case MemoDifficulty.easy:
      return squintingFaceWithTongue;
    case MemoDifficulty.medium:
      return expressionlessFace;
    case MemoDifficulty.hard:
      return faceScreamingInFear;
  }
}

String _rawDifficulty(MemoDifficulty difficulty) {
  switch (difficulty) {
    case MemoDifficulty.easy:
      return 'fácil';
    case MemoDifficulty.medium:
      return 'médio';
    case MemoDifficulty.hard:
      return 'difícil';
  }
}

//
// Symbols
//
const percentSymbol = '%';
const hoursSymbol = 'h';
const minutesSymbol = 'm';

//
// Unicode Emojis
//
const squintingFaceWithTongue = '\u{1F61D}';
const expressionlessFace = '\u{1F611}';
const faceScreamingInFear = '\u{1F631}';
