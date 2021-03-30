class AdUnit {

  static final AdUnit favouritesBannerTop =
      new AdUnit._('ca-app-pub-4421922308722660/9905247705');

  static final AdUnit favouritesBannerBottom =
      new AdUnit._('ca-app-pub-4421922308722660~3018260097');

  static final AdUnit playerScreenMiddle =
      new AdUnit._('ca-app-pub-4421922308722660/5347797854');

  static final AdUnit searchScreenTop =
      new AdUnit._('ca-app-pub-4421922308722660/2050538916');

  static final AdUnit discoveryScreenTop =
      new AdUnit._('ca-app-pub-4421922308722660/3317365031');

  static final AdUnit discoveryScreenBottom =
      new AdUnit._('ca-app-pub-4421922308722660/2721634512');

  final String id;

  AdUnit._(this.id);

  @override
  String toString() {
    return 'AdUnit{id: $id}';
  }
}
