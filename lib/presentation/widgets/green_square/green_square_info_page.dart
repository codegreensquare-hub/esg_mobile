import 'package:flutter/material.dart';

/// Background color for policy-style pages (terms, privacy); app bar matches.
const kPolicyPageBackground = Color(0xFFF3F1EF);

class GreenSquareInfoPage extends StatelessWidget {
  const GreenSquareInfoPage({
    super.key,
    required this.title,
    this.body,
    this.bodyBuilder,
    this.appbarBackgroundColor = const Color.fromARGB(255, 255, 255, 255),
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
  final Color appbarBackgroundColor;
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
        backgroundColor: appbarBackgroundColor ?? backgroundColor,
        foregroundColor: useLightStyle ? Colors.black87 : null,
        title: Text(
          title,
          style: (useLightStyle ? textTheme : theme.textTheme).titleLarge
              ?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'Noto Sans KR',
                color: useLightStyle ? Colors.black87 : null,
              ),
        ),
      ),
      body: bodyContent,
    );
  }
}
