# Das NES auseinanderbrechen Wiki

Diese Ressource enthält umfassende Informationen zu drei Chips:
- [MOS](MOS.md) [6502](6502/Readme.md)
- [Ricoh](Ricoh.md) 2A03
- Ricoh 2C02

Die Chips 2A03 ([APU](APU/Readme.md)) und 2C02 ([PPU](PPU/Readme.md)) bilden die Grundlage der Spielkonsolen Nintendo NES, Famicom und ihrer [zahlreichen Analoga](Dendy.md).

Da der 6502-Prozessor Teil des 2A03-Chips in einer etwas "abgespeckten" Version ist, wird er separat untersucht.

## Informationsquelle

Die Quelle der Informationen sind hochauflösende Mikrofotografien der ICs.

Damals waren die ICs sehr einfach und wurden in [NMOS-Technologie](nmos.md) mit einer Oberflächenschicht aus Metall hergestellt. Um Vektormasken zu erhalten, waren daher zwei Arten von Fotos ausreichend: ein Foto der Oberfläche mit Metall und ein Foto ohne Metall. Normalerweise wird kochende Säure verwendet, um Metall von alten ICs zu entfernen.

Unter dem Mikroskop sehen die Chips so aus:

|6502|APU|PPU|
|---|---|---|
|<img src="/BreakingNESWiki/imgstore/6502/6502_die_shot.jpg" width="180px">|<img src="/BreakingNESWiki/imgstore/apu/apu_die_shot.jpg" width="200px">|<img src="/BreakingNESWiki/imgstore/ppu/ppu_die_shot.jpg" width="210px">|

Nachdem die Vektormasken erhalten wurden, werden sie für die Suche nach Transistoren verwendet, die schließlich eine logische Schaltung bilden.

## Aufbau und Zweck des Wikis

Zu den Funktionen des Wikis gehört eine detaillierte Beschreibung aller Funktionsblöcke der Chips.

Das Wiki ist in 3 Abschnitte unterteilt, je nach Anzahl der untersuchten Chips. Über das Navigationsmenü können Sie einen Einblick in die wichtigsten Funktionsblöcke jedes Chips erhalten.

Jeder Abschnitt ist ein detaillierter Überblick über die Transistorschaltung, die Logikschaltung und, wenn möglich, eine Analyse der Funktionsweise.

An einigen Stellen findet sich am Ende des Abschnitts auch ein Verilog für die untersuchte Schaltung.

Wie üblich sind Kenntnisse in Mikroelektronik und Programmierung erforderlich, um das Material zu verstehen.

Hinweis zur deutschen Version: Die Übersetzung wurde mit dem Dienst [DeepL.com](http://DeepL.com) erstellt, daher kann sie für Muttersprachler etwas unbeholfen wirken. Es steht Ihnen frei, eigene Änderungen vorzunehmen, um sie "menschlich" zu gestalten.

Viel Spaß beim Anschauen!
