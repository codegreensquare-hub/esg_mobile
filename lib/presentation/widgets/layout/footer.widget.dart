import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/presentation/widgets/logo/code_green.logo.dart';
import 'package:flutter/material.dart';

class CodeGreenFooter extends StatelessWidget {
  const CodeGreenFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(defaultPadding),
      alignment: Alignment.center,
      child: SafeArea(
        top: false,
        bottom: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: frameWidth + defaultPadding * 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const CodeGreenLogo(),
              const SizedBox(height: 12),
              Row(
                // TODO social media links redirection
                // Social media icons placeholders
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // TODO replace with better mail
                  Icon(Icons.mail, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 16),
                  // TODO replace with circlular chat bubble icon
                  Icon(
                    Icons.chat_bubble_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 16),
                  // TODO replace with instagram
                  Icon(
                    Icons.camera_alt,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(width: 16),
                  // TODO replace with Naver
                  Icon(
                    Icons.nearby_error,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /*
              리더스 오브 그린 소사이어티 
              Leaders of Green Society
          
              서울특별시 성북구 안암로 145 고려대학교 경영본관 
              일진창업센터 2층 219호 (02841)
              사업자등록번호 5265100275
              통신판매업번호 2019-서울성북-1302 
              전화번호 02-926-0727 / 이메일 lgs190727@naver.com
              Copyright © 2020 codegreen.co.kr All Right Reserved.  
              */
              // Address / company info broken into discrete Text widgets for clarity.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '리더스 오브 그린 소사이어티',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leaders of Green Society',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '서울특별시 성북구 안암로 145 고려대학교 경영본관',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '일진창업센터 2층 219호 (02841)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '사업자등록번호 5265100275',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '통신판매업번호 2019-서울성북-1302',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '전화번호 02-926-0727 / 이메일 lgs190727@naver.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Copyright © 2020 codegreen.co.kr All Right Reserved',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
