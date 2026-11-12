import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => _favorites;

  UserProvider() {
    _loadUser();
  }

  // Memuat data user, tema, counter kunjungan, dan daftar favorit
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    final favorites = prefs.getStringList('favorites') ?? [];

    final currentCount = prefs.getInt('visit_count') ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt('visit_count', newCount);

    _user = User(
      name: name,
      email: email,
      isLoggedIn: isLoggedIn,
    );
    _isDarkMode = isDarkMode;
    _visitCount = newCount;
    _favorites = favorites;
    _isLoading = false;
    notifyListeners();
  }

  // Menambah item favorit ke SharedPreferences
  Future<void> addFavorite(String item) async {
    final trimmed = item.trim();
    if (trimmed.isEmpty) return;

    final updatedFavorites = List<String>.from(_favorites)..add(trimmed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', updatedFavorites);

    _favorites = updatedFavorites;
    notifyListeners();
  }

  // Menghapus item favorit berdasarkan index
  Future<void> removeFavorite(int index) async {
    final updatedFavorites = List<String>.from(_favorites)..removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', updatedFavorites);

    _favorites = updatedFavorites;
    notifyListeners();
  }

  // Mengubah dan menyimpan preferensi tema
  Future<void> toggleTheme() async {
    final newTheme = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', newTheme);

    _isDarkMode = newTheme;
    notifyListeners();
  }

  // Menyimpan data user ke SharedPreferences
  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  // Logout: hapus data user (kecuali email)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }
}