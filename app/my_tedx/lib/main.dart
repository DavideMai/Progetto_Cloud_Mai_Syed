// main.dart
import 'package:flutter/material.dart';
import 'package:my_tedx/services/api_service.dart';
import 'package:my_tedx/pages/tag_search_page.dart';
import 'package:my_tedx/pages/video_of_the_day_page.dart';
import 'package:my_tedx/utils/app_colors.dart';
import 'package:my_tedx/utils/dialog_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDays App',
      theme: ThemeData(
        primarySwatch: AppColors.tedxRed,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.tedxRed,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5D0CE), 
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tedxRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // AGGIUNTO QUI: Tema per il cursore e la selezione del testo
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.tedxRed, // Colore del cursore
          selectionColor: AppColors.tedxRed.withOpacity(0.3), // Colore del testo selezionato (con un po' di trasparenza)
          selectionHandleColor: AppColors.tedxRed, // Colore delle "maniglie" di selezione
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  List<Widget> get _pages => [
        TagSearchPage(apiService: _apiService, showTalkDetails: DialogUtils.showTalkDetails),
        VideoOfTheDayPage(apiService: _apiService, showTalkDetails: DialogUtils.showTalkDetails),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TEDays'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cerca Tag',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Video del Giorno',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.tedxRed,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
      ),
    );
  }
}