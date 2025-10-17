import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/repositories/shop_repository.dart';

final shopRepoProvider = Provider<ShopRepository>((ref) => InMemoryShopRepository());
final cartProvider = StateProvider<List<Product>>((ref) => []);

class ShopHome extends ConsumerWidget {
  const ShopHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Boutique'),
          bottom: const TabBar(tabs: [Tab(text: 'Produits'), Tab(text: 'Panier')]),
        ),
        body: const TabBarView(children: [ProductsTab(), CartTab()]),
      ),
    );
  }
}

class ProductsTab extends ConsumerWidget {
  const ProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(shopRepoProvider).products(),
      builder: (ctx, snap) {
        final items = snap.data ?? [];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final p = items[i];
            return ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(p.name),
              subtitle: Text('${p.description} — ${p.priceCfa} CFA'),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () {
                  final cart = ref.read(cartProvider.notifier);
                  cart.state = [...cart.state, p];
                },
              ),
            );
          },
        );
      },
    );
  }
}

class CartTab extends ConsumerWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<int>(0, (s, p) => s + p.priceCfa);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: cart.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (ctx, i) {
              final p = cart[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${p.priceCfa} CFA'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    final n = [...cart]..removeAt(i);
                    ref.read(cartProvider.notifier).state = n;
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: $total CFA', style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: cart.isEmpty ? null : () {}, child: const Text('Commander')),
            ],
          ),
        )
      ],
    );
  }
}
