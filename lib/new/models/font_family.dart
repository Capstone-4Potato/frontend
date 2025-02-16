/// 폰트 이름 저장
enum FontFamily {
  bmJua(fontName: 'BM_Jua'),
  marine(fontName: 'Marine'),
  madeTommySoft(fontName: 'MADE-Tommy-Soft');

  final String fontName;

  const FontFamily({required this.fontName});
}
