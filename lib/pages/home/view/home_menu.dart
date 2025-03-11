part of 'home_page.dart';

class _HomeMenu extends StatelessWidget {
  const _HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return OMDKSimplePage(
      appBarTitle: const Text('Users'),
      withBottomBar: false,
      bodyPage: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          //manage the state of the page
          switch (state.status) {
            case LoadingStatus.initial:
            case LoadingStatus.inProgress:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case LoadingStatus.updated:
            case LoadingStatus.done:
              return _buildUsersList(context, state);

            case LoadingStatus.failure:
            case LoadingStatus.fatal:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<HomeCubit>().loadItems(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, HomeState state) {
    // If items is empty show a messagge
    if (state.items.isEmpty) {
      return const Center(
        child: Text('Nessun utente disponibile'),
      );
    }

    //Otherwise show a list of user
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final element = state.items[index];

        final String firstName = element.user?.firstName ?? '';
        final String lastName = element.user?.lastName ?? '';
        final String fullName =
            [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
        final String username = element.user?.username != null
            ? 'Username: ${element.user?.username}'
            : "";

        // Crated a card for each user
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                (element.user?.firstName ?? 'N')[0].toUpperCase(),
              ),
            ),
            title: Text(fullName.isNotEmpty ? fullName : "User"),
            subtitle: Text(username),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              UserDialogHelper().showUserProfileDialog(
                  context: context,
                  guid: element.guid!,
                  operaUserRepo: context.read<OperaUserRepo>());
            },
          ),
        );
      },
    );
  }
}
