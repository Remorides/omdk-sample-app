import 'package:flutter/cupertino.dart';
import 'package:omdk_sample_app/blocs/auth/bloc/auth_bloc.dart';
import 'package:omdk_sample_app/common/common.dart';
import 'package:omdk_sample_app/elements/alerts/alerts.dart';
import 'package:omdk_sample_app/elements/alerts/simple_alert/simple_alert.dart';
import 'package:omdk_sample_app/elements/elements.dart';
import 'package:provider/provider.dart';

/// Login page builder
class OTPFailsPage extends StatefulWidget {
  /// Create [OTPFailsPage] instance
  const OTPFailsPage({super.key});

  @override
  State<OTPFailsPage> createState() => _OTPFailsPageState();
}

class _OTPFailsPageState extends State<OTPFailsPage> {
  @override
  Widget build(BuildContext context) {
    return OMDKSimplePage(
      key: widget.key,
      withAppbar: false,
      withBottomBar: false,
      withDrawer: false,
      bodyPage: ResponsiveWidget.isSmallScreen(context)
          ? Center(
              child: OMDKAlert<dynamic>(
                title: context.l.a_t_warning,
                message: Text(context.l.a_msg_otp_invalid),
                confirm: context.l.btn_ok,
                type: AlertType.warning,
                onConfirm: () =>
                    context.read<AuthBloc>().add(LogoutRequested()),
              ),
            )
          : Center(
              child: SizedBox(
                width: 300,
                child: OMDKAlert<dynamic>(
                  title: context.l.a_t_warning,
                  message: Text(context.l.a_msg_otp_invalid),
                  confirm: context.l.btn_ok,
                  type: AlertType.warning,
                  onConfirm: () =>
                      context.read<AuthBloc>().add(LogoutRequested()),
                ),
              ),
            ),
    );
  }
}
