import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_opera_api/omdk_opera_api.dart';
import 'package:omdk_opera_repo/omdk_opera_repo.dart';
import 'package:omdk_repo/omdk_repo.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:omdk_sample_app/elements/jfields/image/widget/carousel_view_wrapper.dart';
import 'package:omdk_sample_app/elements/shimmer/widget/shimmer_loading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FieldImage extends StatelessWidget {
  const FieldImage({
    required this.fieldGuid,
    required this.entityType,
    required this.entityGuid,
    required this.focusNode,
    required this.labelText,
    this.bloc,
    this.imageGuidList = const [],
    this.isMultiImages = false,
    this.isRequired = false,
    this.isActionEnabled = false,
    this.fieldNote,
    this.onImageAdded,
    this.onImageRemoved,
    this.onImageReplaced,
  });

  final String entityGuid;
  final String? fieldGuid;
  final FocusNode? focusNode;
  final JEntityType entityType;
  final String labelText;
  final FieldImageCubit? bloc;
  final List<String>? imageGuidList;
  final bool isMultiImages;
  final bool isRequired;
  final bool isActionEnabled;
  final String? fieldNote;
  final void Function(Attachment?)? onImageAdded;
  final void Function(Attachment)? onImageRemoved;
  final void Function(String, String)? onImageReplaced;

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider.value(value: bloc!, child: _child)
        : BlocProvider(
            create: (context) => FieldImageCubit(
              fieldGuid: fieldGuid,
              isActionEnabled: isActionEnabled,
              entityType: entityType,
              entityGuid: entityGuid,
              assetRepo: context.read<EntityRepo<Asset>>(),
              nodeRepo: context.read<EntityRepo<Node>>(),
              scheduledRepo: context.read<EntityRepo<ScheduledActivity>>(),
              toolRepo: context.read<EntityRepo<Tool>>(),
              attachmentRepo: context.read<OperaAttachmentRepo>(),
              omdkLocalData: context.read<OMDKLocalData>(),
              operaUtils: context.read<OperaUtils>(),
            ),
            child: _child,
          );
  }

  Widget get _child => _FieldImage(
        labelText: labelText,
        focusNode: focusNode,
        fieldNote: fieldNote,
        onImageAdded: onImageAdded,
        imageGuidList: imageGuidList,
        onRemoveImage: onImageRemoved,
        onImageReplaced: onImageReplaced,
        isRequired: isRequired,
      );
}

class _FieldImage extends StatefulWidget {
  const _FieldImage({
    required this.labelText,
    required this.focusNode,
    this.fieldNote,
    this.onImageAdded,
    this.imageGuidList,
    this.onRemoveImage,
    this.onImageReplaced,
    this.isRequired = false,
  });

  final String labelText;
  final FocusNode? focusNode;
  final String? fieldNote;
  final void Function(Attachment?)? onImageAdded;
  final List<String>? imageGuidList;
  final void Function(Attachment)? onRemoveImage;
  final void Function(String, String)? onImageReplaced;
  final bool isRequired;

  @override
  State<_FieldImage> createState() => _FieldImageState();
}

class _FieldImageState extends State<_FieldImage> {
  final _smoothController = PageController();
  int imageIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<FieldImageCubit>().loadImages(widget.imageGuidList ?? []);
    _smoothController
        .addListener(() => imageIndex = _smoothController.page!.truncate());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.labelText.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const Space.vertical(5),
        Stack(
          children: [
            Container(
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: (context.read<FieldImageCubit>().state.isActionEnabled
                          ? widget.isRequired
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context)
                                  .inputDecorationTheme
                                  .border
                                  ?.borderSide
                                  .color
                          : widget.isRequired
                              ? Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withAlpha(150)
                              : Theme.of(context)
                                  .inputDecorationTheme
                                  .disabledBorder
                                  ?.borderSide
                                  .color) ??
                      const Color(0xFF000000),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _imageLoader,
            ),
            _smoothPageIndicator,
          ],
        ),
        if (widget.isRequired)
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
        const Space.vertical(5),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [_options]),
        if (widget.fieldNote != null) _notes,
      ],
    );
  }

  Widget get _smoothPageIndicator =>
      BlocBuilder<FieldImageCubit, FieldImageState>(
        builder: (context, state) => (state.fileList.length > 1)
            ? Positioned(
                bottom: 22,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _smoothController,
                    count: state.fileList.length,
                    effect: WormEffect(
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotHeight: 7,
                      dotWidth: 7,
                      spacing: 7,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      );

  Widget get _options => BlocBuilder<FieldImageCubit, FieldImageState>(
        buildWhen: (previous, current) =>
            previous.isActionEnabled != current.isActionEnabled,
        builder: (context, state) => state.isActionEnabled
            ? Opacity(
                opacity: !state.isActionEnabled ? 0.7 : 1,
                child: AbsorbPointer(
                  absorbing: !state.isActionEnabled,
                  child: OMDKElevatedButton(
                    focusNode: widget.focusNode,
                    onPressed: () => _onOptionsPressed(
                      cubit: context.read<FieldImageCubit>(),
                    ),
                    text: context.l.btn_options,
                  ),
                ),
              )
            : const SizedBox(),
      );

  Widget get _imageLoader => BlocBuilder<FieldImageCubit, FieldImageState>(
        builder: (context, state) => Shimmer(
          child: ShimmerLoading(
            isLoading: state.isLoading,
            child: state.fileList.isEmpty
                ? const Center(child: Icon(Icons.no_photography))
                : PageView.builder(
                    itemCount: state.fileList.length,
                    controller: _smoothController,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, itemIndex) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        // onTap: () async => Navigator.of(context).pushNamed(
                        //   fullScreenRoute,
                        //   arguments: <String, dynamic>{
                        //     'attachmentEntity': state.attachmentList[itemIndex],
                        //     'attachmentFile': state.fileList[itemIndex],
                        //     'withEditBtn': false,
                        //   },
                        // ),
                        onTap: () => _onTap(state, itemIndex),
                        child: Hero(
                          tag: state.attachmentList[itemIndex].attachment.guid!,
                          child: Image.file(
                            state.fileList[itemIndex],
                            fit: BoxFit.fitHeight,
                            // cacheHeight: 250,
                            // cacheWidth: 390,
                            errorBuilder: (context, o, s) => Padding(
                              padding: const EdgeInsets.all(4),
                              child: Center(
                                child: Image.asset(
                                  IconAsset.iconFileImageAsset.iconAsset,
                                  height: 250,
                                  width: 390,
                                  fit: BoxFit.contain,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      );

  void _onTap(FieldImageState state, int itemIndex) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => CarouselViewWrapper(
          fileItems: state.fileList,
          attachmentItems: state.attachmentList,
          backgroundDecoration: Theme.of(context).brightness == Brightness.light
              ? const BoxDecoration(color: Colors.white)
              : const BoxDecoration(color: Colors.black),
          initialIndex: itemIndex,
        ),
      ),
    );
  }

  Widget get _notes => Row(
        children: [
          Expanded(
            child: Text(
              '${widget.fieldNote}',
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      );

  void _onOptionsPressed({required FieldImageCubit cubit}) =>
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
                    context.l.o_l_pick_image_group,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  children: [
                    CupertinoListTile.notched(
                      title: Text(
                        context.l.o_l_take_photo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      leading: const Icon(CupertinoIcons.camera),
                      onTap: _addImageFromCamera,
                    ),
                    CupertinoListTile.notched(
                      title: Text(
                        context.l.o_l_pick_media,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      leading: const Icon(CupertinoIcons.photo),
                      onTap: _pickImageFromGallery,
                    ),
                  ],
                ),
                if (cubit.state.attachmentList.isNotEmpty)
                  CupertinoListSection.insetGrouped(
                    header: Text(
                      context.l.o_l_options_image_group,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    children: [
                      CupertinoListTile.notched(
                        title: Text(
                          context.l.o_l_remove_image,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        leading: const Icon(CupertinoIcons.clear_circled),
                        onTap: _onTapRemove,
                      ),
                      // CupertinoListTile.notched(
                      //   title: Text(
                      //     context.l.o_l_edit_image,
                      //     style: Theme.of(context).textTheme.titleMedium,
                      //   ),
                      //   leading: const Icon(CupertinoIcons.pencil),
                      //   onTap: () =>
                      //       _onEditImage(cubit.state.fileList[imageIndex]),
                      // ),
                      CupertinoListTile.notched(
                        title: Text(
                          context.l.o_l_replace_image_with_camera,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        leading: const Icon(CupertinoIcons.arrow_2_squarepath),
                        onTap: _replaceWithCamera,
                      ),
                      CupertinoListTile.notched(
                        title: Text(
                          context.l.o_l_replace_image_with_gallery,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        leading: const Icon(CupertinoIcons.arrow_2_squarepath),
                        onTap: _replaceWithGallery,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );

  // Add image from camera
  Future<void> _addImageFromCamera() async {
    final cubit = context.read<FieldImageCubit>();
    Navigator.pop(context);
    final newAttachment = await cubit.takeCameraPhoto(
      userFullName: context.myFullName,
      withWatermark: false,
    );
    if (newAttachment != null) {
      widget.onImageAdded?.call(newAttachment);
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final cubit = context.read<FieldImageCubit>();
    Navigator.pop(context);
    final newAttachment = await cubit.pickImage(
      userFullName: context.myFullName,
      withWatermark: false,
    );
    if (newAttachment != null) {
      widget.onImageAdded?.call(newAttachment);
    }
  }

  // Replace with image from gallery
  Future<void> _replaceWithGallery() async {
    final cubit = context.read<FieldImageCubit>();
    final guidAttachmentToRemove = cubit.state.attachmentList[imageIndex].guid;
    Navigator.of(context).pop();
    final newAttachment = await cubit.pickImage(
      userFullName: context.myFullName,
      withWatermark: false,
      replaceFile: true,
      attachmentToRemove: cubit.state.attachmentList[imageIndex],
      fileToRemove: cubit.state.fileList[imageIndex],
    );
    if (newAttachment != null) {
      widget.onImageReplaced?.call(
        guidAttachmentToRemove!,
        newAttachment.guid!,
      );
    }
  }

  // Replace with image from camera
  Future<void> _replaceWithCamera() async {
    final cubit = context.read<FieldImageCubit>();
    final guidAttachmentToRemove = cubit.state.attachmentList[imageIndex].guid;
    Navigator.of(context).pop();
    final newAttachment = await cubit.takeCameraPhoto(
      userFullName: context.myFullName,
      withWatermark: false,
      replaceFile: true,
      attachmentToRemove: cubit.state.attachmentList[imageIndex],
      fileToRemove: cubit.state.fileList[imageIndex],
    );
    if (newAttachment != null) {
      widget.onImageReplaced
          ?.call(guidAttachmentToRemove!, newAttachment.guid!);
    }
  }

  // Remove image function on bs menu
  void _onTapRemove() {
    final cubit = context.read<FieldImageCubit>();
    widget.onRemoveImage?.call(
      cubit.state.attachmentList[
          cubit.state.attachmentList.length == 1 ? 0 : imageIndex],
    );
    cubit.removeImage(
      cubit.state.attachmentList[
          cubit.state.attachmentList.length == 1 ? 0 : imageIndex],
      cubit.state
          .fileList[cubit.state.attachmentList.length == 1 ? 0 : imageIndex],
    );
    Navigator.of(context).pop();
  }
}
