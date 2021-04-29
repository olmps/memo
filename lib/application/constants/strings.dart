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

//
// Progress
//
const progressTotalStudyTime = 'Totais de estudos';
const progressTotalMemos = 'Memos completados';

//
// Execution
//
const executionQuestion = 'Questão';
const executionAnswer = 'Resposta';

const executionNext = 'Próxima';
const executionCheckAnswer = 'Ver resposta';

const executionYourPerformance = 'Seu desempenho';
const executionBackToCollections = 'Voltar para as coleções';

const executionWellDone = '## Muito Bem';
const executionImprovedKnowledgeDescription = 'Você acaba de aprimorar seu conhecimento em:';

String executionLinearIndicatorCompletionLabel(String completionDescription) =>
    'Indicador linear demonstrando que o nível de conclusão desta sessão aprendizado está em $completionDescription';

//
// Application-wide strings
//
String recallLevel = 'Nível de Fixação';

String answeredMemos(MemoDifficulty difficulty) => 'Memos marcados como ${memoDifficulty(difficulty).toLowerCase()}';

String collectionCompletionProgress({required int current, required int target}) =>
    '$current / $target memos completados';

String circularIndicatorMemoAnswersLabel(MemoDifficulty difficulty) =>
    'Indicador circular demonstrando o percentual de memos respondidos como ${memoDifficulty(difficulty).toLowerCase()}';

String linearIndicatorCollectionRecallLabel(String recallDescription) =>
    'Indicador linear demonstrando que o nível de fixação da coleção está em $recallDescription';

String linearIndicatorCollectionCompletionLabel(String completionDescription) =>
    'Indicador linear demonstrando que o nível de conclusão da coleção está em $completionDescription';

String memoDifficultyEmoji(MemoDifficulty difficulty) {
  switch (difficulty) {
    case MemoDifficulty.easy:
      return squintingFaceWithTongue;
    case MemoDifficulty.medium:
      return expressionlessFace;
    case MemoDifficulty.hard:
      return faceScreamingInFear;
  }
}

String memoDifficulty(MemoDifficulty difficulty) {
  switch (difficulty) {
    case MemoDifficulty.easy:
      return 'Fácil';
    case MemoDifficulty.medium:
      return 'Médio';
    case MemoDifficulty.hard:
      return 'Difícil';
  }
}

//
// Symbols
//
const percentSymbol = '%';
const hoursSymbol = 'h';
const minutesSymbol = 'm';

//
// Unicode Emojis - Reference: https://unicode.org/emoji/charts/full-emoji-list.html
//
const squintingFaceWithTongue = '\u{1F61D}';
const expressionlessFace = '\u{1F611}';
const faceScreamingInFear = '\u{1F631}';

const partyPopper = '\u{1F389}';
