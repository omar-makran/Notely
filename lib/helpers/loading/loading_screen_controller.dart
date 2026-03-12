typedef CloseLoadingScreen = void Function();
typedef UpdateLoadingScreen = void Function(String text);

class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreen update;

  LoadingScreenController({required this.close, required this.update});
}
