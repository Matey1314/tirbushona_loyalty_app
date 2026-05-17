/// Simple cards management service for local prototype
class CardsService {
  // Static list shared across screens
  static List<Map<String, dynamic>> myCards = [];

  /// Add a card to the list
  static void addCard(Map<String, dynamic> card) {
    myCards.add(card);
  }

  /// Get all cards
  static List<Map<String, dynamic>> getCards() {
    return myCards;
  }

  /// Check if cards list is empty
  static bool isEmpty() {
    return myCards.isEmpty;
  }

  /// Clear all cards
  static void clearCards() {
    myCards.clear();
  }
}
