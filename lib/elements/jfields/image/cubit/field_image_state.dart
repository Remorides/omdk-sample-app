part of 'field_image_cubit.dart';

final class FieldImageState {
  const FieldImageState({
    this.isActionEnabled = true,
    this.isLoading = true,
    this.fileList = const [],
    this.attachmentList = const [],
    this.errorText,
  });

  final bool isLoading;
  final List<File> fileList;
  final List<Attachment> attachmentList;
  final bool isActionEnabled;
  final String? errorText;

  FieldImageState copyWith({
    bool? isLoading,
    List<File>? fileList,
    List<Attachment>? attachmentList,
    bool? isActionEnabled,
    String? errorText,
  }) {
    return FieldImageState(
      isLoading: isLoading ?? this.isLoading,
      fileList: fileList ?? this.fileList,
      attachmentList: attachmentList ?? this.attachmentList,
      isActionEnabled: isActionEnabled ?? this.isActionEnabled,
      errorText: errorText ?? this.errorText,
    );
  }
}
