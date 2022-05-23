extension MetersDistance on double {
  String inDistance() {
    int km = this ~/ 1000;
    if (km >= 1) {
      double km = this / 1000;
      String kmString = "${km.toStringAsFixed(1)}  kilometer";
      if (km > 1) kmString += "s";
      return kmString;
    } else {
      double meter = this;
      String mString = "${meter.toStringAsFixed(1)} meter";
      if (meter > 1) mString += "s";
      return mString;
    }
  }
}
