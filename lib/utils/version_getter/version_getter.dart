class VersionGetter {
  // For now, returns a hardcoded version
  static String getAppVersion() {
    return '1.0.0';
  }

  // TODO: Implement database version fetching
  // This method can be updated later to fetch from database
  static Future<String> getVersionFromDatabase() async {
    // Placeholder for future database implementation
    return '1.0.0';
  }
}
