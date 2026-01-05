import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail_tab.screen.dart';
import 'package:flutter/material.dart';

class CodeGreenProductDetailTabController extends ChangeNotifier {
  ProductWithOtherDetails? _product;

  ProductWithOtherDetails? get product => _product;

  void select(ProductWithOtherDetails product) {
    _product = product;
    notifyListeners();
  }

  void clear() {
    if (_product == null) return;
    _product = null;
    notifyListeners();
  }
}

class CodeGreenProductDetailTab extends StatefulWidget {
  static const tab = 'product_detail';

  const CodeGreenProductDetailTab({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final CodeGreenProductDetailTabController controller;
  final VoidCallback onBack;

  @override
  State<CodeGreenProductDetailTab> createState() =>
      _CodeGreenProductDetailTabState();
}

class _CodeGreenProductDetailTabState extends State<CodeGreenProductDetailTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void didUpdateWidget(covariant CodeGreenProductDetailTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.controller.product;
    if (product == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('Select a product to view details.')),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: CodeGreenProductDetailTabScreen(
        productWithDetails: product,
        showAppBar: false,
        embedded: true,
        onBack: widget.onBack,
      ),
    );
  }
}
