import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rrule/rrule.dart';
import 'package:success_academy/account/account_model.dart';
import 'package:success_academy/calendar/event_model.dart';
import 'package:success_academy/constants.dart';
import 'package:success_academy/generated/l10n.dart';
import 'package:success_academy/profile/profile_model.dart';
import 'package:success_academy/services/event_service.dart' as event_service;
import 'package:success_academy/services/profile_service.dart'
    as profile_service;
import 'package:timezone/data/latest_10y.dart' as tz;

class SignupEventDialog extends StatefulWidget {
  const SignupEventDialog({
    Key? key,
    required this.event,
    required this.onRefresh,
  }) : super(key: key);

  final EventModel event;
  final void Function() onRefresh;

  @override
  State<SignupEventDialog> createState() => _SignupEventDialogState();
}

class _SignupEventDialogState extends State<SignupEventDialog> {
  late AccountModel _accountContext;
  late DateTime _day;
  late DateTime? _recurUntil;
  late String _summary;
  String? _teacherName;
  late String _description;
  int? _numPoints;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late EventType _eventType;
  late Frequency? _recurFrequency;
  late bool _isSignedUp;
  bool _submitClicked = false;

  @override
  void initState() {
    super.initState();
    _accountContext = context.read<AccountModel>();
    tz.initializeTimeZones();
    final RecurrenceRule? rrule = widget.event.recurrence.isNotEmpty
        ? RecurrenceRule.fromString(widget.event.recurrence[0])
        : null;
    setState(() {
      _day = DateTime(widget.event.startTime.year, widget.event.startTime.month,
          widget.event.startTime.day);
      _summary = widget.event.summary;
      _teacherName = widget.event.teacherId != null
          ? '${_accountContext.teacherProfileModelMap![widget.event.teacherId]!.lastName} ${_accountContext.teacherProfileModelMap![widget.event.teacherId]!.firstName}'
          : null;
      _description = widget.event.description;
      _numPoints = widget.event.numPoints;
      _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.event.endTime);
      _eventType = widget.event.eventType;
      _recurFrequency = rrule?.frequency;
      _recurUntil = rrule?.until;
      _isSignedUp = widget.event.studentIdList
          .contains(_accountContext.studentProfile!.profileId);
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<EventType, String> eventTypeNames = {
      EventType.free: S.of(context).free,
      EventType.preschool: S.of(context).preschool,
      EventType.private: S.of(context).private,
    };

    Map<Frequency?, String> frequencyNames = {
      null: S.of(context).recurNone,
      Frequency.daily: S.of(context).recurDaily,
      Frequency.weekly: S.of(context).recurWeekly,
      Frequency.monthly: S.of(context).recurMonthly,
    };

    return AlertDialog(
      title: Text(
        S.of(context).signupEvent,
        style: Theme.of(context).textTheme.headline6,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _summary,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            Text(eventTypeNames[_eventType]!),
            Text(S.of(context).eventPointsDisplay(_numPoints ?? 0)),
            Text(
              _teacherName ?? '',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
                '${dateFormatter.format(_day)} | ${_startTime.format(context)} - ${_endTime.format(context)}'),
            Text(
                '${frequencyNames[_recurFrequency]!}${_recurUntil != null ? ', ${S.of(context).recurEnd} ${dateFormatter.format(_recurUntil!)}' : ''}'),
            const SizedBox(
              height: 20,
            ),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 400,
                  height: 200,
                  child: SingleChildScrollView(
                    child: Text(_description),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(S.of(context).cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        _submitClicked
            ? const CircularProgressIndicator(
                value: null,
              )
            : Tooltip(
                message: _isSignedUp
                    ? S.of(context).refundPoints(_numPoints ?? 0)
                    : _accountContext.studentProfile!.numPoints <
                            (_numPoints ?? 0)
                        ? S.of(context).notEnoughPoints
                        : S.of(context).usePoints(_numPoints ?? 0,
                            _accountContext.studentProfile!.numPoints),
                child: ElevatedButton(
                  onPressed: _day.isAfter(DateTime.now()
                              .subtract(const Duration(days: 1))) &&
                          _accountContext.studentProfile!.numPoints >=
                              (_numPoints ?? 0)
                      ? () {
                          setState(() {
                            _submitClicked = true;
                          });

                          StudentProfileModel updatedProfile =
                              _accountContext.studentProfile!;
                          final event = widget.event;
                          event.recurrence.clear();
                          if (_isSignedUp) {
                            event.studentIdList.remove(
                                _accountContext.studentProfile!.profileId);
                            updatedProfile.numPoints += _numPoints ?? 0;
                          } else {
                            if (!event.studentIdList.contains(
                                _accountContext.studentProfile!.profileId)) {
                              event.studentIdList.add(
                                  _accountContext.studentProfile!.profileId);
                              updatedProfile.numPoints -= _numPoints ?? 0;
                            }
                          }
                          event_service.updateEvent(event).then((unused) {
                            widget.onRefresh();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: _isSignedUp
                                    ? Text(S.of(context).cancelSignupSuccess)
                                    : Text(S.of(context).signupSuccess),
                              ),
                            );
                          }).then((unused) {
                            return profile_service.updateStudentProfile(
                                _accountContext.firebaseUser!.uid,
                                updatedProfile);
                          }).catchError((err) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: _isSignedUp
                                    ? Text(S.of(context).cancelSignupFailure)
                                    : Text(S.of(context).signupFailure),
                              ),
                            );
                          }).whenComplete(() {
                            Navigator.of(context).pop();
                          });
                        }
                      : null,
                  child: _isSignedUp
                      ? Text(S.of(context).cancelSignup)
                      : Text(S.of(context).signup),
                ),
              ),
      ],
    );
  }
}
