import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  static const _navy = Color(0xFF0D1B2A);
  static const _amber = Color(0xFFF4A535);
  static const _surface = Color(0xFF1C2B3D);
  static const _muted = Color(0xFF8A8FA0);
  static const _warmWhite = Color(0xFFF8F5F0);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(scaffoldBackgroundColor: _navy),
      child: Scaffold(
        backgroundColor: _navy,
        body: CustomScrollView(
          slivers: [
            _buildHeroAppBar(context),
            SliverToBoxAdapter(child: _buildContent(context)),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: _navy,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: _navy.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _warmWhite,
              size: 20,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image
            Image.network(
              product.thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _surface,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: _muted,
                  size: 48,
                ),
              ),
            ),

            // Gradient fade to background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, _navy.withOpacity(0.4), _navy],
                    stops: const [0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category label
          Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              color: _amber,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),

          const SizedBox(height: 8),

          // Title
          Text(
            product.title,
            style: const TextStyle(
              color: _warmWhite,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // Price & Rating row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "\$${product.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: _amber,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              _buildRatingBadge(),
            ],
          ),

          const SizedBox(height: 24),

          // Divider
          Divider(color: Colors.white.withOpacity(0.08), thickness: 1),

          const SizedBox(height: 20),

          // Description label
          Text(
            "DESCRIPTION",
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            product.description,
            style: TextStyle(
              color: _warmWhite.withOpacity(0.75),
              fontSize: 15,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 32),

          // Specs row
          _buildSpecsRow(),

          const SizedBox(height: 100), // space for bottom bar
        ],
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _amber, size: 16),
          const SizedBox(width: 5),
          Text(
            "${product.rating}",
            style: const TextStyle(
              color: _warmWhite,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            " / 5",
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsRow() {
    return Row(
      children: [
        _buildSpecCard(
          icon: Icons.local_offer_outlined,
          label: "Category",
          value:
              product.category[0].toUpperCase() + product.category.substring(1),
        ),
        const SizedBox(width: 12),
        _buildSpecCard(
          icon: Icons.verified_outlined,
          label: "Rating",
          value: "${product.rating} stars",
        ),
        const SizedBox(width: 12),
        _buildSpecCard(
          icon: Icons.attach_money_rounded,
          label: "Price",
          value: "\$${product.price.toStringAsFixed(2)}",
        ),
      ],
    );
  }

  Widget _buildSpecCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _amber, size: 18),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: _warmWhite,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: _navy,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          // Wishlist button
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: _warmWhite,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // Add to cart button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amber,
                  foregroundColor: _navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
