import 'package:esg_mobile/presentation/screens/code_green/about.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/event.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/home.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/look_book.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/original_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail.tab.dart';

const String codeGreenLoginTabId = 'login';
const String codeGreenProductTabId = CodeGreenProductDetailTab.tab;
const String lookbookEntryViewerTabId = 'lookbook_entry_viewer';

const codeGreenTabs = [
  HomeTab.tab,
  OriginalShopTab.tab,
  CurationShopTab.tab,
  AboutTab.tab,
  LookBookTab.tab,
  lookbookEntryViewerTabId,
  EventTab.tab,
  codeGreenProductTabId,
  codeGreenLoginTabId,
];

const codeGreenLabels = {
  HomeTab.tab: 'Home',
  CurationShopTab.tab: 'Curation Shop',
  OriginalShopTab.tab: 'Original Shop',
  LookBookTab.tab: 'Look Book',
  lookbookEntryViewerTabId: 'Look Book Viewer',
  AboutTab.tab: 'About',
  EventTab.tab: 'Event',
  codeGreenProductTabId: 'Product',
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
