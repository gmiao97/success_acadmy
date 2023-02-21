import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:success_academy/account/account_model.dart';
import 'package:success_academy/generated/l10n.dart';
import 'package:success_academy/main.dart';
import 'package:success_academy/profile/profile_browse.dart';
import 'package:success_academy/profile/profile_model.dart';
import 'package:success_academy/services/lesson_info_service.dart'
    as lesson_info_service;
import 'package:success_academy/utils.dart' as utils;
import 'package:webviewx/webviewx.dart';

class FreeLesson extends StatelessWidget {
  const FreeLesson({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountModel>();

    if (account.authStatus == AuthStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          value: null,
        ),
      );
    }
    if (account.authStatus == AuthStatus.emailVerification) {
      return const EmailVerificationPage();
    }
    if (account.authStatus == AuthStatus.signedOut) {
      return const HomePage();
    }
    if (account.userType == UserType.studentNoProfile) {
      return const ProfileBrowse();
    }
    if (account.userType == UserType.admin) {
      return utils.buildAdminProfileScaffold(
        context: context,
        body: const _FreeLesson(),
      );
    }
    if (account.userType == UserType.teacher) {
      return utils.buildTeacherProfileScaffold(
        context: context,
        body: const _FreeLesson(),
      );
    }
    return utils.buildStudentProfileScaffold(
      context: context,
      body: const _FreeLesson(),
    );
  }
}

class _FreeLesson extends StatefulWidget {
  const _FreeLesson({Key? key}) : super(key: key);

  @override
  State<_FreeLesson> createState() => _FreeLessonState();
}

class _FreeLessonState extends State<_FreeLesson> {
  late WebViewXController webviewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountModel>();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                S.of(context).freeLessonTimeTable,
                style: Theme.of(context).textTheme.headline3,
              ),
              const SizedBox(height: 8),
              WebViewX(
                width: 700,
                height: 300,
                onWebViewCreated: (controller) => controller.loadContent(
                    'https://drive.google.com/embeddedfolderview?id=1z5WUmx_lFVRy3YbmtEUH-tIqrwsaP8au#list',
                    SourceType.url),
              ),
              const SizedBox(height: 20),
              Text(
                S.of(context).freeLessonMaterials,
                style: Theme.of(context).textTheme.headline3,
              ),
              const SizedBox(height: 8),
              WebViewX(
                width: 700,
                height: 300,
                onWebViewCreated: (controller) => controller.loadContent(
                    'https://drive.google.com/embeddedfolderview?id=1EMhq3GkTEfsk5NiSHpqyZjS4H2N_aSak#list',
                    SourceType.url),
              ),
              const SizedBox(height: 20),
              account.userType != UserType.student ||
                      (account.subscriptionPlan != null &&
                          account.subscriptionPlan != SubscriptionPlan.monthly)
                  ? ZoomInfo()
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class ZoomInfo extends StatefulWidget {
  const ZoomInfo({Key? key}) : super(key: key);

  @override
  State<ZoomInfo> createState() => _ZoomInfoState();
}

class _ZoomInfoState extends State<ZoomInfo> {
  List<List<String>> zoomInfo = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initLessons();
  }

  void initLessons() async {
    final account = context.watch<AccountModel>();
    final lessons = await lesson_info_service.getLessons(
        includePreschool: account.userType != UserType.student ||
            account.subscriptionPlan == SubscriptionPlan.minimumPreschool);
    setState(() {
      for (final l in lessons) {
        zoomInfo.add([
          l['name'] as String,
          l['zoom_link'] as String,
          l['zoom_id'] as String,
          l['zoom_pw'] as String
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).freeLessonZoomInfo,
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(
          width: 1000,
          child: PaginatedDataTable(
              rowsPerPage: 5,
              columns: <DataColumn>[
                DataColumn(
                  label: Expanded(
                    child: Text(
                      S.of(context).lesson,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      S.of(context).link,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      S.of(context).meetingId,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      S.of(context).password,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ],
              source: _ZoomInfoDataSource(data: zoomInfo)),
        )
      ],
    );
  }
}

class _ZoomInfoDataSource extends DataTableSource {
  _ZoomInfoDataSource({required List data}) : _data = data;

  final List _data;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index][0])),
      DataCell(InkWell(
        child: const Text(
          'Zoom',
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.blue,
          ),
        ),
        onTap: () {
          html.window.open(_data[index][1], 'Zoom');
        },
      )),
      DataCell(Text(_data[index][2])),
      DataCell(Text(_data[index][3])),
    ]);
  }
}
