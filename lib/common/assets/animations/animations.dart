const String _pathAnimations = 'assets/animations';

class AnimationsAsset {
  const AnimationsAsset(this.iconAsset);

  final String iconAsset;

  static AnimationsAsset get nfcAnimation =>
      const AnimationsAsset('$_pathAnimations/nfc_animation.gif');
}
