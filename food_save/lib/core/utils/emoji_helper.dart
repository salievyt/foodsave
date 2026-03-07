/// Maps product categories to representative emojis.
class EmojiHelper {
  EmojiHelper._();

  static const Map<String, String> _categoryEmojis = {
    'Мясо': '🥩',
    'Молочка': '🥛',
    'Овощи': '🥦',
    'Фрукты': '🍎',
    'Напитки': '🥤',
    'Выпечка': '🍞',
    'Рыба': '🐟',
    'Крупы': '🌾',
    'Сладости': '🍫',
    'Соусы': '🧴',
    'Замороженные': '🧊',
    'Другое': '📦',
  };

  static const List<String> allCategories = [
    'Мясо',
    'Молочка',
    'Овощи',
    'Фрукты',
    'Напитки',
    'Выпечка',
    'Рыба',
    'Крупы',
    'Сладости',
    'Соусы',
    'Замороженные',
    'Другое',
  ];

  static String getEmoji(String category) {
    return _categoryEmojis[category] ?? '📦';
  }

  static String getEmojiForDisplay(String category) {
    return '${_categoryEmojis[category] ?? "📦"} $category';
  }
}
