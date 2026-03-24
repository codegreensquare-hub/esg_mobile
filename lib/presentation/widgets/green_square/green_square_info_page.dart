import 'package:flutter/material.dart';

/// Background color for policy-style pages (terms, privacy); app bar matches.
const kPolicyPageBackground = Color(0xFFF3F1EF);
const kPolicyAppBarBackground = Color(0xFFFAF8F6);

class GreenSquareInfoPage extends StatelessWidget {
  const GreenSquareInfoPage({
    super.key,
    required this.title,
    this.body,
    this.bodyBuilder,
    this.appbarBackgroundColor,
    this.backgroundColor,
  }) : assert(
         body != null || bodyBuilder != null,
         'Either body or bodyBuilder must be provided',
       );

  final String title;
  final Widget? body;

  /// When set (with [backgroundColor]), content is built with a [Theme]
  /// that uses Noto Sans KR, so [Theme.of(context).textTheme] has the font.
  final Widget Function(BuildContext context)? bodyBuilder;
  final Color? appbarBackgroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useLightStyle = backgroundColor != null;
    final textTheme = useLightStyle
        ? theme.textTheme.apply(fontFamily: 'Noto Sans KR')
        : theme.textTheme;

    final Widget bodyContent;
    if (useLightStyle && bodyBuilder != null) {
      bodyContent = Theme(
        data: theme.copyWith(textTheme: textTheme),
        child: Builder(builder: (context) => bodyBuilder!(context)),
      );
    } else if (useLightStyle && body != null) {
      bodyContent = Theme(
        data: theme.copyWith(textTheme: textTheme),
        child: body!,
      );
    } else {
      bodyContent = body ?? bodyBuilder!(context);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor:
            appbarBackgroundColor ??
            (useLightStyle ? kPolicyAppBarBackground : backgroundColor),
        foregroundColor: useLightStyle ? Colors.black : null,
        leading: useLightStyle
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          title,
          style: (useLightStyle ? textTheme : theme.textTheme).titleLarge
              ?.copyWith(
                fontWeight: FontWeight.w400,
                fontFamily: 'Noto Sans KR',
                color: useLightStyle ? Colors.black : null,
              ),
        ),
      ),
      body: bodyContent,
    );
  }
}
