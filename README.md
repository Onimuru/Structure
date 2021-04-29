Structure.ahk
===========

A structure management framework for AutoHotkey.

## Usage

Grants access to a class named `Structure` with the following methods: `.SizeOf()`

and instances of `Structure` with the following methods: `.NumGet()`, `.NumPut()`, `.StrGet()`, `.StrPut()` and `.ZeroMemory()`

```autohotkey
#Include <Structure>

; Create a new structure of 8 bytes in size:
struct := new Structure(8)
struct.NumPut(0, "UInt", 69, "UInt", 96)

x := struct.NumGet(0, "UInt")
y := struct.NumGet(4, "UInt")
```

## API

### new Structure(bytes, [zeroFill])

Create a new instance that will free it's allocated memory when deleted.

##### Arguments
1. bytes (*): The number of bytes to be allocated.
2. zeroFill (boolean): Whether the allocated memory will be initialized to zero, default is `False`.

##### Returns
Returns an instance object with a `.Pointer` property that can be passed to `DllCall()`.

##### Example
```autohotkey
; Create a struct of 8 bytes in size and initially filled with zeroes:
struct1 := new Structure(8, 1) 

; Create a new struct that is a copy of `struct1` (the copy points to a new block of memory and as such can have unique values):
struct2 := new Structure(struct1)  
```

### .Pointer

Alias: `.Ptr`

Returns the pointer to the block of memory contained in this struct.

### .Size

Returns the total size of the block of memory contained in this struct.

### .NumGet(offset, type, bytes)

Retrieve a value from this struct at the given offset.

##### Arguments
1. offset (*): 
2. type (*): The data type to retrieve.

##### Returns
Returns the data at the specified address.

##### Example
```autohotkey
struct := new Structure(8)
struct.NumPut(0, "UShort", 1, "Float", 2)

MsgBox, % struct.NumGet(2, "Float")  ; Retrieve the Float (4 bytes) at offset 2 (the first byte after the UShort entry).
```

### .NumPut(offset, type, value, type, value, ...)

Insert any number of values into this struct but not exceeding the size allocated when it was created.

##### Arguments
1. offset (*): The offset at which the first entry will be inserted.
2. value (*): The value to insert.

##### Returns
Returns the next byte in this struct after all values have been added.

##### Example
```autohotkey
struct := new Structure(12 + A_PtrSize)  ; A_PtrSize = 8 on 64-bit and 4 on 32-bit.
struct.NumPut(0, "Int", 1, "Int", 2, "Int", 3)

struct.NumPut(8, "Float", 3.14159, "Ptr", A_ScriptHwnd)  ; Overwrite the value at offset 8 and insert a handle at offset 12.
```
