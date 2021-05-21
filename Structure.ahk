/*
** MSDN_Types: https://github.com/jNizM/AutoHotkey_MSDN_Types/blob/master/src/Windows_Data_Types.txt. **
** MSDN_Structs: https://www.autohotkey.com/boards/viewtopic.php?f=74&t=30497. **
*/

;============ Auto-execute ====================================================;
;======================================================  Setting  ==============;

#Requires AutoHotkey v2.0-a134-d3d43350

;============== Function ======================================================;

StructureFromArray(array, type := "UInt") {
	if (array.__Class != "Array") {
		throw (TypeError(Format("{} is invalid.", Print(array)), -1))
	}

	if (!(type ~= "i)Char|UChar|Short|UShort|Float|Int|UInt|Int64|UInt64|Ptr|UPtr")) {
		throw (ValueError(Format("{} is invalid.", Print(type)), -1))
	}

	size := Structure.SizeOf(type)
		, pointer := (instance := Structure(array.Length*size)).Ptr

	for index, value in array {
		NumPut(type, value, pointer + size*index)
	}

	return (instance)
}

StructureFromStructure(structs*) {
	if (!(structs.Every((value, index, array) => (value.__Class == "Structure")))) {
		throw (TypeError(Format("{} is invalid.", Print(structs)), -1, "This function only accepts parameters of type: Structure."))
	}

	for struct in (bytes := 0, structs) {
		bytes += struct.Size
	}

	for struct in (pointer := (instance := Structure(bytes)).Ptr, structs) {
		DllCall("NtDll\RtlCopyMemory", "Ptr", pointer, "Ptr", struct.Ptr, "Ptr", size := struct.Size), pointer += size
	}

	return (instance)
}

;===============  Class  =======================================================;

Class Structure {
	static Heap := DllCall("Kernel32\GetProcessHeap", "Ptr")  ;! DllCall("Kernel32\HeapCreate", "UInt", 0x00000004, "Ptr", 0, "Ptr", 0, "Ptr")

	static SizeOf(type) {
		static sizeLookup := Map("Char", 1, "UChar", 1, "Short", 2, "UShort", 2, "Float", 4, "Int", 4, "UInt", 4, "Int64", 8, "UInt64", 8, "Ptr", A_PtrSize, "UPtr", A_PtrSize)

		return (sizeLookup[type])
	}

	;* Structure.CreateWndClassEx(style, lpfnWndProc, cbClsExtra, cbWndExtra, hInstance, hIcon, hCursor, hbrBackground, lpszMenuName, lpszClassName, hIconSm)
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexa.
	;* Parameter:
		;* style - See https://docs.microsoft.com/en-us/windows/win32/winmsg/window-class-styles.
	static CreateWndClassEx(style, lpfnWndProc, cbClsExtra, cbWndExtra, hInstance, hIcon, hCursor, hbrBackground, lpszMenuName, lpszClassName, hIconSm) {
		(s := Structure(cbSize := ((A_PtrSize == 8) ? (80) : (48)))).NumPut(0, "UInt", cbSize, "UInt", style, "Ptr", lpfnWndProc, "Int", cbClsExtra, "Int", cbWndExtra, "Ptr", hInstance, "Ptr", hIcon, "Ptr", hCursor, "Ptr", hbrBackground, "Ptr", lpszMenuName, "Ptr", lpszClassName, "Ptr", hIconSm)

		return (s)
	}  ;? WNDCLASSEXA, *PWNDCLASSEXA, *NPWNDCLASSEXA, *LPWNDCLASSEXA;

	;* Structure.CreateCursorInfo([flags, cursor, [Structure] screenPos])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-cursorinfo.
	static CreateCursorInfo(flags := 0, cursor := 0, screenPos := unset) {
		if (!(IsSet(screenPos))) {
			screenPos := this.CreatePoint(0, 0, "UInt")
		}

		(s := this(A_PtrSize + 16)).NumPut(0, "UInt", A_PtrSize + 16, "UInt", flags, "Ptr", cursor, "Struct", screenPos)

		return (s)
	}  ;? CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

	;* Structure.CreateSecurityDescriptor()
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-security_descriptor.
	static CreateSecurityDescriptor() {
		s := this(A_PtrSize*4 - 4*(A_PtrSize == 4) + 8)

		return (s)
	}  ;? SECURITY_DESCRIPTOR, *PISECURITY_DESCRIPTOR;

	;* Structure.CreateGDIplusStartupInput()
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/gdiplusinit/ns-gdiplusinit-gdiplusstartupinput.
	static CreateGDIplusStartupInput() {
		(s := this(A_PtrSize*2 + 8, True)).NumPut(0, "UInt", 0x1)

		return (s)
	}

	;* Structure.CreateConsoleReadConsoleControl([initialChars, ctrlWakeupMask, controlKeyState])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/console/console-readconsole-control.
	;* Parameter:
		;* ctrlWakeupMask - See https://www.asciitable.com/.
	static CreateConsoleReadConsoleControl(initialChars := 0, ctrlWakeupMask := 0x0A, controlKeyState := 0) {
		(s := this(16)).NumPut(0, "UInt", 16, "UInt", initialChars, "UInt", ctrlWakeupMask, "UInt", controlKeyState)

		return (s)
	}  ;? CONSOLE_READCONSOLE_CONTROL, *PCONSOLE_READCONSOLE_CONTROL;

	;* Structure.CreateSmallRect([x, y, width, height])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/console/small-rect-str.
	static CreateSmallRect(x := 0, y := 0, width := 0, height := 0) {
		(s := this(8)).NumPut(0, "Short", x, "Short", y, "Short", x + width - 1, "Short", y + height - 1)

		return (s)
	}  ;? SMALL_RECT;

	;* Structure.CreateCoord([x, y])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/console/coord-str.
	static CreateCoord(x := 0, y := 0) {
		(s := this(4)).NumPut(0, "Short", x, "Short", y)

		return (s)
	}  ;? COORD, *PCOORD;

	;* Structure.CreatePoint([x, y, type])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-point.
	static CreatePoint(x := 0, y := 0, type := "UInt") {
		if (!(type ~= "i)Float|Int|UInt")) {
			throw (ValueError(Format("{} is invalid.", Print(type)), -1))
		}

		(s := this(8)).NumPut(0, type, x, type, y)  ;:

		return (s)
	}  ;? POINT, *PPOINT, *NPPOINT, *LPPOINT;

	;* Structure.CreateRect([x, y, width, height, type])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/windef/ns-windef-rect.
	static CreateRect(x := 0, y := 0, width := 0, height := 0, type := "UInt") {
		if (!(type ~= "i)Float|Int|UInt")) {
			throw (ValueError(Format("{} is invalid.", Print(type)), -1))
		}

		(s := this(16)).NumPut(0, type, x, type, y, type, width, type, height)

		return (s)
	}  ;? RECT, *PRECT, *NPRECT, *LPRECT;

	;* Structure.CreateBitmapData([width, height, stride, pixelFormat, scan0])
	;* Description:
		;* See https://docs.microsoft.com/en-us/previous-versions/ms534421(v=vs.85).
	static CreateBitmapData(width := 0, height := 0, stride := 0, pixelFormat := 0x26200A, scan0 := 0) {
		(s := this(A_PtrSize*2 + 16)).NumPut(0, "UInt", width, "UInt", height, "Int", stride, "Int", pixelFormat, "Ptr", scan0)

		return (s)
	}  ;? BITMAPDATA;

	;* Structure.CreateBitmapInfo([Structure] bmiHeader, [Structure] bmiColors)
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfo.
	static CreateBitmapInfo(bmiHeader, bmiColors) {
		return (StructureFromStructure(bmiHeader, bmiColors))
	}  ;? BITMAPINFO, *LPBITMAPINFO, *PBITMAPINFO;

	;* Structure.CreateBitmapInfoHeader(width, height[, bitCount, compression, sizeImage, xPelsPerMeter, yPelsPerMeter, clrUsed, clrImportant])
	;* Description:
		;* See https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85).
	static CreateBitmapInfoHeader(width, height, bitCount := 32, compression := 0x0000, sizeImage := 0, xPelsPerMeter := 0, yPelsPerMeter := 0, clrUsed := 0, clrImportant := 0) {
		(s := this(40)).NumPut(0, "UInt", 40, "Int", width, "Int", height, "UShort", 1, "UShort", bitCount, "UInt", compression, "UInt", sizeImage, "Int", xPelsPerMeter, "Int", yPelsPerMeter, "UInt", clrUsed, "UInt", clrImportant)

		return (s)
	}  ;? BITMAPINFOHEADER, *PBITMAPINFOHEADER;

	;* Structure.CreateBlendFunction([sourceConstantAlpha, alphaFormat])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-blendfunction, https://www.teamdev.com/downloads/jniwrapper/winpack/javadoc/constant-values.html#com.jniwrapper.win32.gdi.BlendFunction.AC_SRC_OVER.
	;~ Note:
		;~ When the AlphaFormat member is AC_SRC_ALPHA, the source bitmap must be 32 bpp. If it is not, the AlphaBlend function will fail.
	static CreateBlendFunction(sourceConstantAlpha := 255, alphaFormat := 1) {
		(s := this(4, True)).NumPut(2, "UChar", sourceConstantAlpha, "UChar", alphaFormat)

		return (s)
	}  ;? BLENDFUNCTION, *PBLENDFUNCTION;

	;* Structure.CreateRGBQuad([rgbBlue, rgbGreen, rgbRed])
	;* Description:
		;* See https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-rgbquad#members.
	static CreateRGBQuad(blue := 0, green := 0, red := 0) {
		(s := this(4, True)).NumPut(0, "UChar", blue, "UChar", green, "UChar", red)

		return (s)
	}  ;? RGBQUAD;

	;* Structure.CreateSize(width, height)
	;* Description:
		;* See https://docs.microsoft.com/en-us/previous-versions//dd145106(v=vs.85).
	static CreateSize(width, height) {
		(s := this(8)).NumPut(0, "Int", width, "Int", height)

		return (s)
	}  ;? SIZE, *PSIZE;

	;* Structure(bytes[, zero])
	__New(bytes, zero := False) {
		if (!(IsInteger(bytes) && bytes >= 0)) {
			throw (ValueError(Format("{} is invalid.", Print(bytes)), -1, "This parameter must be a non negative integer."))
		}

		this.Ptr := DllCall("Kernel32\HeapAlloc", "Ptr", Structure.Heap, "UInt", (zero) ? (0x00000008) : (0x00000000), "Ptr", bytes, "Ptr")  ;~ Heap allocations made by calling the malloc and HeapAlloc functions are non-executable.
	}

	__Delete() {
		static hHeap := Structure.Heap

		DllCall("Kernel32\HeapFree", "Ptr", hHeap, "UInt", 0, "Ptr", this.Ptr)
	}

	Size {
		Get {
			return (this.GetSize())
		}

		Set {
			this.SetSize(value)

			return (value)
		}
	}

	GetSize() {
		return (DllCall("Kernel32\HeapSize", "Ptr", Structure.Heap, "UInt", 0, "Ptr", this.Ptr, "Ptr"))
	}

	SetSize(value) {
		if (!(IsInteger(value) && value >= 0)) {
			throw (ValueError(Format("{} is invalid.", Print(value)), -1, "This parameter must be a non negative integer."))
		}

		if (!(this.Ptr := DllCall("Kernel32\HeapReAlloc", "Ptr", Structure.Heap, "UInt", 0x00000008, "Ptr", this.Ptr, "Ptr", value, "Ptr"))) {  ;~ If HeapReAlloc fails, the original memory is not freed, and the original handle and pointer are still valid.
			throw (MemoryError("Kernel32\HeapReAlloc failed to allocate memory."))
		}
	}

	NumGet(offset, type, bytes := 0) {
		if (!(IsInteger(offset) && offset >= 0)) {
			throw (ValueError(Format("{} is invalid.", Print(offset)), -1, "This parameter must be a non negative integer."))
		}

		if (type ~= "i)Struct|Structure") {  ;* Create and return a new struct from a slice of another.
			if (!(IsInteger(bytes) && bytes >= 0)) {
				throw (ValueError(Format("{} is invalid.", Print(bytes)), -1, "This parameter must be a non negative integer."))
			}

			if (offset + bytes >= this.Size) {
				throw (MemoryError(Format("offset ({}) + bytes ({}) exceeds the size of this struct ({}).", offset, bytes, this.Size), -1))
			}

			DllCall("NtDll\RtlCopyMemory", "Ptr", (instance := Structure(bytes)).Ptr, "Ptr", this.Ptr + offset, "Ptr", bytes)

			return (instance)
		}
		else {
			if (!(type ~= "i)Char|UChar|Short|UShort|Float|Int|UInt|Int64|UInt64|Ptr|UPtr")) {
				throw (ValueError(Format("{} is invalid.", Print(type)), -1))
			}

			return (NumGet(this.Ptr + offset, type))
		}
	}

	NumPut(offset, params*) {
		if (!(IsInteger(offset) && offset >= 0)) {
			throw (ValueError(Format("{} is invalid.", Print(offset)), -1, "This parameter must be a non negative integer."))
		}

		pointer := this.Ptr

		loop (params.Length//2) {
			index := (A_Index - 1)*2
				, type := params[index], value := params[index + 1]

			if (type = "Struct") {
				if (value.__Class != "Structure") {
					throw (TypeError(Format("{} is invalid.", Print(value)), -1))
				}

				size := value.Size, limit := this.Size - offset
					, bytes := (size > limit) ? (limit) : (size)  ;* Ensure that there is capacity left after accounting for the offset. It is entirely possible to insert a type that exceeds 2 bytes in size into the last 2 bytes of this struct's memory however, thereby corrupting the value.

				if (bytes) {
					DllCall("NtDll\RtlCopyMemory", "Ptr", pointer + offset, "Ptr", value.Ptr, "Ptr", bytes), offset += bytes
				}
			}
			else {
				if (!(type ~= "i)Char|UChar|Short|UShort|Float|Int|UInt|Int64|UInt64|Ptr|UPtr")) {
					throw (ValueError(Format("{} is invalid.", Print(offset)), -1))
				}

				size := Structure.SizeOf(type), limit := this.Size - offset
					, bytes := (size > limit) ? (limit) : (size)

				if (!(bytes - size)) {
					NumPut(type, value, pointer + offset), offset += bytes
				}
			}
		}

		return (offset)  ;* Similar to `array.Push()` returning the new length.
	}

	StrGet(length := "", encoding := "") {
		if (length) {
			return (StrGet(this.Ptr, length, encoding))
		}

		return (StrGet(this.Ptr))
	}

	ZeroMemory(bytes := 0) {
		DllCall("Ntdll\RtlZeroMemory", "Ptr", this.Ptr, "Ptr", (bytes) ? ((bytes > (size := this.Size)) ? (size) : (bytes)) : (this.Size))
	}
}