// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ja';

  static String m0(name) => "${name}のカレンダー";

  static String m1(address) => "確認リンクがメールアドレス（${address}）に送信されました";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addProfile": MessageLookupByLibrary.simpleMessage("プロフィール追加"),
        "calendarHeader": m0,
        "changeProfile": MessageLookupByLibrary.simpleMessage("プロフィール選択"),
        "copied": MessageLookupByLibrary.simpleMessage("コードをコピーしました"),
        "copy": MessageLookupByLibrary.simpleMessage("コードをコピー"),
        "createProfile": MessageLookupByLibrary.simpleMessage("プロフィール作成"),
        "dateOfBirthLabel": MessageLookupByLibrary.simpleMessage("生徒生年月日"),
        "dateOfBirthValidation":
            MessageLookupByLibrary.simpleMessage("生徒の生年月日を選択してください"),
        "firstNameHint": MessageLookupByLibrary.simpleMessage("太郎"),
        "firstNameLabel": MessageLookupByLibrary.simpleMessage("生徒名"),
        "firstNameValidation":
            MessageLookupByLibrary.simpleMessage("生徒の名前を入力してください"),
        "goBack": MessageLookupByLibrary.simpleMessage("戻る"),
        "lastNameHint": MessageLookupByLibrary.simpleMessage("山田"),
        "lastNameLabel": MessageLookupByLibrary.simpleMessage("生徒性"),
        "lastNameValidation":
            MessageLookupByLibrary.simpleMessage("生徒の名字を入力してください"),
        "lessonCalendar": MessageLookupByLibrary.simpleMessage("レッスンカレンダー"),
        "manageSubscription":
            MessageLookupByLibrary.simpleMessage("サブスクリプション管理"),
        "minimumCourse": MessageLookupByLibrary.simpleMessage("ミニマムコース・月＄３０"),
        "minimumPreschoolCourse":
            MessageLookupByLibrary.simpleMessage("ミニマムコース＋未就学児クラス・月＄４０"),
        "myCode": MessageLookupByLibrary.simpleMessage("紹介コード"),
        "name": MessageLookupByLibrary.simpleMessage("名前"),
        "next": MessageLookupByLibrary.simpleMessage("次へ"),
        "pickPlan": MessageLookupByLibrary.simpleMessage("サブスクリプションのコースを選択"),
        "profile": MessageLookupByLibrary.simpleMessage("プロフィール"),
        "reloadPage": MessageLookupByLibrary.simpleMessage("再読み込み"),
        "selectProfile":
            MessageLookupByLibrary.simpleMessage("プロフィールを選択してください"),
        "settings": MessageLookupByLibrary.simpleMessage("設定"),
        "signIn": MessageLookupByLibrary.simpleMessage("サインイン"),
        "signOut": MessageLookupByLibrary.simpleMessage("サインアウト"),
        "stripePurchase": MessageLookupByLibrary.simpleMessage("サブスクリプション購入へ"),
        "timeZoneLabel": MessageLookupByLibrary.simpleMessage("時間帯"),
        "timeZoneValidation":
            MessageLookupByLibrary.simpleMessage("有効の時間帯を選択してください"),
        "today": MessageLookupByLibrary.simpleMessage("今日"),
        "verifyEmailAction": MessageLookupByLibrary.simpleMessage(
            "登録を続けるには確認リンクをクリックしてください。受信トレイにメールがない場合は迷惑メールかゴミ箱に入ってる可能性があるのでご確認ください。"),
        "verifyEmailMessage": m1,
        "viewProfile": MessageLookupByLibrary.simpleMessage("プロフィールを見る")
      };
}