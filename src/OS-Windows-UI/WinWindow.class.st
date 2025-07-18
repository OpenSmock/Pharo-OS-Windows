"
A native window in Windows. Note that this can be a real desktop window as well as any (non-framed) widget.

It is better to use subclasses to work with more specific
kinds of windows.


"
Class {
	#name : 'WinWindow',
	#superclass : 'WinHandle',
	#pools : [
		'WinBaseConstants',
		'WinTypes',
		'WinUserConstants'
	],
	#category : 'OS-Windows-UI-Desktop',
	#package : 'OS-Windows-UI',
	#tag : 'Desktop'
}

{ #category : 'accessing - instances' }
WinWindow class >> activeWindow [
	"Retrieves the window to the active window associated with the thread that calls the function. "

	^ self fromExternalHandle: self activeWindowHandle
]

{ #category : 'accessing - handles' }
WinWindow class >> activeWindowHandle [
	"Retrieves the window handle to the active window associated with the thread that calls the function. "

	^ self ffiCall: #(HWND GetActiveWindow()) module: #user32
]

{ #category : 'accessing - instances' }
WinWindow class >> captureWindow [
	"Return retrieves the window (if any) that has captured the mouse. Only one window at a time can capture the mouse; this window receives mouse input whether or not the cursor is within its borders."

	^ self fromExternalHandle: self captureWindowHandle
]

{ #category : 'accessing - handles' }
WinWindow class >> captureWindowHandle [
	"Return the handle of the window (if any) that has captured the mouse. Only one window at a time can capture the mouse; this window receives mouse input whether or not the cursor is within its borders."

	^ self ffiCall: #(HWND GetCapture()) module: #user32
]

{ #category : 'accessing - instances' }
WinWindow class >> clipboardOwnerWindow [
	"Retrieves the window that is the current owner of the clipboard."

	^ self fromExternalHandle: self clipboardOwnerWindowHandle
]

{ #category : 'accessing - handles' }
WinWindow class >> clipboardOwnerWindowHandle [
	"Retrieves the window handle of the current owner of the clipboard."

	^self ffiCall: #( HWND GetClipboardOwner()) module: #user32
]

{ #category : 'accessing - instances' }
WinWindow class >> clipboardViewerWindow [
	"Returns the first window in the clipboard viewer chain."

	^ self fromExternalHandle: self clipboardViewerWindowHandle
]

{ #category : 'accessing - handles' }
WinWindow class >> clipboardViewerWindowHandle [
	"Retrieves the handle of the first window in the clipboard viewer chain."

	^self ffiCall: #( HWND GetClipboardViewer()) module: #user32
]

{ #category : 'primitives' }
WinWindow class >> createWindowExA: dwExStyle lpClassName: lpClassName lpWindowName: lpWindowName dwStyle: dwStyle
x: x y: y width: nWidth height: nHeight hWndParent: hWndParent hMenu: hMenu
hInstance: hInstance lParam: lpParam [

	^ self ffiCall: #( HWND 'CreateWindowExA'
			( DWORD dwExStyle,
			LPCTSTR lpClassName,
			LPCTSTR lpWindowName,
			DWORD dwStyle,
			ulong x,
			ulong y,
			ulong nWidth,
			ulong nHeight,
			HWND hWndParent,
			HMENU hMenu,
			HINSTANCE hInstance,
			LPVOID lpParam) )
		module: #user32
]

{ #category : 'accessing - instances' }
WinWindow class >> desktopWindow [
	"Return the handle of the windows desktop window"

	^ self fromExternalHandle: self desktopWindowHandle
]

{ #category : 'accessing - handles' }
WinWindow class >> desktopWindowHandle [
	"Return the handle of the windows desktop window"

	^ self ffiCall: #( HWND GetDesktopWindow()) module: #user32
]

{ #category : 'accessing - handles' }
WinWindow class >> enumWindows [
<script: 'self enumWindows inspect'>
| callback oc block |
oc := OrderedCollection new.
block := [ :h :p | 
	oc add: (WinWindow fromExternalHandle: h).
	 ].
callback := FFICallback signature: #(bool (void* hwnd, long param) ) block: [ :hwnd :param | 
		"hwnd is an ExternalAddress" 
		block value: hwnd value: param.
		true  ].
self enumWindows: callback param: 0.
^oc
]

{ #category : 'accessing - handles' }
WinWindow class >> enumWindows: function param: param [

	^self ffiCall: #(int EnumWindows(FFICallback function, long param)) module: #user32 
]

{ #category : 'accessing - handles' }
WinWindow class >> enumWindowsClassLike: aName [
| list |
list:= self enumWindows.
list := list select:[ :e | '*',aName asLowercase,'*' match: e getClassName asLowercase ].
^list
]

{ #category : 'accessing - instances' }
WinWindow class >> focusWindow [
	"Return the window currently having the input focus"

	^ self fromExternalHandle: self focusWindowHandle
]

{ #category : 'accessing - handles' }
WinWindow class >> focusWindowHandle [
	"Return the handle of the window currently having the input focus"

	^ self ffiCall: #(HWND GetFocus ()) module: #user32
]

{ #category : 'accessing - instances' }
WinWindow class >> foregroundWindow [
	"Returns the foreground window (the window with which the user is currently working)."

	^ self fromExternalHandle: self foregroundWindowHandle
]

{ #category : 'accessing - handles' }
WinWindow class >> foregroundWindowHandle [
	"Returns the handle of the foreground window (the window with which the user is currently working)."

	^self ffiCall: #( HWND GetForegroundWindow()) module: #user32
]

{ #category : 'accessing - instances' }
WinWindow class >> pharoWindow [
	<script: 'self pharoWindow inspect'>

	| sdlWindowInfo handle osWindow |
	osWindow := self currentWorld worldState worldRenderer window.
	sdlWindowInfo := osWindow backendWindow getWMInfo.
	handle := sdlWindowInfo info win window.

	^ self fromExternalHandle: handle
]

{ #category : 'accessing' }
WinWindow class >> windowFromPoint: point [

	^self ffiCall: #(HWND WindowFromPoint(POINT point)) module: #user32
]

{ #category : 'comparing' }
WinWindow >> = anotherWindow [
	"Compare using the external give handle"

	^ self species = anotherWindow species and: [
		  self getHandle = anotherWindow getHandle ]
]

{ #category : 'positioning' }
WinWindow >> centerOnDesktop [
	"Center the given window on the desktop"

	self moveTo: (self class desktopWindow windowRectangle extent // 2 - (self windowRectangle extent // 2))
]

{ #category : 'primitives' }
WinWindow >> closeWindow [
	"close the window"

	^ self
		ffiCall: #( BOOL CloseWindow #( HWND self )) module: #user32
]

{ #category : 'primitives' }
WinWindow >> closeWindow: aHandle [
	"close the specified window"

	^ self
		ffiCall: #( BOOL CloseWindow #( HWND aHandle ) )
		module: #user32
]

{ #category : 'visibility' }
WinWindow >> destroy [
	"destroy the window - note this does not end the OS process"
	^ self destroyWindow
]

{ #category : 'primitives' }
WinWindow >> destroyWindow [
	"destroy the window - note this does not end the OS process"

	^ self ffiCall: #( BOOL DestroyWindow ( HWND self )) module: #user32
]

{ #category : 'accessing' }
WinWindow >> deviceContext [

	^ self ffiCall: #(HDC GetDC (HWND self)) module: #user32
]

{ #category : 'primitives' }
WinWindow >> enumWindows: function param: param [

	^self ffiCall: #(int EnumWindows(FFICallback function, long param)) module: #user32 
]

{ #category : 'accessing' }
WinWindow >> getClassName [ 
	| string sz |
	string := (ByteArray new: 257).
	sz := self getClassName: self getHandle buffer: string length: 256.
	^string asString first: sz.
]

{ #category : 'primitives' }
WinWindow >> getClassName: hwnd buffer: string length: length [

	^self ffiCall: #(LONG GetClassNameA (HWND hwnd, char *string, LONG length)) module: #user32
]

{ #category : 'primitives' }
WinWindow >> getWindow: wCmd [
	"Retrieves the handle of a window that has the specified relationship (Z order or owner) to the specified window."

	^self ffiCall: #(HWND GetWindow(HWND self, UINT wCmd)) module: #user32
]

{ #category : 'primitives' }
WinWindow >> getWindowLong: hWnd index: nIndex [

	^self ffiCall: #(LONG GetWindowLongA(HWND hWnd, int nIndex)) module: #user32
]

{ #category : 'primitives' }
WinWindow >> getWindowLongAtIndex: nIndex [

	^self ffiCall: #(LONG GetWindowLongA(HWND self, int nIndex)) module: #user32
]

{ #category : 'primitives' }
WinWindow >> getWindowRect: rect [

	^self ffiCall: #(BOOL GetWindowRect(HWND self, RECT* rect)) module: #user32
]

{ #category : 'accessing' }
WinWindow >> getWindowStyle [

	^ self getWindowLong: self getHandle index: GWL_STYLE
]

{ #category : 'private' }
WinWindow >> getWindowText [
	"self focusWindow windowText"
	| str size |
	size := self getWindowTextLength.
	size = 0 ifTrue: [^''].
	size := size +1.
	str := ByteArray new: size.
	self getWindowText: self buffer: str bufferSize: size.
	str := str asString.
	^str.
]

{ #category : 'primitives' }
WinWindow >> getWindowText: hWnd buffer: lpString bufferSize: nMaxCount [

	^self ffiCall: #(int GetWindowTextA(HWND hWnd, char* lpString, int nMaxCount)) module: #user32
]

{ #category : 'primitives' }
WinWindow >> getWindowTextLength [
	self getHandle isNil ifTrue:[ ^0 ].
	self getHandle = 0 ifTrue: [ ^0 ].
	^self getWindowTextLength: self getHandle
]

{ #category : 'primitives' }
WinWindow >> getWindowTextLength: hwnd [
	^self ffiCall: #(LONG GetWindowTextLengthA (void* hwnd)) module: #user32
]

{ #category : 'comparing' }
WinWindow >> hash [

	^ self getHandle asInteger hash
]

{ #category : 'visibility' }
WinWindow >> hide [
	"hide the window"

	^ self ffiCall: #( BOOL ShowWindow ( HWND self, int SW_HIDE ))
			module: #user32
]

{ #category : 'testing' }
WinWindow >> isEnabled [
	"Retrieves the enable state of the specified window"

	^ self
		  ffiCall: #( int IsWindowEnabled #( HWND self ) )
		  module: #user32
]

{ #category : 'testing' }
WinWindow >> isEnabled: hwnd [
	"Retrieves the enable state of the specified window"

	^ self
		  ffiCall: #( int IsWindowEnabled #( HWND hwnd ) )
		  module: #user32
]

{ #category : 'testing' }
WinWindow >> isIconic [
	"Determines whether the specified window is minimized (iconic). "

	^self ffiCall: #(BOOL IsIconic(HWND self)) module: #user32
]

{ #category : 'testing' }
WinWindow >> isVisible [
	"Retrieves the visibility state of the specified window. . "

	^self ffiCall: #(BOOL IsWindowVisible(HWND self)) module: #user32
]

{ #category : 'testing' }
WinWindow >> isZoomed [
	"Determines whether a window is maximized. "

	^self ffiCall: #(BOOL IsZoomed(HWND self)) module: #user32
]

{ #category : 'positioning' }
WinWindow >> maximize [

	self showWindow: self getHandle cmdShow: SW_MAXIMIZE
]

{ #category : 'positioning' }
WinWindow >> minimize [

	self showWindow: self getHandle cmdShow: SW_MINIMIZE
]

{ #category : 'positioning' }
WinWindow >> moveTo: aPoint [

	|rect|
	rect := self windowRectangle.
	self moveWindowX: aPoint x y: aPoint y width: rect width height: rect height
]

{ #category : 'primitives' }
WinWindow >> moveWindowX: x y: y width: nWidth height: nHeight [
	"move window example"

	^ self ffiCall: #(
			BOOL MoveWindow ( HWND self,
				int x,
				int y,
				int nWidth,
   				int nHeight,
 				int false
				))
		module: #user32
]

{ #category : 'primitives' }
WinWindow >> openIcon: hWnd [

	^ self
		ffiCall: #( BOOL OpenIcon #( HWND hWnd ) )
		module: #user32
]

{ #category : 'printing' }
WinWindow >> printOn: aStream [
aStream nextPutAll: 'Window(',self  getClassName,') ''''',self getWindowText,')'.
]

{ #category : 'primitives' }
WinWindow >> releaseDC: hdc [

	^self ffiCall: #(int ReleaseDC(HWND self, HDC hdc)) module: #user32
]

{ #category : 'visibility' }
WinWindow >> setNonResizable [

	| newStyle |
	newStyle := self windowStyle bitClear: (WS_SIZEBOX|WS_MINIMIZE|WS_MAXIMIZE).
	self setWindowLong: self index: GWL_STYLE newVale: newStyle
]

{ #category : 'primitives' }
WinWindow >> setWindowLong: hWnd index: nIndex newVale: dwNewLong [

	^self ffiCall: #(LONG SetWindowLongA(HWND hWnd, int nIndex, LONG dwNewLong)) module: #user32
]

{ #category : 'primitives' }
WinWindow >> setWindowText: lpString [

	^self ffiCall: #(BOOL SetWindowTextA(HWND self, LPCTSTR lpString)) module: #user32
]

{ #category : 'visibility' }
WinWindow >> show [
	"show the window"

	^ self ffiCall: #( BOOL ShowWindow ( HWND self, int SW_SHOW ))
			  module: #user32
]

{ #category : 'primitives' }
WinWindow >> showWindow: hwnd cmdShow: nCmdShow [ 

	^self ffiCall: #(BOOL ShowWindow(HWND hwnd, int nCmdShow)) module: #user32.

]

{ #category : 'accessing' }
WinWindow >> title [

	^self windowText
]

{ #category : 'accessing' }
WinWindow >> title: aString [

	^self setWindowText: aString
]

{ #category : 'accessing' }
WinWindow >> windowRectangle [

	|rect|
	rect := WinRectangle new.
	^(self getWindowRect: rect)
		ifTrue: [ rect asRectangle ]
		ifFalse: [ self error: 'failed' ]
]

{ #category : 'accessing' }
WinWindow >> windowStyle [
	"Retrieves the window styles"

	^self getWindowLongAtIndex: GWL_STYLE
]

{ #category : 'private' }
WinWindow >> windowText [
	"self focusWindow windowText"
	| len str |
	str := ByteString new: 1000.
	len := self getWindowText: self buffer: str bufferSize: 1000.
	^ str first: len
]
