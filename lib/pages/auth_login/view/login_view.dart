part of 'login_page.dart';

/// Login form class provide all required field to login
class _LoginView extends StatefulWidget {
  /// Build [_LoginView] instance
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  late FocusNode _usernameFN;
  late FocusNode _passwordFN;
  late FocusNode _companyCode;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _usernameFN = FocusNode();
    _passwordFN = FocusNode();
    _companyCode = FocusNode();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameFN.dispose();
    _passwordFN.dispose();
    _companyCode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoadingStatus.failure) {
          OMDKAlert.show(
            context,
            OMDKAlert(
              title: context.l.a_t_warning,
              message: Text(state.errorText),
              confirm: context.l.btn_ok,
              onConfirm: () => (),
              type: AlertType.error,
            ),
          );
        }
      },
      child: OMDKSimplePage(
        key: const Key('authPage'),
        appBarTitle: Text(context.l.p_t_authentication),
        withBottomBar: false,
        withDrawer: false,
        withBackgroundImage: true,
        withKeyboardShortcuts: true,
        focusNodeList: [_companyCode, _usernameFN, _passwordFN],
        isForm: true,
        formKey: _formKey,
        bodyPage: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  _buildSpacer(30),
                  _CompanyInput(
                      widgetFN: _companyCode, nextWidgetFN: _usernameFN),
                  _UsernameInput(
                      widgetFN: _usernameFN, nextWidgetFN: _passwordFN),
                  _PasswordInput(widgetFN: _passwordFN),
                  _buildSpacer(40),
                  _LoginButton(formKey: _formKey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpacer(double size) => Space.vertical(size);
}

class _CompanyInput extends StatelessWidget {
  /// Create [_CompanyInput] instance
  const _CompanyInput({required this.widgetFN, this.nextWidgetFN});

  final FocusNode widgetFN;
  final FocusNode? nextWidgetFN;

  @override
  Widget build(BuildContext context) {
    return FieldString(
      key: const Key('authPage_companyCode_textField'),
      labelText: context.l.o_l_company_code,
      onSubmit: (code) => context.read<LoginCubit>().companyCodeChanged(code),
      onChanged: (code) => context.read<LoginCubit>().companyCodeChanged(code),
      focusNode: widgetFN,
      nextFocusNode: nextWidgetFN,
      validator: (value) {
        if (value == null) {
          return context.l.l_w_mandatory_field;
        } else if (value.isEmpty) {
          return context.l.l_w_not_empty_field;
        }
        return null;
      },
    );
  }
}

class _UsernameInput extends StatelessWidget {
  /// Create [_UsernameInput] instance
  const _UsernameInput({required this.widgetFN, this.nextWidgetFN});

  final FocusNode widgetFN;
  final FocusNode? nextWidgetFN;

  @override
  Widget build(BuildContext context) {
    return FieldString(
      key: const Key('authPage_usernameInput_textField'),
      onSubmit: (username) =>
          context.read<LoginCubit>().usernameChanged(username),
      onChanged: (username) =>
          context.read<LoginCubit>().usernameChanged(username),
      labelText: context.l.o_l_username,
      focusNode: widgetFN,
      nextFocusNode: nextWidgetFN,
      validator: (value) {
        if (value == null) {
          return context.l.l_w_mandatory_field;
        } else if (value.isEmpty) {
          return context.l.l_w_not_empty_field;
        }
        return null;
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  /// Create [_PasswordInput] instance
  _PasswordInput({required this.widgetFN});

  final FocusNode widgetFN;

  final cubit = SimpleTextCubit();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == LoadingStatus.failure,
      listener: (context, state) {
        // Reset password here
        cubit.resetText();
      },
      child: FieldString(
        key: const Key('authPage_passwordInput_textField'),
        cubit: cubit,
        onChanged: (password) =>
            context.read<LoginCubit>().passwordChanged(password),
        onSubmit: (password) =>
            context.read<LoginCubit>().passwordChanged(password),
        labelText: context.l.o_l_password,
        focusNode: widgetFN,
        isObscurable: true,
        validator: (value) {
          if (value == null) {
            return context.l.l_w_mandatory_field;
          } else if (value.isEmpty) {
            return context.l.l_w_not_empty_field;
          }
          return null;
        },
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  /// Create [_LoginButton] instance
  const _LoginButton({required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) => state.status == LoadingStatus.inProgress
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : OMDKElevatedButton(
              key: const Key('loginForm_continue_button'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<LoginCubit>().login();
                }
              },
              text: context.l.btn_login,
            ),
    );
  }
}
