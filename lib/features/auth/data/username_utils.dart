final _usernameRegExp = RegExp(r'^[a-z0-9._]{3,20}$'); // lowercase only

String normalizeUsername(String raw) {
  return raw.trim().toLowerCase();
}

bool isValidUsername(String username) {
  // already normalized (lowercase, no spaces). 3-30 chars allow letters, numbers, underscores
  return _usernameRegExp.hasMatch(username);
}
