import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rrule/rrule.dart';
import 'package:timezone/data/latest_10y.dart' as tz show initializeTimeZones;
import 'package:timezone/timezone.dart' as tz show getLocation;
import 'package:timezone/timezone.dart' show Location, TZDateTime;

import '../../account/data/account_model.dart';
import '../../generated/l10n.dart';
import '../../profile/data/profile_model.dart';
import '../calendar_utils.dart';
import '../data/event_model.dart';
import '../services/event_service.dart' as event_service;

class CreateEventDialog extends StatefulWidget {
  final String? teacherId;
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime selectedDay;

  const CreateEventDialog({
    super.key,
    this.teacherId,
    required this.firstDay,
    required this.lastDay,
    required this.selectedDay,
  });

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _recurUntilController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  late final Location _location;
  late final String _locale;
  late final List<EventType> _eventTypes;

  late TZDateTime _start;
  late TZDateTime _end;
  late String _summary;
  late String _description;
  late EventType _eventType;
  int _numPoints = 0;
  String? _teacherId;
  bool _isRecur = false;
  TZDateTime? _recurUntil;
  Frequency _recurFrequency = Frequency.daily;
  bool _submitClicked = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();

    final account = context.read<AccountModel>();
    assert(canEditEvents(account.userType));
    _location = tz.getLocation(account.myUser!.timeZone);
    _locale = account.locale;
    _eventTypes = getEventTypesCanEdit(account.userType);
    assert(_eventTypes.isNotEmpty);

    _teacherId = widget.teacherId;
    final now = TZDateTime.now(_location);
    _start = TZDateTime(
      _location,
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      now.hour,
      now.minute,
    );
    _end = _start.add(const Duration(hours: 1));
    _startController.text = DateFormat.yMMMMd(_locale).add_jm().format(_start);
    _endController.text = DateFormat.yMMMMd(_locale).add_jm().format(_end);
    _eventType = _eventTypes[0];
  }

  Future<TZDateTime?> _pickDateTime({required TZDateTime initial}) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: widget.firstDay,
      lastDate: widget.lastDay,
    );
    // ignore: use_build_context_synchronously
    if (date == null || !context.mounted) {
      return null;
    }

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return null;
    }
    return TZDateTime(
      _location,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _selectStartTime() async {
    final TZDateTime? dateTime = await _pickDateTime(initial: _start);
    if (dateTime != null) {
      setState(() {
        final delta = _end.difference(_start);
        _start = dateTime;
        _startController.text =
            DateFormat.yMMMMd(_locale).add_jm().format(_start);
        _end = _start.add(delta);
        _endController.text = DateFormat.yMMMMd(_locale).add_jm().format(_end);
      });
    }
  }

  void _selectEndTime() async {
    final TZDateTime? dateTime = await _pickDateTime(initial: _end);
    if (dateTime != null) {
      setState(() {
        _end = dateTime;
        _endController.text = DateFormat.yMMMMd(_locale).add_jm().format(_end);
      });
    }
  }

  void _selectRecurUntil() async {
    final DateTime? day = await showDatePicker(
      context: context,
      initialDate: _recurUntil ?? _end,
      firstDate: widget.firstDay,
      lastDate: widget.lastDay,
    );
    if (day != null) {
      setState(() {
        _recurUntil = TZDateTime(_location, day.year, day.month, day.day)
            .add(const Duration(days: 1));
        _recurUntilController.text = DateFormat.yMMMMd(_locale).format(day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeZone =
        context.select<AccountModel, String>((a) => a.myUser!.timeZone);
    final userType = context.select<AccountModel, UserType>((a) => a.userType);
    final teacherProfiles =
        context.select<AccountModel, List<TeacherProfileModel>>(
      (a) => a.teacherProfileList,
    );

    return AlertDialog(
      title: Text(S.of(context).createEvent),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 350,
          minHeight: 300,
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<EventType>(
                  items: _eventTypes
                      .map(
                        (eventType) => DropdownMenuItem(
                          value: eventType,
                          child: Text(eventType.getName(context)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _eventType = value!;
                    });
                  },
                  value: _eventType,
                ),
                if (userType == UserType.admin)
                  DropdownButtonFormField<String>(
                    items: teacherProfiles
                        .map(
                          (profile) => DropdownMenuItem(
                            value: profile.profileId,
                            child: Text(
                              '${profile.lastName}, ${profile.firstName}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _teacherId = value;
                      });
                    },
                    value: _teacherId,
                    decoration: InputDecoration(
                      hintText: S.of(context).teacherTitle,
                      icon: const Icon(Icons.person),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _teacherId = null;
                          });
                        },
                      ),
                    ),
                  ),
                TextFormField(
                  decoration: InputDecoration(
                    icon: const Icon(Icons.text_fields),
                    labelText: S.of(context).eventSummaryLabel,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _summary = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).eventSummaryValidation;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.text_snippet),
                    labelText: S.of(context).eventDescriptionLabel,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).eventDescriptionValidation;
                    }
                    return null;
                  },
                ),
                _eventType == EventType.private
                    ? TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          icon: const Icon(Icons.add),
                          labelText: S.of(context).eventPointsLabel,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _numPoints = int.parse(value);
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).eventPointsValidation;
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),
                Text(
                  '${S.of(context).timeZoneLabel}: ${timeZone.replaceAll('_', ' ')}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                TextFormField(
                  controller: _startController,
                  readOnly: true,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.access_time),
                    labelText: S.of(context).eventStartLabel,
                  ),
                  onTap: () {
                    _selectStartTime();
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).eventStartValidation;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _endController,
                  readOnly: true,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.access_time),
                    labelText: S.of(context).eventEndLabel,
                  ),
                  onTap: () {
                    _selectEndTime();
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).eventEndValidation;
                    }
                    if (!_start.isBefore(_end)) {
                      return S.of(context).eventValidTimeValidation;
                    }
                    if (_end.difference(_start) >= const Duration(hours: 24)) {
                      return S.of(context).eventTooLongValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _isRecur,
                      onChanged: (value) {
                        setState(() {
                          _isRecur = value!;
                        });
                      },
                    ),
                    Text(S.of(context).recurTitle),
                  ],
                ),
                if (_isRecur)
                  Column(
                    children: [
                      DropdownButtonFormField<Frequency>(
                        items: recurFrequencies
                            .map(
                              (f) => DropdownMenuItem(
                                value: f,
                                child: Text(frequencyToString(context, f)),
                              ),
                            )
                            .toList(),
                        value: _recurFrequency,
                        onChanged: (value) {
                          setState(() {
                            _recurFrequency = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _recurUntil != null,
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  _recurUntil = _end;
                                  _recurUntilController.text =
                                      DateFormat.yMMMMd(_locale)
                                          .format(_recurUntil!);
                                } else {
                                  _recurUntil = null;
                                }
                              });
                            },
                          ),
                          Text(S.of(context).recurEnd),
                        ],
                      ),
                      if (_recurUntil != null)
                        TextFormField(
                          controller: _recurUntilController,
                          readOnly: true,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.calendar_month),
                            labelText: S.of(context).recurUntilLabel,
                          ),
                          onTap: () {
                            _selectRecurUntil();
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ),
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
            ? Transform.scale(
                scale: 0.5,
                child: const CircularProgressIndicator(),
              )
            : TextButton(
                child: Text(S.of(context).confirm),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _submitClicked = true;
                    });
                    final event = EventModel(
                      eventType: _eventType,
                      summary: _summary,
                      description: _description,
                      numPoints:
                          _eventType == EventType.private ? _numPoints : 0,
                      startTime: _start,
                      endTime: _end,
                      recurrence: _isRecur
                          ? buildRecurrence(
                              frequency: _recurFrequency,
                              until: _recurUntil,
                            )
                          : [],
                      timeZone: timeZone,
                      teacherId: _teacherId,
                    );
                    try {
                      final newEvent = await event_service.insertEvent(
                        event,
                        location: _location,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).createEventSuccess),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).createEventFailure),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    } finally {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
      ],
    );
  }
}
