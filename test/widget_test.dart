import 'package:flutter_test/flutter_test.dart';
import 'package:trophy_room/l10n.dart';
import 'package:trophy_room/worker_link.dart';

void main() {
  test('ikon adresi: uzantı yoksa .jpg eklenir, kilitliyken gri ikon seçilir', () {
    const a = WorkerAchievement(
        api: 'A', title: 't', desc: 'd', hidden: false, unlocked: false, icon: 'abc', iconGray: 'xyz.jpg');
    expect(a.iconUrl(730, unlocked: true), endsWith('/730/abc.jpg'));
    expect(a.iconUrl(730, unlocked: false), endsWith('/730/xyz.jpg'));
    const b = WorkerAchievement(api: 'B', title: '', desc: '', hidden: false, unlocked: false);
    expect(b.iconUrl(1, unlocked: true), isNull);
  });

  test('çeviri yer tutucuları ve Steam dil adı', () {
    expect(const S('en').t('unlocked_of', {'a': '3', 'b': '10'}), '3 / 10 unlocked');
    expect(const S('tr').steamLang, 'turkish');
    expect(const S('en').steamLang, 'english');
  });
}
