import 'package:intl/intl.dart';

class ModelBirthdate {
  final String? id;
  final String? userId;
  final String? poId;
  final String? fullName;
  final DateTime birthdate;
  final int? personalityNumber;
  final int? lifePathNumber;
  final int? pinnacle1;
  final int? pinnacle2;
  final int? pinnacle3;
  final int? pinnacle4;
  final int? pinnacleBase;
  final List<dynamic>? loShuGrid;
  final List<int>? absentNumbers;
  final Map<String, dynamic>? numberOccurrences;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ModelBirthdate({
    this.id,
    this.userId,
    this.poId,
    this.fullName,
    required this.birthdate,
    this.personalityNumber,
    this.lifePathNumber,
    this.pinnacle1,
    this.pinnacle2,
    this.pinnacle3,
    this.pinnacle4,
    this.pinnacleBase,
    this.loShuGrid,
    this.absentNumbers,
    this.numberOccurrences,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory ModelBirthdate.fromMap(Map<String, dynamic> map) {
    return ModelBirthdate(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      poId: map['po_id'] as String?,
      fullName: map['full_name'] as String?,
      birthdate: DateTime.parse(map['birthdate'].toString()),
      personalityNumber: map['personality_number'] as int?,
      lifePathNumber: map['life_path_number'] as int?,
      pinnacle1: map['pinnacle1'] as int?,
      pinnacle2: map['pinnacle2'] as int?,
      pinnacle3: map['pinnacle3'] as int?,
      pinnacle4: map['pinnacle4'] as int?,
      pinnacleBase: map['pinnacle_base'] as int?,
      loShuGrid: map['lo_shu_grid'] as List<dynamic>?,
      absentNumbers: (map['absent_numbers'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      numberOccurrences: map['number_occurrences'] as Map<String, dynamic>?,
      status: map['status'] as String? ?? 'pending',
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'].toString())
              : null,
      updatedAt:
          map['updated_at'] != null
              ? DateTime.parse(map['updated_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (poId != null) 'po_id': poId,
      if (fullName != null) 'full_name': fullName,
      'birthdate': DateFormat('yyyy-MM-dd').format(birthdate),
      if (personalityNumber != null) 'personality_number': personalityNumber,
      if (lifePathNumber != null) 'life_path_number': lifePathNumber,
      if (pinnacle1 != null) 'pinnacle1': pinnacle1,
      if (pinnacle2 != null) 'pinnacle2': pinnacle2,
      if (pinnacle3 != null) 'pinnacle3': pinnacle3,
      if (pinnacle4 != null) 'pinnacle4': pinnacle4,
      if (pinnacleBase != null) 'pinnacle_base': pinnacleBase,
      if (loShuGrid != null) 'lo_shu_grid': loShuGrid,
      if (absentNumbers != null) 'absent_numbers': absentNumbers,
      if (numberOccurrences != null) 'number_occurrences': numberOccurrences,
      'status': status,
    };
  }

  ModelBirthdate copyWith({
    String? id,
    String? userId,
    String? poId,
    String? fullName,
    DateTime? birthdate,
    int? personalityNumber,
    int? lifePathNumber,
    int? pinnacle1,
    int? pinnacle2,
    int? pinnacle3,
    int? pinnacle4,
    int? pinnacleBase,
    List<dynamic>? loShuGrid,
    List<int>? absentNumbers,
    Map<String, dynamic>? numberOccurrences,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModelBirthdate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      poId: poId ?? this.poId,
      fullName: fullName ?? this.fullName,
      birthdate: birthdate ?? this.birthdate,
      personalityNumber: personalityNumber ?? this.personalityNumber,
      lifePathNumber: lifePathNumber ?? this.lifePathNumber,
      pinnacle1: pinnacle1 ?? this.pinnacle1,
      pinnacle2: pinnacle2 ?? this.pinnacle2,
      pinnacle3: pinnacle3 ?? this.pinnacle3,
      pinnacle4: pinnacle4 ?? this.pinnacle4,
      pinnacleBase: pinnacleBase ?? this.pinnacleBase,
      loShuGrid: loShuGrid ?? this.loShuGrid,
      absentNumbers: absentNumbers ?? this.absentNumbers,
      numberOccurrences: numberOccurrences ?? this.numberOccurrences,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
