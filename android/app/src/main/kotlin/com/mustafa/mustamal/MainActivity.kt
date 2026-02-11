override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.moeninja.mustamal/battery").setMethodCallHandler {
        call, result ->
        if (call.method == "getBatteryTemp") {
            result.success("35.5 C") // Your native logic here
        } else {
            result.notImplemented()
        }
    }
}