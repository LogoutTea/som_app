class Product {
  final String id;
  final String name;
  final String article;
  final double price;
  final String? ean13;
  final int? quantity;
  final String type;
  final String? groupId;
  final bool isMarked;
  final String? markedCategory;
  final String country; //страна при создании номенклатуры
  final double nds; //ндс при создании карточки товара

  Product({
    required this.id,
    required this.name,
    required this.article,
    required this.price,
    this.ean13,
    this.quantity,
    required this.type,
    this.groupId,
    this.isMarked = false,
    this.markedCategory,
    this.country = 'Россия', //чтобы стандартно россия подставлялась
    this.nds = 20.0, //стандартный ндс 20% при создании карточки подставлялся автоматом
  });

  Product copyWith({
    String? id,
    String? name,
    String? article,
    double? price,
    String? ean13,
    int? quantity,
    String? type,
    String? groupId,
    bool? isMarked,
    String? markedCategory,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      article: article ?? this.article,
      price: price ?? this.price,
      ean13: ean13 ?? this.ean13,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      groupId: groupId ?? this.groupId,
      isMarked: isMarked ?? this.isMarked,
      markedCategory: markedCategory ?? this.markedCategory,
    );
  }
}
