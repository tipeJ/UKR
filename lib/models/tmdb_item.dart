class TMDBItem {
  final String name;
  final bool adult;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final int? budget;
  final String? homepage;

  const TMDBItem(
      {required this.name,
      required this.popularity,
      required this.voteAverage,
      required this.voteCount,
      this.adult = false,
      this.budget,
      this.homepage});
  factory TMDBItem.fromJson(dynamic j) => TMDBItem(
      name: j['name'],
      adult: j['adult'],
      popularity: j['popularity'],
      voteAverage: j['vote_average'],
      voteCount: j['vote_count'],
      budget: j['budget'],
      homepage: j['homepage']);
}
