/// Level enum
enum Levels {
  beginner(levelName: 'Beginner', levelNum: 1),
  intermediate(levelName: 'Intermediate', levelNum: 5),
  advanced(levelName: 'Advanced', levelNum: 16);

  final String levelName;
  final int levelNum;

  const Levels({required this.levelName, required this.levelNum});
}
