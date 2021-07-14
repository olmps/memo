[Inglês](/README.md) | Português

<div align="center">
  <h1>Memo</h1>
  <img src="https://raw.githubusercontent.com/olmps/memo/master/assets/icon.png" alt="Memo Icon" width="200">
  <br>
  <br>
  <a href="https://github.com/olmps/memo/actions/workflows/release.yml">
    <img src="https://github.com/olmps/memo/actions/workflows/release.yml/badge.svg" alt="Release">
  </a>
  <br>
  <br>
</div>

Monorepo do Memo.

Memo é um software de código aberto (escrito em Flutter) de
[repetição espaçada](https://en.wikipedia.org/wiki/Spaced_repetition) (SRS, em inglês) voltado ao tema de programação.

> Atualmente, este projeto está construído apenas para gerar _builds_ para Android e iOS. Embora o fato de que, dado a
> estabilidade da SDK do Flutter para desktop (Windows, Linux e macOS) e web, existe uma alta probabilidade que este
> projeto eventualmente suportará _builds_ para todas as plataformas.

---

Este README e todos os sub-documentos presentes aqui (CONTRIBUTING, ARCHITECTURE & CHANGELOG) tem como objetivo guiar a
estrutura deste projeto e devem auxiliar na escalabilidade das funcionalidades existentes hoje e nas que serão criadas
com o decorrer do andamento do projeto. Estes documentos servem como um conjunto flexível de regras que guiam as
decisões tomadas no andamento do projeto. Embora estas regras possam - e provavelmente irão - mudar, discussões devem
ser levantadas sobre os motivos para tais mudanças, de maneira que essas discussões e decisões sejam transparentes para
todos.

- [Setup](#setup): como configurar seu projeto localmente;
- [Arquitetura](#arquitetura): como está estruturada a arquitetura da aplicação;
- [Background](#background): um pouco do _background_ sobre este projeto;
- [Contribuição & Boas Práticas](#contribuição--boas-práticas): recomendações sobre contribuições;
- [Licença](#licença): como essa aplicação está licenciada e como você pode utilizá-la.

## Setup

Se você não tem ideia de como instalar o Flutter e rodá-lo localmente, dê uma olhada nesse
[_Get started_ (em inglês)](https://flutter.dev/docs/get-started/install)

Agora, se você já tem o Flutter configurado localmente, na pasta raíz do projeto, instale as dependências através do
comando `flutter pub get`.

## Arquitetura

Como essa aplicação foi estruturada e como ela interage com dependência externas - escrito em detalhes em
[ARCHITECTURE](ARCHITECTURE.md) (em inglês).

## Background

Se você está interessado em dar uma olhadinha sobre como acabamos lidando com o processo de software deste projeto (dentro
da nossa equipe), dê uma olhada no [.process/](.process/README.md).

## Contribuição & Boas Práticas

Veja o documento [CONTRIBUTING](CONTRIBUTING.md) para mais detalhes sobre como contribuir com este projeto.

## Licença

Memo está licenciado sobre a licença [BSD 3-Clause](LICENSE).

## Patrocinadores

Este projeto foi construído com a ajuda dos patrocinadores abaixo:

- [Maratona Discover](https://bit.ly/lucas-montano-maratonadiscover): Aprenda programação na prática. E de graça.
- [Startup Life Podcast](https://bit.ly/lucas-montano-startup-life): O seu podcast sobre negócios, tecnologia e inovação.
- [Pingback](https://bit.ly/lucas-montano-pingback): Crie conteúdo com total liberdade.
