import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../account/data/account_model.dart';
import '../../account/widgets/manage_users_page.dart';
import '../../account/widgets/settings_page.dart';
import '../../calendar/widgets/calendar_view.dart';
import '../../constants.dart' as constants;
import '../../generated/l10n.dart';
import '../../lesson_info/widgets/lesson_info_page.dart';
import '../../profile/widgets/add_points_page.dart';
import '../../profile/widgets/profile_home_page.dart';

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  late final List<Widget> _content;
  int _selectedIndex = 0;
  bool _extended = false;

  @override
  void initState() {
    super.initState();
    switch (context.read<AccountModel>().userType) {
      case UserType.admin:
        _content = [
          const ProfileHomePage(),
          const CalendarView(),
          const LessonInfoPage(),
          const ManageUsersPage(),
          const SettingsPage(),
        ];
        break;
      case UserType.teacher:
        _content = [
          const ProfileHomePage(),
          const CalendarView(),
          const LessonInfoPage(),
          const SettingsPage(),
        ];
        break;
      case UserType.student:
        _content = [
          const ProfileHomePage(),
          const CalendarView(),
          const LessonInfoPage(),
          const AddPointsPage(),
          const SettingsPage(),
        ];
        break;
      default:
        _content = [];
        break;
    }
  }

  List<NavigationRailDestination> _getDestinations() {
    switch (context.watch<AccountModel>().userType) {
      case UserType.admin:
        return [
          NavigationRailDestination(
            icon: const Icon(Icons.account_box_outlined),
            selectedIcon: const Icon(Icons.account_box),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).viewProfile),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).lessonCalendar),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).lessonInfo),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.people_outlined),
            selectedIcon: const Icon(Icons.people),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).manageProfile),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).settings),
          ),
        ];
      case UserType.teacher:
        return [
          NavigationRailDestination(
            icon: const Icon(Icons.account_box_outlined),
            selectedIcon: const Icon(Icons.account_box),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).viewProfile),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).lessonCalendar),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).lessonInfo),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).settings),
          ),
        ];
      case UserType.student:
        return [
          NavigationRailDestination(
            icon: const Icon(Icons.account_box_outlined),
            selectedIcon: const Icon(Icons.account_box),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).viewProfile),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).lessonCalendar),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).lessonInfo),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.add),
            selectedIcon: const Icon(Icons.add_outlined),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).addPoints),
          ),
          NavigationRailDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            padding: const EdgeInsets.symmetric(vertical: 5),
            label: Text(S.of(context).settings),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 1,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
            ),
            Text(
              constants.homePageAppBarName,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              account.locale = account.locale == 'en' ? 'ja' : 'en';
            },
            child: Text(account.locale == 'en' ? 'US' : 'JP'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text(S.of(context).signOut),
          )
        ],
      ),
      body: Row(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: IconButton(
                  onPressed: () => setState(() {
                    _extended = !_extended;
                  }),
                  icon: Icon(
                    _extended ? Icons.chevron_left : Icons.chevron_right,
                  ),
                ),
              ),
              Expanded(
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  extended: _extended,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  groupAlignment: -0.8,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  selectedLabelTextStyle: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                  unselectedLabelTextStyle:
                      Theme.of(context).textTheme.labelLarge,
                  destinations: _getDestinations(),
                ),
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _content,
            ),
          ),
        ],
      ),
      bottomSheet: account.shouldShowContent()
          ? null
          : MaterialBanner(
              leading: const Icon(Icons.block),
              content: Text(S.of(context).noPlan),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              actions: [
                FilledButton.tonal(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  child: Text(S.of(context).addPlan),
                )
              ],
            ),
    );
  }
}
