enum CallAction { start, end, decline, missed }

enum CallType { audio, video }

class CallSignalPayload {
  final String type = 'CALL_SIGNAL';
  final String callId;
  final String callerId;
  final String callerName;
  final String calleeId;
  final CallType callType;
  final CallAction action;

  CallSignalPayload({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.calleeId,
    required this.callType,
    required this.action,
  });

  factory CallSignalPayload.fromMap(Map<String, dynamic> data) {
    return CallSignalPayload(
      callId: data['callId'] ?? '',
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? '',
      calleeId: data['calleeId'] ?? '',
      callType: _parseCallType(data['callType']),
      action: _parseCallAction(data['action']),
    );
  }

  static CallType _parseCallType(String? value) {
    switch (value) {
      case 'VIDEO':
        return CallType.video;
      default:
        return CallType.audio;
    }
  }

  static CallAction _parseCallAction(String? value) {
    switch (value) {
      case 'START':
        return CallAction.start;
      case 'END':
        return CallAction.end;
      case 'DECLINE':
        return CallAction.decline;
      case 'MISSED':
        return CallAction.missed;
      default:
        return CallAction.start;
    }
  }
}
