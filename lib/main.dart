import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:auto_size_text/auto_size_text.dart';

// --- CATPPUCCIN-FÄRGER ---
// (bara en liten “färgpalett-fil” i samma fil för enkelhet)
class Catppuccin {
  // Macchiato (mörkt)
  static const Color mBase = Color(0xFF24273A);
  static const Color mText = Color(0xFFCAD3F5);
  static const Color mSurface = Color(0xFF363A4F);

  // Latte (ljust)
  static const Color lBase = Color(0xFFEFF1F5);
  static const Color lText = Color(0xFF4C4F69);
  static const Color lSurface = Color(0xFFCCD0DA);

  // Pastellfärger att rotera mellan (t.ex. deck-ikon, kortfärg osv)
  static const List<Color> pastels = [
    Color(0xFFF5E0DC), // Rosewater
    Color(0xFFF2CDCD), // Flamingo
    Color(0xFFCBA6F7), // Mauve
    Color(0xFFF38BA8), // Red
    Color(0xFFFAB387), // Peach
    Color(0xFFF9E2AF), // Yellow
    Color(0xFFA6E3A1), // Green
    Color(0xFF89DCEB), // Sky
  ];
}

void main() {
  runApp(const FlashcardApp());
}

// --- APP-WRAPPER ---
// Här sätter vi tema + vilken “startsida” appen ska öppna
class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard', // <-- fix: inte “Flashcard Pro”
      debugShowCheckedModeBanner: false,

      // Ljust tema
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Catppuccin.lBase,
        appBarTheme: const AppBarTheme(
          backgroundColor: Catppuccin.lBase,
          foregroundColor: Catppuccin.lText,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Catppuccin.lSurface,
          foregroundColor: Catppuccin.lText,
        ),
        useMaterial3: true,
      ),

      // Mörkt tema
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Catppuccin.mBase,
        appBarTheme: const AppBarTheme(
          backgroundColor: Catppuccin.mBase,
          foregroundColor: Catppuccin.mText,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Catppuccin.mSurface,
          foregroundColor: Catppuccin.mText,
        ),
        useMaterial3: true,
      ),

      // Kör systemets dark/light automatiskt
      themeMode: ThemeMode.system,

      // Första vyn man landar på
      home: const LibraryPage(),
    );
  }
}

// --- DATA-MODELLER ---
// Flashcard = ett kort (fråga + svar)
class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(question: json['question'], answer: json['answer']);
  }
}

// Deck = “kursen”/kortleken (namn + lista av kort)
class Deck {
  String name;
  List<Flashcard> cards;

  Deck({required this.name, required this.cards});

  Map<String, dynamic> toJson() => {
        'name': name,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      name: json['name'],
      cards: (json['cards'] as List).map((x) => Flashcard.fromJson(x)).toList(),
    );
  }
}

// --- BIBLIOTEKET (LISTA MED DECKS) ---
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Deck> decks = [];

  @override
  void initState() {
    super.initState();
    // Kom ihåg: ladda sparad data när appen startar
    _loadDecks();
  }

  // Spara allt lokalt (SharedPreferences) som en JSON-sträng
  Future<void> _saveDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(decks.map((d) => d.toJson()).toList());
    await prefs.setString('my_decks', encoded);
  }

  // Ladda allt lokalt (om det finns)
  Future<void> _loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString('my_decks');
    if (encoded != null) {
      final List<dynamic> decoded = jsonDecode(encoded);
      setState(() {
        decks = decoded.map((json) => Deck.fromJson(json)).toList();
      });
    }
  }

  // Skapa en ny deck och spara den
  // (OBS: vi poppar INTE dialogen här längre — det sköter dialogen själv)
  Future<void> _addDeck(String name) async {
    setState(() {
      decks.add(Deck(name: name, cards: []));
    });
    await _saveDecks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard')), // <-- fixad titel
      body: decks.isEmpty
          ? Center(
              child: Text(
                "No decks yet.\nTap + to create a course!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Catppuccin.mText : Catppuccin.lText,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];

                // Snabbt “identifiera” decken med en pastellfärg
                final color =
                    Catppuccin.pastels[index % Catppuccin.pastels.length];

                return Card(
                  color: isDark ? Catppuccin.mSurface : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(
                        deck.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      deck.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${deck.cards.length} cards"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    // Öppna decken och plugga
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudyPage(
                            deck: deck,
                            onSave: _saveDecks,
                          ),
                        ),
                      );
                      // Kom ihåg: uppdatera listan när man kommer tillbaka
                      setState(() {});
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Öppna dialog för att skapa ny deck
          showDialog(
            context: context,
            builder: (context) => AddDeckDialog(onAdd: _addDeck),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- STUDY-SIDAN (SWIPER) ---
class StudyPage extends StatefulWidget {
  final Deck deck;
  final VoidCallback onSave; // “spara till disk” callback

  const StudyPage({super.key, required this.deck, required this.onSave});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  // Kom ihåg: controller om man vill styra swipen med kod senare
  final CardSwiperController _swiperController = CardSwiperController();

  void _deleteCard(int index) {
    // Bekräftelse-dialog så man inte råkar ta bort
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Card"),
        content: const Text("Are you sure you want to delete this card?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.deck.cards.removeAt(index);
              });

              // spara efter borttagning
              widget.onSave();

              // stäng bekräftelsedialogen
              Navigator.pop(context);

              // om decken blev tom: gå tillbaka till library
              if (widget.deck.cards.isEmpty) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Om decken är tom: visa “lägg till kort”-prompt
    if (widget.deck.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deck.name)),
        body: const Center(child: Text("Empty Deck! Add some cards.")),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddCardScreen(
                  onAdd: (q, a) {
                    setState(() {
                      widget.deck.cards.add(
                        Flashcard(question: q, answer: a),
                      );
                    });
                    widget.onSave();
                    Navigator.pop(context); // stäng AddCardScreen
                  },
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.deck.name)),
      body: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: _swiperController,
              cardsCount: widget.deck.cards.length,
              numberOfCardsDisplayed:
                  widget.deck.cards.length > 3 ? 3 : widget.deck.cards.length,

              // Kom ihåg: ingen loop här så index stämmer för delete
              isLoop: false,
              cardBuilder: (context, index, x, y) {
                final color =
                    Catppuccin.pastels[index % Catppuccin.pastels.length];
                return FlipCardWidget(
                  card: widget.deck.cards[index],
                  color: color,
                  onDelete: () => _deleteCard(index),
                );
              },
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCardScreen(
                onAdd: (q, a) {
                  setState(() {
                    widget.deck.cards.add(
                      Flashcard(question: q, answer: a),
                    );
                  });
                  widget.onSave();
                  Navigator.pop(context); // stäng AddCardScreen
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- FLIP-KORTET ---
// Tap för att växla fråga/svar +  X-knapp för delete
class FlipCardWidget extends StatefulWidget {
  final Flashcard card;
  final Color color;
  final VoidCallback onDelete;

  const FlipCardWidget({
    super.key,
    required this.card,
    required this.color,
    required this.onDelete,
  });

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      // Kom ihåg: AspectRatio för att få “kortkänsla”
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                // Tap = vänd kortet (typ)
                setState(() {
                  showAnswer = !showAnswer;
                });
              },
              child: Card(
                color: widget.color,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showAnswer ? "ANSWER" : "QUESTION",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // AutoSizeText = om texten är lång så krymper den hellre än overflow
                      AutoSizeText(
                        showAnswer ? widget.card.answer : widget.card.question,
                        textAlign: TextAlign.center,
                        minFontSize: 12,
                        maxLines: 10,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // X-knapp uppe till höger (delete)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.close, color: Colors.black54),
                tooltip: "Delete Card",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DIALOGER & SKÄRMAR ---

class AddDeckDialog extends StatefulWidget {
  // Fix: gör onAdd await:bar så vi kan spara klart och sen poppa dialogen EN gång
  final Future<void> Function(String) onAdd;

  const AddDeckDialog({super.key, required this.onAdd});

  @override
  State<AddDeckDialog> createState() => _AddDeckDialogState();
}

class _AddDeckDialogState extends State<AddDeckDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Course Name"),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              await widget.onAdd(name);
              if (context.mounted) {
                Navigator.pop(context); // <-- fix: poppa bara dialogen här
              }
            }
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}

class AddCardScreen extends StatefulWidget {
  final Function(String, String) onAdd;

  const AddCardScreen({super.key, required this.onAdd});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _qCtrl = TextEditingController();
  final _aCtrl = TextEditingController();

  @override
  void dispose() {
    _qCtrl.dispose();
    _aCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Card")),
      body: SingleChildScrollView(
        // Kom ihåg: scroll så det funkar på små skärmar också
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _qCtrl,
              maxLength: 120, // hålla det rimligt så layouten inte spårar ur
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Question",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aCtrl,
              maxLength: 120,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Answer",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final q = _qCtrl.text.trim();
                  final a = _aCtrl.text.trim();

                  // bara lägg till om båda fälten har nåt
                  if (q.isNotEmpty && a.isNotEmpty) {
                    widget.onAdd(q, a);
                  }
                },
                child: const Text("Add to Deck"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
