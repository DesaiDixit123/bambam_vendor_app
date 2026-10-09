/**
 * app/utils/name_match_util.dart
 * ──────────────────────────────
 * Name matching utility for verifying PAN, Bank, and GSTIN
 * document names against registered person / company name.
 */

String cleanName(String str) {
  return str
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const Set<String> _personNoise = {
  'mr', 'mrs', 'ms', 'shri', 'shree', 'bhai', 'ben', 'kumar', 'ji', 'dr', 'late'
};

const Set<String> _companyNoise = {
  'pvt', 'ltd', 'private', 'limited', 'llp', 'inc', 'co', 'corp', 'corporation',
  'enterprise', 'enterprises', 'company', 'india', 'logistics', 'mobility',
  'travels', 'cabs', 'solutions', 'services', 'transport', 'transports', 'industries'
};

bool checkNameMatch(String inputName, String docName, {String type = 'person'}) {
  final clean1 = cleanName(inputName);
  final clean2 = cleanName(docName);

  if (clean1.isEmpty || clean2.isEmpty) {
    return false;
  }

  // Exact or direct substring match
  if (clean1 == clean2 || clean1.contains(clean2) || clean2.contains(clean1)) {
    return true;
  }

  final noiseSet = type == 'company' ? _companyNoise : _personNoise;

  final tokens1 = clean1.split(' ').where((t) => t.length >= 3 && !noiseSet.contains(t)).toList();
  final tokens2 = clean2.split(' ').where((t) => t.length >= 3 && !noiseSet.contains(t)).toList();

  if (tokens1.isEmpty || tokens2.isEmpty) {
    final raw1 = clean1.split(' ').where((t) => t.length >= 3).toList();
    final raw2 = clean2.split(' ').where((t) => t.length >= 3).toList();
    return raw1.any((t1) => raw2.any((t2) => t1.contains(t2) || t2.contains(t1)));
  }

  final matchingTokens = tokens1.where((t1) =>
    tokens2.any((t2) => t1 == t2 || t1.contains(t2) || t2.contains(t1))
  ).toList();

  return matchingTokens.isNotEmpty;
}
