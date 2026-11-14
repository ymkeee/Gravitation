<div align="center">

# 🌌 Gravitation (RootHide & Rootless)

[![Build Status](https://github.com/ymkeee/Gravitation/actions/workflows/build.yml/badge.svg)](https://github.com/ymkeee/Gravitation/actions)
[![Latest Release](https://img.shields.io/github/v/release/ymkeee/Gravitation?color=purple&label=Release)](https://github.com/ymkeee/Gravitation/releases/latest)
[![iOS Support](https://img.shields.io/badge/iOS-15.0%20--%2016.7%2B-blue.svg)](https://github.com/ymkeee/Gravitation)
[![Architecture](https://img.shields.io/badge/Arch-arm64e%20%7C%20arm64-orange.svg)](https://github.com/ymkeee/Gravitation)
[![Jailbreak](https://img.shields.io/badge/Jailbreak-RootHide%20%7C%20Rootless-green.svg)](https://github.com/ymkeee/Gravitation/releases/latest)

**Культовый физический твик Gravitation для iOS, полностью переписанный без багов с поддержкой как Dopamine RootHide, так и стандартного Rootless (Dopamine Rootless, Palera1n).**

[English](#-english) • [Русский](#-русский) • [📥 Скачать релизы / Download Releases](https://github.com/ymkeee/Gravitation/releases/latest)

</div>

---

## 🇷🇺 Русский

### 📦 Доступно две версии пакета:

| Версия | Для каких джейлбрейков | Пакет для скачивания |
| :--- | :--- | :--- |
| **RootHide** | **Dopamine RootHide** (A12–A16, iOS 15.0–16.7+) | `..._roothide.deb` |
| **Rootless** | **Dopamine Rootless**, **Palera1n**, **XinaA15**, etc. | `..._rootless.deb` |

---

### ✨ Особенности и новые функции:

* ⚙️ **Полноценная панель в Настройках iOS (PreferenceLoader):** Твик появляется в Настройках со своей собственной иконкой, ссылкой на GitHub разработчика и полным набором переключателей.
* 🏷 **Правильный хитбокс для названий иконок:** Названия приложений видны по умолчанию, а хитбокс расширен по бокам, защищая текст от наложений соседних значков. При включении опции скрытия названий пустой 30pt промежуток полностью убирается.
* ⏰ **Хитбоксы времени и батареи:** Часы слева и батарея справа защищены отдельными барьерами, не блокируя проход к Dynamic Island.
* 🏝 **Усиленный хитбокс Dynamic Island:** Физический отскок со всех 4 сторон Dynamic Island на iPhone 14 Pro Max.
* 📥 **Управление падением за док (Dock Barrier):** 
  * *Включено:* док работает как твёрдый пол, иконки прыгают на нём.
  * *Выключено:* иконки падают за док до самого низа экрана.
* 📱 **Гравитация иконок в доке:** Возможность включить падение для иконок нижнего дока (Телефон, Safari, Сообщения, Музыка).
* 🧲 **Плавное возвращение на место:** При повторной встряске иконки мягко возвращаются в свои исходные ячейки с приятным пружинящим эффектом без рывков.
* 🎯 **100% точное восстановление сетки:** Координаты каждого значка и виджета сохраняются перед падением и восстанавливаются пиксель в пиксель.
* 🧩 **Полная поддержка виджетов:** Виджеты (2×2, 2×4, 4×4) могут либо падать, либо оставаться неподвижными твёрдыми платформами.
* 👆 **Притяжение пальцем (Finger Gravity):** Коснитесь экрана, чтобы притянуть иконки к пальцу словно магнитом.
* 🚀 **Запуск приложений по нажатию:** Нажмите на любую падающую иконку, чтобы мгновенно открыть приложение.
* 🔒 **Работа ТОЛЬКО на рабочем столе:** Твик полностью игнорирует встряску внутри открытых приложений и на экране блокировки.
* 🔇 **Абсолютная тишина:** Никаких лишних вибраций и звуков.

---

### 📲 Как установить / обновить:

1. Перейдите в раздел **[Releases](https://github.com/ymkeee/Gravitation/releases/latest)**.
2. Скачайте нужный файл:
   * **`com.ymkeee.gravitation_X.X.X_roothide.deb`** — если у вас **RootHide**.
   * **`com.ymkeee.gravitation_X.X.X_rootless.deb`** — если у вас обычный **Rootless**.
3. Откройте скачанный файл через **Sileo**, **Zebra** или **Filza**.
4. Нажмите **«Обновить»** (или **«Установить»**).
5. Сделайте быстрый респринг (*Respring*).

---

## 🇬🇧 English

### 📦 Two Editions Available:

| Edition | Supported Jailbreaks | File Name |
| :--- | :--- | :--- |
| **RootHide** | **Dopamine RootHide** (A12–A16, iOS 15.0–16.7+) | `..._roothide.deb` |
| **Rootless** | **Dopamine Rootless**, **Palera1n**, **XinaA15**, etc. | `..._rootless.deb` |

---

### ✨ Features & Settings:

* ⚙️ **iOS Settings Integration (PreferenceLoader):** Access Gravitation directly from the iOS Settings app with dedicated toggles.
* 🏷 **No Overlapping Labels:** App title labels are smoothly hidden during fall so rotated labels do not clutter or overlap icons. Labels fade back upon return.
* ⏰ **Status Bar Barrier:** Prevents icons from flying over the clock, battery, and cellular indicators at the top of the screen.
* 🏝 **Dynamic Island Hitbox:** Precise collision boundary matching the Dynamic Island pill on iPhone 14 Pro / Pro Max.
* 📥 **Dock Floor Barrier vs Fall Through:** Toggle whether icons bounce off the top of the dock or fall behind it.
* 📱 **Dock Icons Gravity:** Optionally enable physics for the icons inside the dock bar.
* 🧲 **Smooth Gliding Return:** Gentle spring bounce on return with zero jerk at the end.
* 🎯 **Pixel-Perfect Grid Restoration:** Absolute precision placement restoration with zero misplaced icons.
* 🧩 **Full WidgetKit Support:** Interactive widgets can fall or act as static obstacle platforms.
* 👆 **Finger Gravity:** Magnetic pull toward your touch point.
* 🚀 **Tap to Launch Apps:** Tap any icon while falling to open apps immediately.
* 🔒 **Home Screen Only:** Completely ignores shakes inside open apps or on the Lock Screen.
* 🔇 **Silent:** Zero unwanted vibrations or sounds.

---

### 📲 Installation:

1. Go to the **[Latest Release](https://github.com/ymkeee/Gravitation/releases/latest)** page.
2. Download the appropriate `.deb`:
   * **`..._roothide.deb`** for **Dopamine RootHide**.
   * **`..._rootless.deb`** for **Dopamine Rootless / Palera1n**.
3. Open the file in **Sileo**, **Zebra**, or **Filza**.
4. Tap **Update** (or **Install**).
5. Respring your device.

---

### 📜 Credits:

* **Original Tweak:** [Kritanta](https://github.com/KritantaDev) (Gravitation)
* **RootHide & Rootless Modern Port:** [ymkeee](https://github.com/ymkeee)
