import 'dart:async';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

// Pagination
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  List<Product> products = [];
  List<Product> filteredProducts = [];

  final ScrollController _scrollController = ScrollController();

  int limit = 10;
  int skip = 0;
  bool isLoading = false;

  String selectedCategory = "All";

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchProducts();
      }
    });
  }

  Future<void> fetchProducts() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    List<Product> newProducts = await apiService.fetchProducts(limit, skip);

    setState(() {
      skip += limit;
      products.addAll(newProducts);
      filteredProducts = products;
      isLoading = false;
    });
  }

  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filteredProducts = products
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  void filterProducts(String category) {
    setState(() {
      selectedCategory = category;

      if (category == "All") {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((p) => p.category == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search products...",
                border: OutlineInputBorder(),
              ),
              onChanged: searchProducts,
            ),
          ),

          DropdownButton<String>(
            value: selectedCategory,
            items: [
              "All",
              "beauty",
              "fragrances",
              "furniture",
              "groceries",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {
              if (value != null) {
                filterProducts(value);
              }
            },
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: filteredProducts.length + 1,
              itemBuilder: (context, index) {
                if (index < filteredProducts.length) {
                  Product product = filteredProducts[index];

                  return ListTile(
                    leading: Image.network(
                      product.thumbnail,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.title),
                    subtitle: Text("\$${product.price}"),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                }

                return isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
