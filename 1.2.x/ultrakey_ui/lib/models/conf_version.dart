enum ConfigVersion {
  kbm1_2_3();

  static ConfigVersion kbmLatest = kbm1_2_3;

  static String toLabel(ConfigVersion ver) {
    return ver.toString().replaceAll("ConfigVersion.", "").replaceAll("_", ".");
  }

  static ConfigVersion fromLabel() {
    return kbm1_2_3;
  }
}