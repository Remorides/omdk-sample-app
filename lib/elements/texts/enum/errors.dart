import 'package:flutter/cupertino.dart';
import 'package:omdk_sample_app/common/common.dart';

extension FieldTextErrorHelper on FieldTextError? {
  String localizateError(BuildContext context) => switch (this) {
        FieldTextError.mandatory => context.l.l_w_mandatory_field,
        FieldTextError.notEmpty => context.l.l_w_not_empty_field,
        FieldTextError.notNullable => context.l.l_w_not_nullable_field,
        null => '',
      };
}

enum FieldTextError {
  mandatory,
  notEmpty,
  notNullable,
}
