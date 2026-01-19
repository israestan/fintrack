import 'package:uuid/uuid.dart';

final Uuid _uuid = Uuid();

String generateUuidV4() => _uuid.v4();
