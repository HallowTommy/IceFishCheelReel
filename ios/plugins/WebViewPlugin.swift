import Godot
import UIKit

@objc(WebViewPlugin)
class WebViewPlugin: NSObject, GodotPlugin {

    func registerSingletons() {
        registerSingleton(name: "WebView", object: self)
    }

    @objc func open(_ url: String, _ options: Dictionary?) {
        print("[WebViewPlugin] open called with url:", url)
        WebViewManager.shared.open(urlString: url)
    }

    @objc func close() {
        WebViewManager.shared.close()
    }

    @objc func is_visible() -> Bool {
        return WebViewManager.shared.is_webview_visible()
    }
}
