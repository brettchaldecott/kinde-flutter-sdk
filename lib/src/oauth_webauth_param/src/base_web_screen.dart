import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kinde_flutter_sdk/src/oauth_webauth_param/oauth_webauth_param.dart';
import 'package:kinde_flutter_sdk/src/oauth_webauth_param/src/base/base_flow.dart';
import 'package:kinde_flutter_sdk/src/oauth_webauth_param/src/base/model/base_configuration.dart';
import 'package:kinde_flutter_sdk/src/oauth_webauth_param/src/base_web_view.dart';


class BaseWebScreen extends StatelessWidget {
  static Future? start({
    Key? key,
    GlobalKey<BaseWebViewState>? globalKey,
    required BuildContext context,
    required BaseConfiguration configuration,
  }) {
    assert(
        !kIsWeb ||
            (kIsWeb &&
                configuration.onSuccessRedirect != null &&
                configuration.onError != null &&
                configuration.onCancel != null),
        'You must set onSuccessRedirect, onError and onCancel function when running on Web otherwise you will not get any result.');
    if (kIsWeb) {
      final baseFlow = BaseFlow()
        ..init(
          initialUri: Uri.parse(configuration.initialUrl),
          redirectUrls: configuration.redirectUrls,
          onSuccessRedirect: configuration.onSuccessRedirect,
          onError: configuration.onError,
          onCancel: configuration.onCancel,
        );
      baseFlow.onNavigateTo(OAuthWebAuth.instance.appBaseUrl);
      return null;
    }
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BaseWebScreen(
                  key: key,
                  globalKey: globalKey,
                  configuration: configuration,
                )));
  }

  late final BuildContext context;
  final GlobalKey<BaseWebViewState> globalKey;
  final BaseConfiguration configuration;

  BaseWebScreen({
    Key? key,
    GlobalKey<BaseWebViewState>? globalKey,
    required this.configuration,
  })  : globalKey = globalKey ?? GlobalKey<BaseWebViewState>(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        this.context = context;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: WillPopScope(
              onWillPop: onBackPressed,
              child: BaseWebView(
                key: globalKey,
                configuration: configuration.copyWith(
                  onSuccessRedirect: _onSuccess,
                  onError: _onError,
                  onCancel: _onCancel,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSuccess(String responseRedirect) {
    Navigator.pop(context, responseRedirect);
    configuration.onSuccessRedirect?.call(responseRedirect);
  }

  void _onError(dynamic error) {
    Navigator.pop(context, error);
    configuration.onError?.call(error);
  }

  void _onCancel() {
    Navigator.pop(context);
    configuration.onCancel?.call();
  }

  Future<bool> onBackPressed() async {
    if (!((await globalKey.currentState?.onBackPressed()) ?? false)) {
      return false;
    }
    configuration.onCancel?.call();
    return true;
  }
}
