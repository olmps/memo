# Memo - Perguntas Frequentes

- [Memo - Perguntas Frequentes](#memo---perguntas-frequentes)
  - [O que é uma Coleção?](#o-que-é-uma-coleção)
  - [O que é um Memo?](#o-que-é-um-memo)
  - [O que é o nível de fixação?](#o-que-é-o-nível-de-fixação)

## O que é uma Coleção?

Uma coleção se trata de um grupo de [Memos](#o-que-é-um-memo).

Fazendo uma analogia com [flashcards](https://en.wikipedia.org/wiki/Flashcard), ela é o que consideramos um Deck.

## O que é um Memo?

Um memo é um "desafio" individual de uma [Coleção](#o-que-é-uma-coleção).

Fazendo uma analogia com [flashcards](https://en.wikipedia.org/wiki/Flashcard), é o que consideramos como uma Carta,
esta na qual pertence à um Deck.

## O que é o nível de fixação?

O nível de fixação (traduzido de *memory recall*) pode ser definido como **a soma das estimativas de memória (do
usuário) para cada Memo, isto é, o quão _forte_ é a memória do usuário sobre os Memos de uma Coleção**. Este nível é
calculado com base na [curva de esquecimento do SuperMemo](https://supermemo.guru/wiki/Forgetting_curve).

A implementação deste cálculo pode ser vista mais à fundo na sua própria implementação dentro deste repositório, no
serviço chamado `MemoryRecallServices`.

Obs.: este nível de fixação ainda está em fase de desenvolvimento e deverá ser melhorado ao longo do tempo. Isto quer
dizer que ainda não temos um forte embasamento de que esta estimativa de "fixação" seja tão assertiva.