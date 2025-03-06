import 'package:flutter/cupertino.dart';
import 'package:omdk_sample_app/common/common.dart';

extension FieldFileErrorHelper on FieldFileError? {
  String localizateError(BuildContext context) => switch(this){
    FieldFileError.retrievingFile => context.l.e_e_retrieving_file,
    null => '',
  };
}

enum FieldFileError {
  retrievingFile,
}
