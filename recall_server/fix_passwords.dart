import 'dart:io';

void main() {
  final file = File('config/passwords.yaml');
  final content = '''
development:
  database: 'sOxlqQs6OuZOMbgxOWnAOXQkSUzoWuCE'
  redis: '6kKdeBqJxkRK64lqI50Zqwd2bABpR3Mg'
  serviceSecret: 'Dk_7b@3!8s#9Lm&qR5*tV1^wX4+z'
  jwtRefreshTokenHashPepper: 'Dk_7b@3!8s#9Lm&qR5*tV1^wX4+z'
  emailSecretHashPepper: 'Dk_7b@3!8s#9Lm&qR5*tV1^wX4+z'
  sessionKeyHashPepper: 'ThisIsARandomSessionKeyPepper123!'
''';

  file.writeAsStringSync(content);
  print('passwords.yaml rewritten successfully.');
}
