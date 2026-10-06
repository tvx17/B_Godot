# Pocket Rooms

Eine kleine Idle-Spielvorlage für Godot 4.3 oder neuer mit GDScript, ohne externe Assets oder Plugins. Entwickelt für die mobile Querformatansicht; noch kein fertiges Android-/iOS-Paket.

## Starten

`project.godot` in Godot importieren und mit **F6/F5** die Hauptszene starten (F5 startet das Projekt). Alternativ: `godot --path .`.

## Ausprobieren

- **Werkbank**: Die türkisfarbene Figur findet durch die Türen einen Weg zum orangefarbenen Quader. Dort entsteht alle drei Sekunden eine Münze.
- **Abholen**: Übernimmt die bereitliegenden Münzen. Der rote Punkt zeigt neue Erträge an.
- **Erkunden** oder Boden antippen: Die Figur läuft automatisch zum Ziel.
- **90°** oder **Q/E**: Dreht die orthografische Kamera in vier feste Ansichten.
- **Menü / Esc**: Öffnet ein vollständig deckendes Menü und pausiert Bewegung und Produktion. Produktion und Laufgeschwindigkeit lassen sich einstellen.

Einstellungen werden in `user://settings.cfg` gespeichert. Münzen sind bewusst nur Sitzungszustand; Offline-Erträge und Spielstandspeicherung sind noch nicht implementiert.

## Orientierung für Web-Entwickler

Die Szene `scenes/main.tscn` ist der Einstiegspunkt. Nodes bilden einen Baum ähnlich einem Komponentenbaum; Signale verbinden Ereignisse mit Reaktionen. `_ready()` initialisiert, `_process(delta)` aktualisiert pro Bild und `_physics_process(delta)` führt die Bewegung aus.

| Datei | Aufgabe |
| --- | --- |
| `scripts/main.gd` | Kamera, Aufträge, Produktion, Eingaben und Einstellungen |
| `scripts/room_world.gd` | Vier Räume, Türen, Quader und A*-Raster auf der X/Z-Ebene |
| `scripts/worker.gd` | Bewegung entlang von Wegpunkten und Ankunftssignal |
| `scripts/hud.gd` | Touch-Buttons, roter Hinweis und pausierendes Menü |

Raumgeometrie wird zunächst aus Code aufgebaut. Ändere das Raster in `room_world.gd`, um Räume zu erweitern. Sichtbare Wände und gesperrte Wegpunkte werden aus denselben Daten erzeugt. Die Werkbank ist gesperrt, die Figur läuft zur benachbarten Arbeitszelle. Für weitere Ereignisse ergänze Aufträge in `main.gd`; weitere Hinweis-Symbole können das Badge-Muster aus `hud.gd` übernehmen.

## Prüfen und mobil exportieren

`godot --headless --path . --editor --quit` prüft den Import. `godot --headless --path . --script tests/smoke.gd` prüft Wegsuche, Ankunft, Produktion, Kamera und Pause.

Für einen Gerätebuild installiere zur Godot-Version passende Exportvorlagen und richte Android- bzw. iOS-Export im Editor ein. Signierung, SDKs und Geräteprüfung bleiben projektspezifisch. Prüfe Touch-Bedienung, Bildschirmränder und Leistung auf einem echten Gerät, bevor du veröffentlichst.
