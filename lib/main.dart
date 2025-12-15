import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:auto_size_text/auto_size_text.dart';

// --- CATPPUCCIN COLORS ---
class Catppuccin {
  // Macchiato
  static const Color mBase = Color(0xFF24273A);
  static const Color mText = Color(0xFFCAD3F5);
  static const Color mSurface = Color(0xFF363A4F);
  // Latte
  static const Color lBase = Color(0xFFEFF1F5);
  static const Color lText = Color(0xFF4C4F69);
  static const Color lSurface = Color(0xFFCCD0DA);

  // Pastels
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

// --- The Wrapper ---
class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Pro',
      debugShowCheckedModeBanner: false,
      // Light Mode Theme
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
      // Dark Mode Theme
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
      themeMode: ThemeMode.system, // Auto-switch
      home: const LibraryPage(),
    );
  }
}

// --- DATA MODELS ---
class Flashcard {
  String question;
  String answer;
  Flashcard({required this.question, required this.answer});

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(question: json['question'], answer: json['answer']);
  }
}
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

// --- LIBRARY SCREEN  ---
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
    _loadDecks();
  }

  Future<void> _saveDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(decks.map((d) => d.toJson()).toList());
    await prefs.setString('my_decks', encoded);
  }

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

  Future<void> _addDeck(String name) async {
    setState(() {
      decks.add(Deck(name: name, cards: []));
    });
    await _saveDecks();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('FlashcardsApp')),
      body: decks.isEmpty
          ? Center(
              child: Text(
                "No decks yet.\nTap + to create a course!",
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Catppuccin.mText : Catppuccin.lText),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                // Use a pastel color for the deck icon
                final color = Catppuccin.pastels[index % Catppuccin.pastels.length];
                
                return Card(
                  color: isDark ? Catppuccin.mSurface : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(deck.name[0].toUpperCase(), 
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(deck.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${deck.cards.length} cards"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      // Navigate to Study Page and wait for result (in case cards were added)
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudyPage(deck: deck, onSave: _saveDecks),
                        ),
                      );
                      setState(() {}); // Refresh list when coming back
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            showDialog(
            context: context, 
            builder: (context) => AddDeckDialog(onAdd: _addDeck)
            );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- STUDY SCREEN (The Swiper) ---
class StudyPage extends StatefulWidget {
  final Deck deck;
  final VoidCallback onSave; // Callback to save changes to disk

  const StudyPage({super.key, required this.deck, required this.onSave});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  //we need a controller to programmatically swipe of needed
  final CardSwiperController _swiperController = CardSwiperController();

  void _deleteCard(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Card"),
        content: const Text("Are you sure you want to delete this card?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                widget.deck.cards.removeAt(index);
              });
              widget.onSave(); //save to disk
              Navigator.pop(context); //close dialog

              //if the deck is empty, go back to the library page
              if (widget.deck.cards.isEmpty) {
                Navigator.pop(context);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no cards, show simple prompt
    if (widget.deck.cards.isEmpty) {
        return Scaffold(
            appBar: AppBar(title: Text(widget.deck.name)),
            body: Center(child: Text("Empty Deck! Add some cards.")),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                    await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => AddCardScreen(
                            onAdd: (q, a) {
                                setState(() {
                                    widget.deck.cards.add(Flashcard(question: q, answer: a));
                                });
                                widget.onSave(); // Save to disk
                                Navigator.pop(context);
                            }
                        ))
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
              numberOfCardsDisplayed: widget.deck.cards.length > 3 ? 3 : widget.deck.cards.length,
              // We disable loop so indices match up correctly for deletion
              isLoop: false, 
              cardBuilder: (context, index, x, y) {
                final color = Catppuccin.pastels[index % Catppuccin.pastels.length];
                return FlipCardWidget(
                  card: widget.deck.cards[index], 
                  color: color,
                  onDelete: () => _deleteCard(index), // Pass the delete command down
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
                MaterialPageRoute(builder: (_) => AddCardScreen(
                    onAdd: (q, a) {
                        setState(() {
                            widget.deck.cards.add(Flashcard(question: q, answer: a));
                        });
                        widget.onSave();
                        Navigator.pop(context);
                    }
                ))
            );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- FLIP CARD WIDGET, med AutoSize och Delete funktion ---
class FlipCardWidget extends StatefulWidget {
  final Flashcard card;
  final Color color;
  final VoidCallback onDelete; // Callback to delete the card
  
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
      // Aspect Ratio makes it look like a poker card (0.7 is standard)
      child: AspectRatio(
        aspectRatio: 1, 
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  showAnswer = !showAnswer;
                });
              },
          child: Card(
            color: widget.color,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                      fontSize: 12
                    ),
                  ),
                  const SizedBox(height: 20),
                  //autosizetext that handles shrinking
                  AutoSizeText(
                    showAnswer ? widget.card.answer : widget.card.question,
                    textAlign: TextAlign.center,
                    minFontSize: 12, //doesnt shrink smaller than this
                    maxLines: 10,
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // the delete button
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

// --- DIALOGS & SCREENS ---
class AddDeckDialog extends StatefulWidget {
  final Function(String) onAdd;
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      widget.onAdd(_controller.text);
                      Navigator.pop(context);
                    }
                }, 
                child: const Text("Create")
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
      body: SingleChildScrollView( // Added scrolling for small screens
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _qCtrl, 
              maxLength: 120, // <--- max caracters to prevent errors
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Question", 
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aCtrl, 
              maxLength: 120, // <--- max charaters to prevent errors
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Answer", 
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_qCtrl.text.isNotEmpty && _aCtrl.text.isNotEmpty) {
                    widget.onAdd(_qCtrl.text, _aCtrl.text);
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