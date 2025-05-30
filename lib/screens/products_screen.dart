import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/product_manager.dart';
import '../managers/product_group_manager.dart';
import '../models/product.dart';
import '../models/product_group.dart';
import '../widgets/edit_group_screen.dart';
import '../widgets/edit_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Product? _searchedProduct;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductManager>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchByArticle(BuildContext context) {
    final article = _searchController.text.trim();
    if (article.isEmpty) {
      setState(() => _searchedProduct = null);
      return;
    }
    final productManager = context.read<ProductManager>();
    final found = productManager.findByArticle(article);
    setState(() => _searchedProduct = found);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Товары и Группы')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Поиск по артикулу',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      // Автоматически сбрасываем результат поиска при стирании
                      if (_searchController.text.isEmpty && _searchedProduct != null) {
                        setState(() => _searchedProduct = null);
                      }
                    },
                    onSubmitted: (_) => _searchByArticle(context),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchByArticle(context),
                  child: const Icon(Icons.search),
                ),
                if (_searchedProduct != null || _searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchedProduct = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          if (_searchedProduct != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Card(
                color: Colors.yellow[100],
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text(_searchedProduct!.name),
                  subtitle: Text('Артикул: ${_searchedProduct!.article}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editProduct(context, _searchedProduct!),
                  ),
                  onTap: () => _editProduct(context, _searchedProduct!),
                ),
              ),
            ),
          if (_searchedProduct == null)
            Expanded(
              child: Consumer2<ProductManager, ProductGroupManager>(
                builder: (context, productManager, groupManager, _) {
                  final rootGroups = groupManager.getSubgroups(null);
                  final rootProducts = productManager.getProductsByGroup(null);

                  return RefreshIndicator(
                    onRefresh: () async => productManager.fetchProducts(),
                    child: ListView(
                      children: [
                        _buildSectionTitle('Группы'),
                        ...rootGroups.map((g) => _GroupTile(group: g)),
                        _buildSectionTitle('Товары без группы'),
                        ...rootProducts.map((p) => _ProductTile(product: p)),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'add_group',
              icon: const Icon(Icons.create_new_folder),
              label: const Text('Группа'),
              onPressed: () => _showEditGroupDialog(context, null),
            ),
            FloatingActionButton.extended(
              heroTag: 'add_product',
              icon: const Icon(Icons.add),
              label: const Text('Товар'),
              onPressed: () => _showEditProductDialog(context, null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, String? parentId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditGroupScreen(
          group: ProductGroup(id: '', name: '', parentId: parentId),
          allGroups: context.read<ProductGroupManager>().groups,
        ),
      ),
    );
    if (!mounted) return;
    if (result is ProductGroup) {
      context.read<ProductGroupManager>().addGroup(result);
    }
  }

  void _showEditProductDialog(BuildContext context, String? groupId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(
          product: Product(
            id: '',
            name: '',
            article: '',
            price: 0,
            type: 'Товар',
            groupId: groupId,
          ),
          groups: context.read<ProductGroupManager>().groups,
        ),
      ),
    );
    if (!mounted) return;
    if (result is Product) {
      context.read<ProductManager>().addProduct(result);
    }
  }

  void _editProduct(BuildContext context, Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(
          product: product,
          groups: context.read<ProductGroupManager>().groups,
        ),
      ),
    );
    if (!mounted) return;
    if (result is Product) {
      context.read<ProductManager>().updateProduct(result);
      if (_searchedProduct != null && result.article == _searchedProduct!.article) {
        setState(() {
          _searchedProduct = result;
        });
      }
    }
  }
}

class _GroupTile extends StatelessWidget {
  final ProductGroup group;

  const _GroupTile({required this.group});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(group.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editGroup(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteGroup(context),
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupDetailScreen(parentGroup: group),
        ),
      ),
    );
  }

  void _editGroup(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditGroupScreen(
          group: group,
          allGroups: context.read<ProductGroupManager>().groups,
        ),
      ),
    );
    if (!context.mounted) return;
    if (result is ProductGroup) {
      context.read<ProductGroupManager>().updateGroup(result);
    }
  }

  void _deleteGroup(BuildContext context) async {
    final productManager = context.read<ProductManager>();
    final groupManager = context.read<ProductGroupManager>();
    final productsInGroup = productManager.getProductsByGroup(group.id);
    final subgroups = groupManager.getSubgroups(group.id);

    if (productsInGroup.isNotEmpty || subgroups.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нельзя удалить группу: сначала удалите все товары и подгруппы!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить группу?'),
        content: Text('Вы уверены, что хотите удалить "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirm == true) {
      context.read<ProductGroupManager>().removeGroup(group.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Группа "${group.name}" удалена')),
      );
    }
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.shopping_bag),
      title: Text(product.name),
      subtitle: Text('Артикул: ${product.article}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editProduct(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteProduct(context),
          ),
        ],
      ),
      onTap: () => _editProduct(context),
    );
  }

  void _editProduct(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(
          product: product,
          groups: context.read<ProductGroupManager>().groups,
        ),
      ),
    );
    if (!context.mounted) return;
    if (result is Product) {
      context.read<ProductManager>().updateProduct(result);
    }
  }

  void _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text('Вы уверены, что хотите удалить "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirm == true) {
      context.read<ProductManager>().removeProduct(product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Товар "${product.name}" удалён')),
      );
    }
  }
}

class GroupDetailScreen extends StatelessWidget {
  final ProductGroup parentGroup;

  const GroupDetailScreen({super.key, required this.parentGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(parentGroup.name)),
      body: Consumer2<ProductManager, ProductGroupManager>(
        builder: (context, productManager, groupManager, _) {
          final subgroups = groupManager.getSubgroups(parentGroup.id);
          final products = productManager.getProductsByGroup(parentGroup.id);

          return ListView(
            children: [
              ...subgroups.map((g) => _GroupTile(group: g)),
              ...products.map((p) => _ProductTile(product: p)),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'add_subgroup_${parentGroup.id}',
              icon: const Icon(Icons.create_new_folder),
              label: const Text('Группа'),
              onPressed: () => _showEditGroupDialog(context),
            ),
            FloatingActionButton.extended(
              heroTag: 'add_product_${parentGroup.id}',
              icon: const Icon(Icons.add),
              label: const Text('Товар'),
              onPressed: () => _showEditProductDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditGroupScreen(
          group: ProductGroup(id: '', name: '', parentId: parentGroup.id),
          allGroups: context.read<ProductGroupManager>().groups,
        ),
      ),
    );
    if (!context.mounted) return;
    if (result is ProductGroup) {
      context.read<ProductGroupManager>().addGroup(result);
    }
  }

  void _showEditProductDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(
          product: Product(
            id: '',
            name: '',
            article: '',
            price: 0,
            type: 'Товар',
            groupId: parentGroup.id,
          ),
          groups: context.read<ProductGroupManager>().groups,
        ),
      ),
    );
    if (!context.mounted) return;
    if (result is Product) {
      context.read<ProductManager>().addProduct(result);
    }
  }
}
