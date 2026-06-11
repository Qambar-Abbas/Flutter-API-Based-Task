import 'dart:async';

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();

  int limit = 10;
  int skip = 0;
  bool isLoading = false;

  String selectedCategory = "All";

  Timer? _debounce;

  static const _categories = [
    "All",
    "beauty",
    "fragrances",
    "furniture",
    "groceries",
  ];

  static const _navy = Color(0xFF0D1B2A);
  static const _amber = Color(0xFFF4A535);
  static const _surface = Color(0xFF1C2B3D);
  static const _muted = Color(0xFF8A8FA0);
  static const _warmWhite = Color(0xFFF8F5F0);

  @override
  void initState() {
    super.initState();
    fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
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
      filteredProducts = _applyFilters(products);
      isLoading = false;
    });
  }

  List<Product> _applyFilters(List<Product> source) {
    final query = _searchController.text.toLowerCase();
    return source.where((p) {
      final matchesSearch =
          query.isEmpty || p.title.toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == "All" || p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => filteredProducts = _applyFilters(products));
    });
  }

  void filterProducts(String category) {
    setState(() {
      selectedCategory = category;
      filteredProducts = _applyFilters(products);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _navy,
        colorScheme: const ColorScheme.dark(primary: _amber, surface: _surface),
      ),
      child: Scaffold(
        backgroundColor: _navy,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategoryRow(),
              const SizedBox(height: 8),
              Expanded(child: _buildProductList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SHOP",
            style: TextStyle(
              color: _amber,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Discover Products",
            style: TextStyle(
              color: _warmWhite,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: searchProducts,
          style: const TextStyle(color: _warmWhite, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Search products...",
            hintStyle: TextStyle(color: _muted, fontSize: 15),
            prefixIcon: Icon(Icons.search_rounded, color: _muted, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: _muted, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      searchProducts('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => filterProducts(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _amber : _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _amber : Colors.white.withOpacity(0.08),
                ),
              ),
              child: Text(
                cat[0].toUpperCase() + cat.substring(1),
                style: TextStyle(
                  color: selected ? _navy : _muted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    if (filteredProducts.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: _muted, size: 48),
            const SizedBox(height: 12),
            Text(
              "No products found",
              style: TextStyle(color: _muted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: filteredProducts.length + 1,
      itemBuilder: (context, index) {
        if (index < filteredProducts.length) {
          return _buildProductCard(filteredProducts[index]);
        }
        return isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: _amber,
                    strokeWidth: 2,
                  ),
                ),
              )
            : const SizedBox(height: 16);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                product.thumbnail,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: _navy,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: _muted,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        color: _amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _warmWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: _warmWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.star_rounded, color: _amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          "${product.rating}",
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
