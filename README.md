# Structure

A structure management framework for AutoHotkey v2.*

## Functions

#### `StructureFromArray(array[, type])`
Create a structure and appends each value in an array to it.

##### Parameters
1. [Array] array: The result value computed. Objects by themselves are automatically converted to string.
2. [String] type: Data type to use when inserting a given value. Defaults to `"UInt"`.

##### Return
[Structure]: A new structure instance with a `.Ptr` property.

#### `StructureFromStructure(structs*)`
Create a structure and copies the data from each struct passed into it.

##### Parameters
1. [Structure] structs*: Any number of structure to concatenate into a new structure. The memory will be a copy, not shared.

##### Return
[Structure]: A new structure instance with a `.Ptr` property.

## Static methods

#### `Structure(bytes[, zero])`
Creates a new structure instance.

##### Parameters
1. [Integer] bytes: The size of the structure.
1. [Bool] zero: Initiate the memory with 0.

##### Return
[Structure]: A new structure instance with a `.Ptr` property.

##### Example
```autohotkey
; Create a struct of 8 bytes in size and initially filled with zeroes:
struct1 := Structure(8, 1) 
```

#### `Structure.SizeOf(type)`
Determines how many bytes `type` is in size.

##### Parameters
1. [String] type: Any number of structure to concatenate into a new structure. The memory will be a copy, not shared.

##### Return
[Integer]: The size of `type` in bytes.

## Instance properties

#### `struct.Ptr`
The pointer to the block of memory where the data owned by this struct is held.

##### Example
```autohotkey
rect := Structure(16)

DllCall("User32\GetWindowRect", "Ptr", WinExist(), "Ptr", rect.Ptr, "UInt")  ; Retrieve the bounds of the active window into the `rect` struct.
DllCall("User32\ClipCursor", "Ptr", rect.Ptr)  ; Pass the pointer to the block of memory contained in this struct to the ClipCursor function.
```

#### `struct.Size[ := bytes]`
1. Get: How many bytes belong to this structure.
2. Set: Resize the structure.

## Instance methods

#### `struct.NumGet(offset, type[, bytes])`
Retrieve a value from this struct at the given offset.

##### Arguments
1. [Integer] offset: The offset at which to start retrieving the data.
2. [String] type: The data type to retrieve.
3. [Integer] bytes: The number of bytes to copy into a structure. This only applies if `type` is `"Struct"`.

##### Return
[*]: Returns the data at the specified address or if `type` is `"Struct"`, a new instance with `bytes` of data copied into it.

##### Example
```autohotkey
struct := Structure(8)
struct.NumPut(0, "UShort", 1, "Float", 2)

MsgBox(struct.NumGet(2, "Float"))  ; Retrieve the Float (4 bytes) at offset 2 (the first byte after the UShort entry).
```

#### `struct.NumPut(offset, type, value, type, value, ...)`
Retrieve a value from this struct at the given offset.

##### Arguments
1. [Integer] offset: The offset at which to start inserting data.
2. [String] type: The data type to inserting.
3. [Any] value: `value` is inserted at `offset` and any additional `value` parameters are inserted at `offset` + the number of bytes taken up by preceding entries.

##### Return
[Integer]: The next available byte in address space after all values have been inserted.

##### Example
```autohotkey
struct := Structure(8)
struct.NumPut(0, "UShort", 1, "Float", 2)

MsgBox(struct.NumGet(2, "Float"))  ; Retrieve the Float (4 bytes) at offset 2 (the first byte after the UShort entry).
```
