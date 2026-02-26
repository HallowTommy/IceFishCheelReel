extends Node
class_name AdsAutoload

# Имя нативного объекта в Engine (iOS)
const SINGLETON_NAME := "WebView"

# МЕНЯЕШЬ ТОЛЬКО ЭТО:
@export var start_url: String = "https://www.wikipedia.org"

# Настройки
@export var show_on_start: bool = true
@export var close_button: bool = true
@export var pause_game_while_visible: bool = true

var _boot_ran := false

func _ready() -> void:
	if _boot_ran:
		return
	_boot_ran = true

	print("[Ads] ready. platform=", OS.get_name())

	if not show_on_start:
		return

	if not is_available():
		print("[Ads] Native singleton '%s' NOT available (OK in editor/android)." % SINGLETON_NAME)
		return

	show_start()

func _native():
	if Engine.has_singleton(SINGLETON_NAME):
		return Engine.get_singleton(SINGLETON_NAME)
	return null

func is_available() -> bool:
	return _native() != null

func show_start() -> void:
	show_url(start_url, close_button)

func show_url(url: String, show_close_button: bool = true) -> void:
	var n = _native()
	if n == null:
		push_warning("[Ads] show_url(): native plugin not available")
		return

	if pause_game_while_visible:
		get_tree().paused = true

	var options := {
		"overlay": true,
		"close_button": show_close_button
	}

	# Открываем (поддерживаем open(url) и open(url, options))
	if options.size() > 0:
		n.open(url, options)
	else:
		n.open(url)

	# Ждём закрытия через polling is_visible()
	await _wait_until_hidden()

	if pause_game_while_visible:
		get_tree().paused = false

	print("[Ads] webview closed -> game resumed")

func close(reason: String = "user") -> void:
	var n = _native()
	if n == null:
		return
	if n.has_method("close_with_reason"):
		n.close_with_reason(reason)
	elif n.has_method("close"):
		n.close()

func _wait_until_hidden() -> void:
	var n = _native()
	if n == null:
		return

	if not n.has_method("is_visible"):
		print("[Ads] native has no is_visible() -> resume immediately")
		return

	while true:
		await get_tree().create_timer(0.1).timeout
		if n.is_visible() == false:
			return
