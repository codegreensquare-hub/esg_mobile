import 'package:esg_mobile/presentation/screens/code_green/about.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/event.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/home.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/look_book.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/original_shop.tab.dart';

const String codeGreenLoginTabId = 'login';

const codeGreenTabs = [
  HomeTab.tab,
  CurationShopTab.tab,
  OriginalShopTab.tab,
  LookBookTab.tab,
  AboutTab.tab,
  EventTab.tab,
  codeGreenLoginTabId,
];

const codeGreenLabels = {
  HomeTab.tab: 'Home',
  CurationShopTab.tab: 'Curation Shop',
  OriginalShopTab.tab: 'Original Shop',
  LookBookTab.tab: 'Look Book',
  AboutTab.tab: 'About',
  EventTab.tab: 'Event',
  codeGreenLoginTabId: 'Login',
};

const codeGreenSubTabs = {
  OriginalShopTab.tab: ['all', 'best', 'style', 'type'],
  CurationShopTab.tab: ['all', 'best', 'style', 'type'],
};

const codeGreenSubSubTab = {
  'style': ['tote', 'shoulder', 'cross', 'accessories'],
  'type': ['natural', 'biodegradable', 'vegan'],
};
