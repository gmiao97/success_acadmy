import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:success_academy/account/account_model.dart';
import 'package:success_academy/constants.dart' as constants;
import 'package:success_academy/generated/l10n.dart';
import 'package:success_academy/profile/profile_model.dart';
import 'package:success_academy/services/profile_service.dart'
    as profile_service;
import 'package:success_academy/utils.dart' as utils;

// TODO: Make UI responsive for different screen sizes
class ProfileBrowse extends StatefulWidget {
  const ProfileBrowse({Key? key}) : super(key: key);

  @override
  State<ProfileBrowse> createState() => _ProfileBrowseState();
}

class _ProfileBrowseState extends State<ProfileBrowse> {
  List<StudentProfileModel> _studentProfiles = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initProfiles();
  }

  void initProfiles() async {
    final account = context.watch<AccountModel>();
    final studentProfiles = await profile_service
        .getStudentProfilesForUser(account.firebaseUser!.uid);
    setState(() {
      _studentProfiles = studentProfiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return utils.buildLoggedInScaffold(
      context: context,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).selectProfile,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 50),
            // TODO: Add error handling.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final profile in _studentProfiles)
                  _buildProfileCard(context, profile),
                _studentProfiles.length < constants.maxProfileCount
                    ? const _AddProfileWidget()
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Card _buildProfileCard(BuildContext context, StudentProfileModel profile) {
  final account = context.watch<AccountModel>();

  return Card(
    elevation: 10.0,
    child: InkWell(
      splashColor: Theme.of(context).colorScheme.primary.withAlpha(30),
      onTap: () {
        account.studentProfile = profile;
      },
      child: SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: Text(profile.firstName,
              style: Theme.of(context).textTheme.headlineMedium),
        ),
      ),
    ),
  );
}

class _AddProfileWidget extends StatelessWidget {
  const _AddProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.primary.withAlpha(30),
        onTap: () {
          Navigator.pushNamed(context, constants.routeCreateProfile);
        },
        child: SizedBox(
          width: 200,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
                size: 50,
              ),
              Text(S.of(context).addProfile),
            ],
          ),
        ),
      ),
    );
  }
}
