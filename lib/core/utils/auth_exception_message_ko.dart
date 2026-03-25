import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps [AuthException] from Supabase/GoTrue to Korean for UI display.
String authExceptionMessageKo(
  AuthException e, {
  String genericFallback = '요청을 처리할 수 없습니다. 잠시 후 다시 시도해주세요.',
}) {
  if (e is AuthWeakPasswordException) {
    if (e.reasons.isEmpty) {
      return '비밀번호 요구사항을 충족하지 않습니다.';
    }
    return e.reasons.map(_weakPasswordReasonKo).join('\n');
  }

  final code = e.code;
  if (code != null) {
    final byCode = _messageForErrorCode(code);
    if (byCode != null) return byCode;
  }

  final raw = e.message.trim();
  if (_containsHangul(raw)) {
    return raw;
  }

  final lower = raw.toLowerCase();
  final byPhrase = _messageForEnglishPhrase(lower);
  if (byPhrase != null) return byPhrase;

  return genericFallback;
}

bool _containsHangul(String s) => RegExp(r'[가-힣]').hasMatch(s);

String? _messageForErrorCode(String code) {
  switch (code) {
    case 'invalid_login_credentials':
    case 'invalid_credentials':
    case 'invalid_grant':
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    case 'email_not_confirmed':
    case 'provider_email_needs_verification':
      return '이메일 인증이 완료되지 않았습니다. 받은 편지함을 확인해주세요.';
    case 'user_banned':
      return '이용이 제한된 계정입니다.';
    case 'email_exists':
    case 'user_already_exists':
    case 'phone_exists':
      return '이미 가입된 정보입니다.';
    case 'signup_disabled':
      return '현재 회원가입이 허용되지 않습니다.';
    case 'over_request_rate_limit':
    case 'over_email_send_rate_limit':
    case 'over_sms_send_rate_limit':
      return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
    case 'validation_failed':
      return '입력 정보를 확인해주세요.';
    case 'weak_password':
      return '비밀번호 요구사항을 충족하지 않습니다.';
    case 'user_not_found':
      return '해당 계정을 찾을 수 없습니다.';
    case 'session_not_found':
    case 'session_expired':
      return '로그인 세션이 만료되었습니다. 다시 로그인해주세요.';
    case 'same_password':
      return '이전과 다른 비밀번호를 입력해주세요.';
    case 'email_provider_disabled':
      return '이메일 로그인이 비활성화되어 있습니다.';
    case 'captcha_failed':
      return '보안 확인에 실패했습니다. 다시 시도해주세요.';
    default:
      return null;
  }
}

String? _messageForEnglishPhrase(String lower) {
  if (lower.contains('invalid login credentials')) {
    return '이메일 또는 비밀번호가 올바르지 않습니다.';
  }
  if (lower.contains('email not confirmed')) {
    return '이메일 인증이 완료되지 않았습니다. 받은 편지함을 확인해주세요.';
  }
  if (lower.contains('user is banned') || lower.contains('user banned')) {
    return '이용이 제한된 계정입니다.';
  }
  if (lower.contains('already registered') ||
      lower.contains('already been registered') ||
      lower.contains('user already exists')) {
    return '이미 가입된 정보입니다.';
  }
  if (lower.contains('signups not allowed')) {
    return '현재 회원가입이 허용되지 않습니다.';
  }
  if (lower.contains('rate limit') || lower.contains('too many requests')) {
    return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
  }
  if (lower.contains('password')) {
    if (lower.contains('at least') || lower.contains('least')) {
      return '비밀번호 요구사항을 충족하지 않습니다.';
    }
  }
  return null;
}

String _weakPasswordReasonKo(String reason) {
  switch (reason) {
    case 'characters':
    case 'too_short':
      return '비밀번호가 너무 짧습니다.';
    case 'no_uppercase':
      return '대문자를 포함해야 합니다.';
    case 'no_lowercase':
      return '소문자를 포함해야 합니다.';
    case 'no_numbers':
      return '숫자를 포함해야 합니다.';
    case 'no_special_chars':
      return '특수문자를 포함해야 합니다.';
    default:
      return '비밀번호 요구사항을 충족하지 않습니다.';
  }
}
