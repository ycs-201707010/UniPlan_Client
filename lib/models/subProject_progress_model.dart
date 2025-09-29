class SubProjectProgress {
  final int? progressId;
  final List<DateTime>? dates;

  SubProjectProgress({this.progressId, this.dates});

  SubProjectProgress copyWith({int? progressId, List<DateTime>? dates}) {
    return SubProjectProgress(
      progressId: progressId ?? this.progressId,
      dates: dates ?? this.dates,
    );
  }

  Map<String, dynamic> toJson() {
    // 최종 JSON Map 구성
    final Map<String, dynamic> jsonMap = {
      // 값이 null이 아닐 경우에만 JSON에 포함
      if (progressId != null) 'progress_id': progressId,
      if (dates != null) 'dates': dates,
    };
    return jsonMap;
  }

  factory SubProjectProgress.fromJson(Map<String, dynamic> json) {
    return SubProjectProgress(
      progressId: json['progress_id'] as int?,
      dates:
          (json['dates'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList(),
    );
  }
}
