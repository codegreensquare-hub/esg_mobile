import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';

class ProductOptionDefinition {
  const ProductOptionDefinition({
    required this.id,
    required this.label,
    required this.parameterRowId,
    required this.values,
  });

  final String id;
  final String label;
  final String parameterRowId;
  final List<ProductOptionValueRow> values;
}
