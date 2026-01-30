library web_updater;

JsContext context = JsContext();

class JsContext {
  dynamic operator [](String key) => JsObject();
  void callMethod(String method, List args) {}
}

class JsObject {
  void callMethod(String method, List args) {}
}
