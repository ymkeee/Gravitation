<div align="center">

# 🌌 Gravitation (RootHide Dopamine)

[![Build Status](https://github.com/ymkeee/Gravitation/actions/workflows/build.yml/badge.svg)](https://github.com/ymkeee/Gravitation/actions)
[![Latest Release](https://img.shields.io/github/v/release/ymkeee/Gravitation?color=purple&label=Release)](https://github.com/ymkeee/Gravitation/releases/latest)
[![iOS Support](https://img.shields.io/badge/iOS-15.0%20--%2016.7%2B-blue.svg)](https://github.com/ymkeee/Gravitation)
[![Architecture](https://img.shields.io/badge/Arch-arm64e%20%7C%20arm64-orange.svg)](https://github.com/ymkeee/Gravitation)
[![Jailbreak](https://img.shields.io/badge/Jailbreak-Dopamine%20RootHide-green.svg)](https://github.com/roothide)

**The legendary physics tweak for iOS, completely re-engineered for Dopamine RootHide on iOS 15 & 16 (iPhone 14 Pro Max / arm64e).**

[English](#-english) • [Русский](#-русский) • [Download .deb](https://github.com/ymkeee/Gravitation/releases/latest)

</div>

---

## 🇷🇺 Русский

### ✨ Особенности и исправления:

* 📱 **Реальная физика гравитации:** Встряхните телефон на рабочем столе, чтобы иконки открепились и упали. Наклоняйте устройство — иконки плавно скользят под действием реального акселерометра и гироскопа.
* 🧲 **Плавное возвращение на место:** Встряхните телефон снова — иконки плавно и мягко скользят назад с приятным пружинящим отскоком, без резких рывков и дёрганий на последнем кадре.
* 🎯 **100% точное восстановление сетки:** Никаких смещений и перепутанных иконок! Перед запуском физики координаты каждого элемента фиксируются с точностью до пикселя.
* 🧩 **Полная поддержка виджетов iOS 14–16:** Виджеты (2×2, 2×4, 4×4) больше не ломают сетку. В настройках можно выбрать:
  * *Падение виджетов:* виджеты падают вместе с иконками с учётом своего реального размера и массы.
  * *Виджеты как платформы:* виджеты остаются на месте как твёрдые препятствия, от которых отскакивают иконки.
* 👆 **Гравитация пальца (Finger Gravity):** Коснитесь свободного места на экране, чтобы притянуть иконки к пальцу, словно магнитом.
* 🚀 **Запуск приложений по нажатию:** Нажмите на любую падающую или лежащую иконку, чтобы сразу открыть приложение (при этом иконки аккуратно вернутся на свои места).
* 🔒 **Работа ТОЛЬКО на рабочем столе:** Твик полностью игнорирует встряску внутри приложений (Telegram, Safari и др.) и на экране блокировки.
* 🏝 **Отскок от Dynamic Island:** На iPhone 14 Pro Max иконки физически отскакивают от островка Dynamic Island.
* 🔇 **Абсолютная тишина:** Полностью отключены нежелательные вибрации и звуки.

---

### 📲 Как установить:

1. Перейдите в раздел **[Releases](https://github.com/ymkeee/Gravitation/releases/latest)**.
2. Скачайте файл **`com.ymkeee.gravitation_X.X.X_iphoneos-arm64e.deb`**.
3. Откройте скачанный файл через **Sileo**, **Zebra** или **Filza**.
4. Нажмите **«Установить»** (или **«Обновить»**, если у вас уже стоит предыдущая версия).
5. Сделайте быстрый респринг (*Respring*).

---

## 🇬🇧 English

### ✨ Features & Bug Fixes:

* 📱 **Realistic Physics & Gyro:** Shake your device on the Home Screen to unhinge icons. Tilt your iPhone in any direction to watch icons slide smoothly with true device gravity.
* 🧲 **Smooth Gliding Return:** Shake again to smoothly return icons to their grid slots with a lively, organic spring bounce and zero twitching at the end.
* 🎯 **Pixel-Perfect Grid Restoration:** Eliminates all placement bugs from older versions. Pre-physics coordinates are preserved and restored with absolute precision.
* 🧩 **Full WidgetKit Support:** iOS 14–16 modern widgets (small, medium, large) are completely supported:
  * *Falling Widgets (ON):* Widgets tumble and slide with realistic mass.
  * *Falling Widgets (OFF):* Widgets act as solid collision bumper platforms.
* 👆 **Finger Gravity:** Touch and drag across the screen to create a radial gravitational attractor pulling icons toward your fingertip.
* 🚀 **Tap to Launch Apps:** Tap any icon while it is falling to immediately launch the app.
* 🔒 **Home Screen Only:** Completely ignores shakes inside open applications or on the Lock Screen.
* 🏝 **Dynamic Island Collisions:** iPhone 14 Pro Max Dynamic Island bounds act as a solid collision obstacle.
* 🔇 **Silent & Clean:** No unwanted haptics or vibration clicks.

---

### 📲 Installation:

1. Go to the **[Latest Release](https://github.com/ymkeee/Gravitation/releases/latest)** page.
2. Download **`com.ymkeee.gravitation_X.X.X_iphoneos-arm64e.deb`**.
3. Open the file in **Sileo**, **Zebra**, or **Filza**.
4. Tap **Install** (or **Update** if upgrading).
5. Respring your device.

---

### 🛠 Building from Source:

This tweak is pre-configured with **GitHub Actions**. Every commit automatically compiles a clean RootHide `.deb` and publishes a GitHub Release.

To build manually on macOS with RootHide Theos:

```bash
export THEOS=/path/to/roothide/theos
make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide
```

---

### 📜 Credits:

* **Original Tweak:** [Kritanta](https://github.com/KritantaDev) (Gravitation)
* **RootHide Dopamine Port & Bugfixes:** [ymkeee](https://github.com/ymkeee)
