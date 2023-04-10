import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rrule/rrule.dart';
import 'package:success_academy/account/account_model.dart';
import 'package:success_academy/calendar/calendar_utils.dart';
import 'package:success_academy/calendar/event_model.dart';
import 'package:success_academy/generated/l10n.dart';
import 'package:success_academy/profile/profile_model.dart';
import 'package:success_academy/services/event_service.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ViewEventDialog extends StatefulWidget {
  const ViewEventDialog({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  State<ViewEventDialog> createState() => _ViewEventDialogState();
}

class _ViewEventDialogState extends State<ViewEventDialog> {
  EventModel? _recurrenceEvent;
  TeacherProfileModel? _teacher;
  List<StudentProfileModel?> _students = [];
  bool _isLoadingRecurringEvent = true;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadRecurrenceEvent();
    final account = context.read<AccountModel>();
    _teacher = account.teacherProfileModelMap[widget.event.teacherId];
    _students = widget.event.studentIdList
        .map((id) => account.studentProfileMap[id])
        .toList();
  }

  void _loadRecurrenceEvent() async {
    final recurrenceId = widget.event.recurrenceId;
    if (recurrenceId != null) {
      try {
        final event = await getEvent(
          eventId: recurrenceId,
          location:
              tz.getLocation(context.read<AccountModel>().myUser!.timeZone),
        );
        setState(() {
          _recurrenceEvent = event;
          _isLoadingRecurringEvent = false;
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).failedGetRecurrenceEvent),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        });
      }
    } else {
      _isLoadingRecurringEvent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AccountModel, String>((a) => a.locale);
    final userType = context.select<AccountModel, UserType>((a) => a.userType);
    final rrule = _recurrenceEvent != null
        ? RecurrenceRule.fromString(_recurrenceEvent!.recurrence[0])
        : null;

    return AlertDialog(
      actions: [
        TextButton(
          child: Text(S.of(context).close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 350,
          minHeight: 300,
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.event.summary,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.event.eventType.getName(context),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.labelLarge,
                  children: [
                    const WidgetSpan(child: Icon(Icons.access_time)),
                    TextSpan(
                        text:
                            '${DateFormat.MMMMd(locale).add_jm().format(widget.event.startTime)} - ${DateFormat.MMMMd(locale).add_jm().format(widget.event.endTime)}')
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.labelLarge,
                  children: [
                    const WidgetSpan(child: Icon(Icons.repeat)),
                    _isLoadingRecurringEvent
                        ? WidgetSpan(
                            child: Transform.scale(
                              scale: 0.5,
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : TextSpan(text: rruleToString(context, rrule))
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.labelLarge,
                  children: [
                    const WidgetSpan(child: Icon(Icons.shopping_cart)),
                    TextSpan(
                        text: S
                            .of(context)
                            .eventPointsDisplay(widget.event.numPoints))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${S.of(context).teacherTitle} - ',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    _teacher != null
                        ? TextSpan(
                            text:
                                '${_teacher!.lastName} ${_teacher!.firstName}',
                            style: Theme.of(context).textTheme.labelLarge,
                          )
                        : TextSpan(
                            text: S.of(context).unspecified,
                            style: Theme.of(context).textTheme.labelLarge,
                          )
                  ],
                ),
              ),
              if (userType != UserType.student)
                Column(
                  children: [
                    Text(
                      S.of(context).studentListTitle,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    for (final s in _students)
                      if (s != null) Text('・${s.lastName} ${s.firstName}'),
                  ],
                ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 100,
                ),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(widget.event.description),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
