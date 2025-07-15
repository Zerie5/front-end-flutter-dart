/// Authentication models for dual token system
///
/// This file contains all authentication-related data models that handle
/// the new backend dual token system with access tokens, refresh tokens,
/// and session management.
library;

class LoginResponse {
  final String status;
  final String token; // Access token (15 min)
  final String? refreshToken; // Refresh token (30 days) - NEW
  final String? sessionId; // Session identifier - NEW
  final DateTime? expiresAt; // Access token expiry - ENHANCED
  final String? userId;
  final int? userTableId;
  final String? userUniqueId;
  final int? registerStatus;
  final Map<String, dynamic>? profile;
  final String? message;
  final String? code;

  LoginResponse({
    required this.status,
    required this.token,
    this.refreshToken,
    this.sessionId,
    this.expiresAt,
    this.userId,
    this.userTableId,
    this.userUniqueId,
    this.registerStatus,
    this.profile,
    this.message,
    this.code,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? 'error',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'], // NEW field
      sessionId: json['sessionId'], // NEW field
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      userId: json['userId']?.toString(),
      userTableId: json['userTableId'] is int
          ? json['userTableId']
          : int.tryParse(json['userTableId']?.toString() ?? ''),
      userUniqueId: json['userUniqueId']?.toString(),
      registerStatus: json['registerStatus'] is int
          ? json['registerStatus']
          : int.tryParse(json['registerStatus']?.toString() ?? ''),
      profile: json['profile'] != null
          ? Map<String, dynamic>.from(json['profile'])
          : null,
      message: json['message'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'token': token,
      'refreshToken': refreshToken,
      'sessionId': sessionId,
      'expiresAt': expiresAt?.toIso8601String(),
      'userId': userId,
      'userTableId': userTableId,
      'userUniqueId': userUniqueId,
      'registerStatus': registerStatus,
      'profile': profile,
      'message': message,
      'code': code,
    };
  }

  /// Check if this is a successful login response
  bool get isSuccess => status == 'success' && token.isNotEmpty;

  /// Check if this response includes dual token data
  bool get hasDualTokens => refreshToken != null && sessionId != null;

  /// Check if token expiry is provided
  bool get hasExpiry => expiresAt != null;

  @override
  String toString() {
    return 'LoginResponse(status: $status, hasToken: ${token.isNotEmpty}, '
        'hasRefreshToken: ${refreshToken != null}, '
        'hasSessionId: ${sessionId != null}, '
        'expiresAt: $expiresAt)';
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}

class RefreshTokenResponse {
  final String status;
  final String? token; // New access token
  final DateTime? expiresAt; // New access token expiry
  final String? message;
  final String? code;

  RefreshTokenResponse({
    required this.status,
    this.token,
    this.expiresAt,
    this.message,
    this.code,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    // Handle both 'token' and 'accessToken' fields for backend compatibility
    final accessToken = json['accessToken'] ?? json['token'];

    // Calculate expiry from expiresIn (seconds) or use expiresAt
    DateTime? expiresAt;
    if (json['expiresIn'] != null) {
      final expiresInSeconds = json['expiresIn'] as int;
      expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
    } else if (json['expiresAt'] != null) {
      expiresAt = DateTime.parse(json['expiresAt']);
    }

    return RefreshTokenResponse(
      status: json['status'] ?? 'error',
      token: accessToken,
      expiresAt: expiresAt,
      message: json['message'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'token': token,
      'expiresAt': expiresAt?.toIso8601String(),
      'message': message,
      'code': code,
    };
  }

  /// Check if this is a successful refresh response
  bool get isSuccess =>
      status == 'success' && token != null && token!.isNotEmpty;

  @override
  String toString() {
    return 'RefreshTokenResponse(status: $status, hasNewToken: ${token != null}, expiresAt: $expiresAt)';
  }
}

class LogoutAllResponse {
  final String status;
  final String message;
  final String? code;

  LogoutAllResponse({
    required this.status,
    required this.message,
    this.code,
  });

  factory LogoutAllResponse.fromJson(Map<String, dynamic> json) {
    return LogoutAllResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Logout response',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'code': code,
    };
  }

  /// Check if this is a successful logout response
  bool get isSuccess => status == 'success';

  @override
  String toString() {
    return 'LogoutAllResponse(status: $status, message: $message)';
  }
}

/// Authentication state information for internal use
class AuthState {
  final bool hasAccessToken;
  final bool hasRefreshToken;
  final bool hasSessionId;
  final bool hasExpiry;
  final bool needsRefresh;
  final bool isExpired;
  final DateTime? expiresAt;

  AuthState({
    required this.hasAccessToken,
    required this.hasRefreshToken,
    required this.hasSessionId,
    required this.hasExpiry,
    required this.needsRefresh,
    required this.isExpired,
    this.expiresAt,
  });

  factory AuthState.fromMap(Map<String, dynamic> map) {
    return AuthState(
      hasAccessToken: map['hasAccessToken'] ?? false,
      hasRefreshToken: map['hasRefreshToken'] ?? false,
      hasSessionId: map['hasSessionId'] ?? false,
      hasExpiry: map['hasExpiry'] ?? false,
      needsRefresh: map['needsRefresh'] ?? true,
      isExpired: map['isExpired'] ?? true,
      expiresAt:
          map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
    );
  }

  /// Check if user is properly authenticated
  bool get isAuthenticated => hasAccessToken && !isExpired;

  /// Check if system can auto-refresh
  bool get canAutoRefresh => hasRefreshToken && hasAccessToken;

  /// Check if user needs to login again
  bool get needsLogin => !hasRefreshToken || isExpired;

  @override
  String toString() {
    return 'AuthState(authenticated: $isAuthenticated, canRefresh: $canAutoRefresh, needsLogin: $needsLogin)';
  }
}

/// Token refresh status for UI updates
enum TokenRefreshStatus {
  idle,
  refreshing,
  success,
  failed,
  needsLogin,
}

class TokenRefreshState {
  final TokenRefreshStatus status;
  final String? message;
  final DateTime? lastRefresh;

  TokenRefreshState({
    required this.status,
    this.message,
    this.lastRefresh,
  });

  bool get isRefreshing => status == TokenRefreshStatus.refreshing;
  bool get needsLogin => status == TokenRefreshStatus.needsLogin;
  bool get hasFailed => status == TokenRefreshStatus.failed;

  @override
  String toString() {
    return 'TokenRefreshState(status: $status, message: $message)';
  }
}
