import 'package:flutter/material.dart';
import 'package:success_academy/calendar/data/event_model.dart';
import 'package:success_academy/calendar/services/event_service.dart'
    as event_service;
import 'package:success_academy/data/data_source.dart';
import 'package:success_academy/helpers/tz_date_time_range.dart';

final class EventsDataSource extends ChangeNotifier
    implements DataSource<Set<EventModel>, TZDateTimeRange> {
  EventsDataSource._(bool singleEvents) : _singleEvents = singleEvents;

  factory EventsDataSource({required bool singleEvents}) {
    if (singleEvents) {
      return _singleEventsInstance;
    } else {
      return _recurrenceInstance;
    }
  }

  static final EventsDataSource _singleEventsInstance =
      EventsDataSource._(true);
  static final EventsDataSource _recurrenceInstance = EventsDataSource._(false);

  final bool _singleEvents;
  final Set<EventModel> _eventsCache = {};
  final List<TZDateTimeRange> _cachedDateTimeRanges = [];

  /// Loads all currently cached events.
  @override
  Future<Set<EventModel>> loadData() async {
    return _eventsCache;
  }

  /// Loads event data that falls within [dateTimeRange].
  ///
  /// Includes events with any overlap with [dateTimeRange] i.e. an end
  /// timestamp greater than `dateTimeRange.start` and a start timestamp less
  /// than `dateTimeRange.end`.
  @override
  Future<Set<EventModel>> loadDataByKey(TZDateTimeRange dateTimeRange) async {
    await fetchAndStoreDataByKey(dateTimeRange);
    return Future.value(
      _eventsCache
          .where(
            (event) =>
                event.endTime.isAfter(dateTimeRange.start) &&
                event.startTime.isBefore(dateTimeRange.end),
          )
          .toSet(),
    );
  }

  /// Refetches and stores events according to [_cachedDateTimeRanges].
  @override
  Future<void> fetchAndStoreData() async {
    _eventsCache.clear();
    for (final dateTimeRange in _cachedDateTimeRanges) {
      _eventsCache.addAll(
        await event_service.listEvents(
          location: dateTimeRange.start.location,
          dateTimeRange: dateTimeRange,
          singleEvents: _singleEvents,
        ),
      );
    }
    return;
  }

  /// Fetches and stores event data by [dateTimeRange].
  @override
  Future<void> fetchAndStoreDataByKey(TZDateTimeRange dateTimeRange) async {
    _eventsCache.addAll(
      await event_service.listEvents(
        location: dateTimeRange.start.location,
        dateTimeRange: dateTimeRange,
        singleEvents: _singleEvents,
      ),
    );
    _cachedDateTimeRanges.add(dateTimeRange);
    mergeTZDateTimeRanges(_cachedDateTimeRanges);
    return;
  }
}
