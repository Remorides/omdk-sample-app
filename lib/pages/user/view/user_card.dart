part of 'user_view.dart';

/// Widget to show user details
class _UserProfileCard extends StatelessWidget {
  /// Constructor
  const _UserProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.status == LoadingStatus.inProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadingStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final guid = context.read<UserCubit>().state.item?.guid;
                    if (guid != null) {
                      context.read<UserCubit>().loadItem(guid);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final user = state.item;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: user.entity.thumbnail != null
                      ? MemoryImage(base64Decode(user.entity.thumbnail!))
                      : null,
                  child: user.entity.thumbnail == null
                      ? Text(
                    (user.user?.firstName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 30),
                  )
                      : null,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      context.read<UserCubit>().changePhoto();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _buildInfoRow(
                'First name',
                user.user?.firstName ??  'N/A'
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Last name',
                user.user?.lastName ??  'N/A'
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Role',
                user.user?.userProfile.name ?? 'N/A'
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}