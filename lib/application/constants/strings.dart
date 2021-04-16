// This is a temporary constants file related to all strings
//
// Even if the v1 for memo will only be available in ptBR, splitting random strings throughout the code will make it
// hard when we decide to support multiple locales.
//
// Also, when new locales are added to the application, we can still maintain a single point of entry for all strings
// just like this file, but we have to consider that we will possibly need access to the BuildContext, as this is where
// the runtime locale is determined.

const collectionsNavigationTab = 'Coleções';
const progressNavigationTab = 'Progresso';

const collectionsExploreTab = 'Explorar';
const collectionsReviewTab = 'Revisar';

const collectionsSectionHeaderSeeAll = 'Ver todos';

const collectionsMemoryStability = 'Estabilidade da Memória';

const progressTotalStudyTime = 'HORAS TOTAIS DE ESTUDOS';

const progressTotalMemos = 'MEMOS COMPLETADOS';
const progressTotalHardMemos = 'MEMOS MARCADOS COMO DIFÍCIL';
const progressTotalMediumMemos = 'MEMOS MARCADOS COMO MÉDIO';
const progressTotalEasyMemos = 'MEMOS MARCADOS COMO FÁCIL';

const progressHardMemosIndicatorLabel =
    'Indicador circular demonstrando o percentual de memos respondidos como difícil';
const progressMediumMemosIndicatorLabel =
    'Indicador circular demonstrando o percentual de memos respondidos como médio';
const progressEasyMemosIndicatorLabel = 'Indicador circular demonstrando o percentual de memos respondidos como fácil';

//
// Symbols
//
const percentSymbol = '%';
const hoursSymbol = 'h';
const minutesSymbol = 'm';

//
// Unicode Emojis
//
const faceScreamingInFear = '\u{1F631}';
const expressionlessFace = '\u{1F611}';
const squintingFaceWithTongue = '\u{1F61D}';
