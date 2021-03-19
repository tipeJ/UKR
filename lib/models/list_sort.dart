class ListSort {
  final bool ignoreArticle;
  final String method;
  final Order order;
  final bool userArtistSortName;

  const ListSort(
      {this.ignoreArticle = false,
      this.userArtistSortName = false,
      this.order = Order.Ascending,
      required this.method});

  Map<String, dynamic> toJson() => {
        "ignorearticle": ignoreArticle,
        "method": method,
        "order": order.toString().substring(6).toLowerCase(),
        "useartistsortname": userArtistSortName
      };

  /// Default Sort
  static const ListSort defaultSort = ListSort(
      method: "none",
      ignoreArticle: false,
      userArtistSortName: false,
      order: Order.Ascending);
}

enum Order { Ascending, Descending }
