import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)
class SessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String habitCategory;

  @HiveField(2)
  int plannedDurationMinutes;

  @HiveField(3)
  int actualDurationSeconds;

  @HiveField(4)
  DateTime startTimestamp;

  @HiveField(5)
  DateTime? endTimestamp;

  @HiveField(6)
  String status; // 'active', 'completed', 'broken'

  @HiveField(7)
  double penaltyAmount;

  @HiveField(8)
  String restrictionLevel; // 'normal', 'strict', 'extreme'

  @HiveField(9)
  List<String> blockedCategories;

  SessionModel({
    required this.id,
    required this.habitCategory,
    required this.plannedDurationMinutes,
    this.actualDurationSeconds = 0,
    required this.startTimestamp,
    this.endTimestamp,
    this.status = 'active',
    this.penaltyAmount = 0,
    this.restrictionLevel = 'normal',
    this.blockedCategories = const [],
  });
}
