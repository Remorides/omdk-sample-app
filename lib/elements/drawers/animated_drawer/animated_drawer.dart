import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omdk_sample_app/blocs/auth/auth.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/elements.dart';

class OMDKAnimatedDrawer extends StatelessWidget {
  /// Create [OMDKAnimatedDrawer] instance
  const OMDKAnimatedDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Align(child: _UserDetails()),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                _menuVoice(
                  context: context,
                  title: context.l.d_t_settings,
                  onTap: () => Navigator.of(context).pushNamed(settingsRoute),
                ),
                _divider,
                _menuVoice(
                  context: context,
                  title: context.l.d_t_privacy_policy,
                ),
                _divider,
                _menuVoice(
                  context: context,
                  title: context.l.d_t_opera_guide,
                ),
                _divider,
                _menuVoice(
                  context: context,
                  title: context.l.d_t_languages,
                  onTap: () => Navigator.of(context).pushNamed(languagesRoute),
                ),
                _divider,
                _menuVoice(
                  context: context,
                  title: context.l.d_t_logout,
                  onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get _divider => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: OMDKDivider(thickness: 1),
      );

  Widget _menuVoice({
    required BuildContext context,
    required String title,
    VoidCallback? onTap,
    IconAsset? iconAsset,
  }) =>
      ListTile(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
        leading: iconAsset != null
            ? Image.asset(
                iconAsset.iconAsset,
                height: 24,
                color: Colors.grey,
              )
            : null,
      );
}

class _UserDetails extends StatelessWidget {
  const _UserDetails();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _getUserAvatar(context),
              const Space.horizontal(14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getUserFullName(context),
                    _getUsername(context),
                    _getUserRole(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getUserFullName(BuildContext context) => Text(
        context.myFullName ?? context.l.l_w_failure_not_found,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      );

  Widget _getUsername(BuildContext context) => Text(
        context.read<AuthBloc>().state.user.username.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      );

  Widget _getUserRole(BuildContext context) => Text(
        context.read<AuthBloc>().state.user.userProfile ??
            context.l.o_l_user_role.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
      );

  Widget _getUserAvatar(BuildContext context) {
    final myPhoto = context.myPhoto;
    return CircleAvatar(
      backgroundImage: myPhoto != null
          ? MemoryImage(myPhoto)
          : AssetImage(IconAsset.userAsset.iconAsset),
      foregroundColor: Colors.grey,
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      minRadius: MediaQuery.of(context).size.width / 14,
    );
  }
}
