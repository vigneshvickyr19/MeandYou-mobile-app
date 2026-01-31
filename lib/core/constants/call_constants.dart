enum CallAction {
  START,
  END,
  DECLINE,
  MISSED,
}

enum CallType {
  AUDIO,
  VIDEO,
}

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
        return CallType.VIDEO;
      default:
        return CallType.AUDIO;
    }
  }

  static CallAction _parseCallAction(String? value) {
    switch (value) {
      case 'START':
        return CallAction.START;
      case 'END':
        return CallAction.END;
      case 'DECLINE':
        return CallAction.DECLINE;
      case 'MISSED':
        return CallAction.MISSED;
      default:
        return CallAction.START;
    }
  }
}
