import '../models/product.dart';

abstract class ShopRepository {
  Future<List<Product>> products();
}

class InMemoryShopRepository implements ShopRepository {
  final _items = <Product>[
    Product(id:'p1', name:'Huile de Baobab', description:'100% pure', priceCfa: 3500),
    Product(id:'p2', name:'Huile de Ricin', description:'Pressée à froid', priceCfa: 2500),
    Product(id:'p3', name:'Huile de Fenugrec', description:'Qualité premium', priceCfa: 3000),
  ];
  @override
  Future<List<Product>> products() async => _items;
}
