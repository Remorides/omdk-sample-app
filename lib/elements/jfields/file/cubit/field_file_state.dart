part of 'field_file_cubit.dart';

@immutable
final class FieldFileState {
  const FieldFileState({
    this.isLoading = true,
    this.attachmentList = const [],
    this.selectedAttachment,
    this.fileList = const [],
    this.error,
    this.isEnabled = true,
  });

  final bool isLoading;
  final List<Attachment> attachmentList;
  final Attachment? selectedAttachment;
  final List<File> fileList;
  final FieldFileError? error;
  final bool isEnabled;

  FieldFileState copyWith({
    bool? isLoading,
    List<Attachment>? attachmentList,
    Attachment? selectedAttachment,
    List<File>? fileList,
    FieldFileError? error,
    bool? isEnabled,
  }) {
    return FieldFileState(
      isLoading: isLoading ?? this.isLoading,
      attachmentList: attachmentList ?? this.attachmentList,
      selectedAttachment: selectedAttachment ?? this.selectedAttachment,
      fileList: fileList ?? this.fileList,
      error: error ?? this.error,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
