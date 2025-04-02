String getStarsString(double note) {
  String res = '';

  final fullStars = note.floor();
  final hasHalfStar = (note - fullStars) >= 0.5;
  final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

  res += '★' * fullStars;
  if (hasHalfStar) {
    res += '⯪';
  }
  res += '☆' * emptyStars;

  return res;
}
