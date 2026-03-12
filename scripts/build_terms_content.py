#!/usr/bin/env python3
"""Generate terms.screen.dart Column children for 마일리지 정책."""

def p_bottom(n, style="bodyStyle"):
    return f'''              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  ''' + "'''" + "{}".replace("'", "\\'") + "'''" + f''',
                  style: {style},
                ),
              ),'''

def p_left_bottom(text, style="bodyStyle"):
    t = text.replace("\\", "\\\\").replace("'", "\\'")
    return f'''              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Text(
                  '{t}',
                  style: {style},
                ),
              ),'''

def article(title):
    return f'''              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('{title}', style: articleLabelStyle),
              ),'''

def chapter(title):
    return f'''              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 14),
                child: Text('{title}', style: chapterStyle),
              ),'''

# Build content as list of (type, content) then render
# type: 'chapter', 'article', 'body', 'body_first'
lines = []
def add_chapter(s): lines.append(('c', s))
def add_article(s): lines.append(('a', s))
def add_body(s, first=False): lines.append(('b', s))

# Ch1
add_chapter("1장 총칙")
add_article("제1조(목적)")
add_body("본 약관은 ㈜ 리더스 오브 그린 소사이어티(이하 \"회사\")가 운영하는 \"Code Green square\"를 통해서 제공하는 전자상거래 관련 서비스 및 기타 서비스(이하 \"서비스\")를 이용함에 있어서의 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.", first=True)
add_article("제2조(용어의 정의)")
add_body("① 본 약관에서 사용되는 용어의 정의는 다음과 같습니다.")
add_body("1. \"서비스\"란 회원의 단말기(모바일, 태블릿PC 등 각종 유무선 장치를 포함)를 통하여 회사가 제공하는 코드 그린 스퀘어 관련 서비스 일체를 말합니다.")
add_body("2.\"회원\"이란 서비스에 카카오계정 로그인 접속하여 이용계약을 체결하고 서비스를 이용하는 고객을 말합니다.")
# ... (truncated - would need full content)

# Just output the structure for one section to test
out = []
out.append("              Padding(")
out.append("                padding: const EdgeInsets.only(bottom: 12),")
out.append("                child: Text('마일리지 정책', style: titleStyle),")
out.append("              ),")
print("\n".join(out))
