import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_local_data/omdk_local_data.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:omdk_sample_app/elements/shimmer/widget/shimmer_loading.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_repo/omdk_repo.dart';

class FieldFile extends StatelessWidget {
  const FieldFile({
    required this.entityType,
    required this.entityGuid,
    required this.attachmentsGuid,
    required this.labelText,
    this.selectedAttachment,
    this.bloc,
    this.onOptions,
    this.isMultiFile = false,
    this.isEnabled = true,
    this.isRequired = false,
    this.isOptionsEnabled = true,
    this.fieldNote,
    this.hintText,
    this.focusNode,
    this.onSelected,
    this.onFileAdded,
    this.onFileRemoved,
    this.onFileReplaced,
  });

  final String entityGuid;
  final List<String>? attachmentsGuid;
  final String? selectedAttachment;
  final JEntityType entityType;
  final String labelText;
  final FieldFileCubit? bloc;
  final VoidCallback? onOptions;
  final bool isMultiFile;
  final bool isEnabled;
  final bool isRequired;
  final bool isOptionsEnabled;
  final String? hintText;
  final String? fieldNote;
  final FocusNode? focusNode;
  final void Function(Attachment?)? onSelected;
  final void Function(Attachment?)? onFileAdded;
  final void Function(Attachment)? onFileRemoved;
  final void Function(String, String)? onFileReplaced;

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider.value(value: bloc!, child: _child)
        : BlocProvider(
            create: (_) => FieldFileCubit(
              entityType: entityType,
              entityGuid: entityGuid,
              isEnabled: isEnabled,
              assetRepo: context.read<EntityRepo<Asset>>(),
              nodeRepo: context.read<EntityRepo<Node>>(),
              toolRepo: context.read<EntityRepo<Tool>>(),
              scheduledRepo: context.read<EntityRepo<ScheduledActivity>>(),
              attachmentRepo: context.read<OperaAttachmentRepo>(),
              omdkLocalData: context.read<OMDKLocalData>(),
              operaUtils: context.read<OperaUtils>(),
            )..loadFiles(attachmentsGuid, selectedAttachment),
            child: _child,
          );
  }

  Widget get _child => _FieldFile(
        labelText: labelText,
        onOptions: onOptions,
        isMultiFile: isMultiFile,
        isRequired: isRequired,
        isOptionsEnabled: isOptionsEnabled,
        fieldNote: fieldNote,
        hintText: hintText,
        focusNode: focusNode,
        onSelected: onSelected,
        onFileAdded: onFileAdded,
        onFileRemoved: onFileRemoved,
        onFileReplaced: onFileReplaced,
      );
}

class _FieldFile extends StatelessWidget {
  const _FieldFile({
    required this.labelText,
    required this.isMultiFile,
    required this.isOptionsEnabled,
    required this.isRequired,
    this.onOptions,
    this.fieldNote,
    this.hintText,
    this.focusNode,
    this.onSelected,
    this.onFileAdded,
    this.onFileRemoved,
    this.onFileReplaced,
  });

  final String labelText;
  final VoidCallback? onOptions;
  final bool isMultiFile;
  final bool isOptionsEnabled;
  final bool isRequired;
  final String? fieldNote;
  final String? hintText;
  final FocusNode? focusNode;
  final void Function(Attachment?)? onSelected;
  final void Function(Attachment?)? onFileAdded;
  final void Function(Attachment)? onFileRemoved;
  final void Function(String, String)? onFileReplaced;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                labelText.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const Space.vertical(5),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _fileLoader,
            const SizedBox(height: 5),
            _multiFileOptions,
          ],
        ),
        if (isRequired)
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l.a_mandatory,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        if (fieldNote != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  '$fieldNote',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget get _multiFileOptions => BlocBuilder<FieldFileCubit, FieldFileState>(
        builder: (context, state) => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isMultiFile || state.attachmentList.isEmpty)
              OMDKElevatedButton(
                enabled: state.isEnabled,
                onPressed: () => _onOptionsPressed(
                  context: context,
                  cubit: context.read<FieldFileCubit>(),
                ),
                text: context.l.btn_options,
              ),
          ],
        ),
      );

  Widget get _fileLoader => BlocBuilder<FieldFileCubit, FieldFileState>(
        builder: (context, state) => Shimmer(
          child: ShimmerLoading(
            isLoading: state.isLoading,
            child: Opacity(
              opacity: !state.isEnabled ? 0.5 : 1,
              child: AbsorbPointer(
                absorbing: !state.isEnabled,
                child: DropdownButtonFormField(
                  icon: const Icon(CupertinoIcons.doc),
                  decoration: InputDecoration(
                    hintText: hintText,
                    filled: true,
                    enabled: state.isEnabled,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border:
                        Theme.of(context).inputDecorationTheme.border?.copyWith(
                              borderSide: Theme.of(context)
                                  .inputDecorationTheme
                                  .border
                                  ?.borderSide
                                  .copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                  ),
                  items: state.attachmentList
                      .map(
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(i.attachment.fileName ?? ''),
                        ),
                      )
                      .toList(),
                  value: state.attachmentList.isEmpty
                      ? null
                      : state.selectedAttachment,
                  isExpanded: true,
                  onChanged: (a) {
                    context.read<FieldFileCubit>().changeSelected(a);
                    onSelected?.call(a);
                  },
                ),
              ),
            ),
          ),
        ),
      );

  void _onOptionsPressed({
    required BuildContext context,
    required FieldFileCubit cubit,
  }) =>
      OMDKSimpleBottomSheet.show(
        context,
        (bottomSheetContext) => OMDKSimpleBottomSheet(
          color: CupertinoColors.systemGroupedBackground,
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoListSection.insetGrouped(
                  header: Text(
                    context.l.o_l_pick_file_group,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  children: [
                    CupertinoListTile.notched(
                      title: Text(
                        context.l.o_l_pick_file,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      leading: const Icon(CupertinoIcons.camera),
                      onTap: () async {
                        final newAttachment = await cubit.addFile();
                        onFileAdded?.call(newAttachment);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                if (cubit.state.selectedAttachment != null)
                  CupertinoListSection.insetGrouped(
                    header: Text(
                      context.l.o_l_options_file_group,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    children: [
                      CupertinoListTile.notched(
                        title: Text(
                          context.l.o_l_remove_file(
                            cubit
                                .state.selectedAttachment!.attachment.fileName!,
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        leading: const Icon(CupertinoIcons.clear_circled),
                        onTap: () {
                          onFileRemoved?.call(cubit.state.selectedAttachment!);
                          cubit.removeFile(
                            cubit.state.selectedAttachment!,
                            cubit.state.fileList[cubit.state.attachmentList
                                .indexOf(cubit.state.selectedAttachment!)],
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoListTile.notched(
                        title: Text(
                          context.l.o_l_replace_file(
                            cubit
                                .state.selectedAttachment!.attachment.fileName!,
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        leading: const Icon(CupertinoIcons.arrow_2_squarepath),
                        onTap: () async {
                          final guidAttachmentToRemove =
                              cubit.state.selectedAttachment!.guid;
                          Navigator.of(context).pop();
                          final newAttachment = await cubit.addFile(
                            replaceFile: true,
                            attachmentToRemove: cubit.state.selectedAttachment,
                            fileToRemove: cubit.state.fileList[cubit
                                .state.attachmentList
                                .indexOf(cubit.state.selectedAttachment!)],
                          );
                          if (newAttachment != null) {
                            onFileReplaced?.call(
                              guidAttachmentToRemove!,
                              newAttachment.guid!,
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
}
