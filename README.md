# Flashcard

A modern, gesture-based flashcard application built with Flutter. Designed to help users memorize concepts efficiently using a clean, distraction-free interface with "swipe-to-study" mechanics.

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![Tech](https://img.shields.io/badge/built%20with-Flutter-blue.svg)

## 📖 Overview

This project was built to solve a personal need for a simple, aesthetic study tool. Unlike complex alternatives, Flashcard Pro focuses on the essentials: creating decks, adding cards, and studying with intuitive gestures.

**Key Features:**
* **📚 Deck Management:** Organize cards into specific "Decks" (e.g., Biology, Spanish) with colorful pastel icons.
* **👆 Card Interaction:** Tap cards to flip between question and answer. Swipe through cards using the card stack interface.
* **🗑️ Delete Functionality:** Remove cards with a confirmation dialog via the X button on each card.
* **🌗 Adaptive Theme:** Automatically switches between Light (Latte) and Dark (Macchiato) modes based on system settings using the Catppuccin color palette.
* **💾 Persistent Storage:** All decks and cards are saved locally on the device using `SharedPreferences`.
* **📐 Responsive Design:** Cards feature auto-sizing text to handle long strings without breaking the UI.

## 🏗️ App Architecture

The app follows a clear navigation flow centered around three main views.

```mermaid
---
config:
  layout: elk
  theme: redux-dark
title: App Interaction Flow
---
flowchart LR
 subgraph MainLibrary["View 1: Main Library"]
    direction LR
        LibraryPage(["Library Page (Main)"])
        DeckTile["Deck (List Item)"]
        AddDeckBtn["＋ Add Deck"]
        AddDeckPopup["Popup: Add New Deck"]
        DeckName[/"Input: Deck Name"/]
        CancelDeck["Cancel"]
        CreateDeck["Create"]
        SaveDeck["Save deck to list"]
  end
 subgraph StudySession["View 2: Study Session"]
    direction LR
        StudyPage(["Study Page (Main)"])
        BackToLibrary["← Back"]
        SwipeCard["Swipe: Next Card"]
        DeleteBtn["✕ Delete Card"]
        ConfirmDeletePopup[["Popup: Confirm Delete?"]]
        DeleteCancel["Cancel"]
        DeleteConfirm["Delete"]
        AddCardBtn["＋ Add Card"]
  end
 subgraph CardCreation["View 3: Create Card"]
    direction LR
        AddCardScreen(["Add Card Screen (Main)"])
        Form{{"Card form (Question + Answer)"}}
        Question[/"Input: Question"/]
        Answer[/"Input: Answer"/]
        BackToStudy["← Back"]
        AddToDeck["Add to Deck"]
        Disabled["no input -&gt; add to deck disabled"]
  end
    Start(("User Opens App")) --> LibraryPage
    LibraryPage --> DeckTile & AddDeckBtn
    AddDeckBtn --> AddDeckPopup
    AddDeckPopup --> DeckName & CancelDeck
    DeckName --> CreateDeck
    CancelDeck --> LibraryPage
    CreateDeck --> SaveDeck
    SaveDeck --> LibraryPage
    StudyPage --> BackToLibrary & SwipeCard & DeleteBtn & AddCardBtn
    SwipeCard --> StudyPage
    DeleteBtn --> ConfirmDeletePopup
    ConfirmDeletePopup --> DeleteCancel & DeleteConfirm
    DeleteCancel --> StudyPage
    DeleteConfirm --> StudyPage
    AddCardScreen --> Question & Answer & BackToStudy
    Question --> Form
    Answer --> Form
    Form -- valid --> AddToDeck
    AddToDeck --> StudyPage
    Form -- invalid --> Disabled
    Disabled -.-> Form
    BackToStudy --> StudyPage
    DeckTile -- Tap deck --> StudyPage
    BackToLibrary --> LibraryPage
    AddCardBtn -- ＋ --> AddCardScreen
LibraryPage:::main
StudyPage:::main
AddCardScreen:::main
classDef main stroke-width:3px,font-weight:bold;
AddDeckPopup@{ shape: subproc }---
config:
  layout: elk
  theme: redux-dark
title: App Interaction Flow
---
flowchart LR
 subgraph MainLibrary["View 1: Main Library"]
    direction LR
        LibraryPage(["Library Page (Main)"])
        DeckTile["Deck (List Item)"]
        AddDeckBtn["＋ Add Deck"]
        AddDeckPopup["Popup: Add New Deck"]
        DeckName[/"Input: Deck Name"/]
        CancelDeck["Cancel"]
        CreateDeck["Create"]
        SaveDeck["Save deck to list"]
  end
 subgraph StudySession["View 2: Study Session"]
    direction LR
        StudyPage(["Study Page (Main)"])
        BackToLibrary["← Back"]
        SwipeCard["Swipe: Next Card"]
        DeleteBtn["✕ Delete Card"]
        ConfirmDeletePopup[["Popup: Confirm Delete?"]]
        DeleteCancel["Cancel"]
        DeleteConfirm["Delete"]
        AddCardBtn["＋ Add Card"]
  end
 subgraph CardCreation["View 3: Create Card"]
    direction LR
        AddCardScreen(["Add Card Screen (Main)"])
        Form{{"Card form (Question + Answer)"}}
        Question[/"Input: Question"/]
        Answer[/"Input: Answer"/]
        BackToStudy["← Back"]
        AddToDeck["Add to Deck"]
        Disabled["no input -&gt; add to deck disabled"]
  end
    Start(("User Opens App")) --> LibraryPage
    LibraryPage --> DeckTile & AddDeckBtn
    AddDeckBtn --> AddDeckPopup
    AddDeckPopup --> DeckName & CancelDeck
    DeckName --> CreateDeck
    CancelDeck --> LibraryPage
    CreateDeck --> SaveDeck
    SaveDeck --> LibraryPage
    StudyPage --> BackToLibrary & SwipeCard & DeleteBtn & AddCardBtn
    SwipeCard --> StudyPage
    DeleteBtn --> ConfirmDeletePopup
    ConfirmDeletePopup --> DeleteCancel & DeleteConfirm
    DeleteCancel --> StudyPage
    DeleteConfirm --> StudyPage
    AddCardScreen --> Question & Answer & BackToStudy
    Question --> Form
    Answer --> Form
    Form -- valid --> AddToDeck
    AddToDeck --> StudyPage
    Form -- invalid --> Disabled
    Disabled -.-> Form
    BackToStudy --> StudyPage
    DeckTile -- Tap deck --> StudyPage
    BackToLibrary --> LibraryPage
    AddCardBtn -- ＋ --> AddCardScreen
LibraryPage:::main
StudyPage:::main
AddCardScreen:::main
classDef main stroke-width:3px,font-weight:bold;
AddDeckPopup@{ shape: subproc }
```

## 🛠️ Tech Stack & Packages

  * **Framework:** Flutter (Dart)
  * **State Management:** `setState` (Native)
  * **Local Database:** `shared_preferences`
  * **UI Components:**
      * `flutter_card_swiper: ^7.0.0`: For the gesture-based card stack.
      * `auto_size_text: ^3.0.0`: To handle dynamic text scaling on cards.
      * `shared_preferences: ^2.2.0`: For local data persistence.

## 🎨 Design System

The app utilizes the **Catppuccin** color palette for a soft, high-contrast look that is easy on the eyes during late-night study sessions.

| Mode | Background | Surface | Text |
| :--- | :--- | :--- | :--- |
| **Light (Latte)** | `#EFF1F5` | `#CCD0DA` | `#4C4F69` |
| **Dark (Macchiato)** | `#24273A` | `#363A4F` | `#CAD3F5` |

## 🚀 Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/fisram/flashcards
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

-----

*Built with Flutter 🐦*
