class ProductsParams {
  final String? subId;
  final String search;

  const ProductsParams({this.subId, this.search = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsParams &&
          runtimeType == other.runtimeType &&
          subId == other.subId &&
          search == other.search;

  @override
  int get hashCode => subId.hashCode ^ search.hashCode;
}
