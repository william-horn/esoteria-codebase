# PackageManager

A light-weight package managing system that makes dependencies and other global assets readily accessible. 

Inspired by CommonJS modules.

## API

The `PackageManager` provides the following utility functions:

... Coming soon

# Import a directory


```lua
pm.import("directory")
```

* **IF** `directory` doesn't exist, then PM will throw an error.

## Directory is a Folder

If `directory` is a `Folder`, then PM will check to see if the folder contains a **ModuleScript** named `default`. 

* **IF** this `default` module **exists**, then it will be **required**. 

* **IF** this `default` module **DOES NOT** exist, then the directory instance will be returned.

**Note:** Whatever is returned inside the `default` module is exactly what the return value will be from `import` and children of `import`. This is because the default module inherently counts as the default export, so there is no need for PM to check if the return value is a table to search for a `default` field.

## Directory is a ModuleScript

If the directory is a `ModuleScript`, it will be required.

### Module returns a **function**

If the **return** value of the module is a **function**, then it is assumed to be a wrapper function for the PM environment and it will be called with PM environment variables like `import` and `global`. PM will then return whatever is returned from within the function.

### Ex:

```lua
-- inside 'module'

return function(import, global, pm) -- this gets called by PM
	return "Hello"
end
```

Calling `pm.import("module")` will result in a return value of `"Hello"`


### Module returns a **table**

**IF** what is returned from inside the function is a **table**, it is assumed to be a "package", and PM will look for a "default" export. 

### Ex:

```lua
return {
	default = ...
}
```

### `default` does not exist in the returned table
* **IF** this `default` value does **NOT** exist within the returned table, PM will throw an error. This behavior can be escaped by importing this same module with:

```lua
pm.import("module*") -- use '*' to escape default export
```

After calling the import above, `{ default = ... }` will be returned and no error will occur.

### `default` does exist in the returned table

* **IF** the default export exists in the table, then that value will be returned.

## Indexing imported tables

Assume `MyTable` is a module that returns a table. If you have an import like:

```lua
pm.import("MyTable/key")
```

Then PM will require `MyTable` and attempt to index it with `key`.

* **IF** `key` exists, then it will be returned.
* **IF** `key` does not exist, PM will throw an error

## Escaping require

If you want to path through a module without requiring it, you can use `@` before the segment name to escape the require.

### Ex:

```lua
pm.import("@MyTable/key")
```

This will escape the requiring of `MyTable` and see if it contains a `ModuleScript` called `key`.

* **IF** `key` exists, it will be required.
* **IF** `key` doesn't exist, PM will throw an error

## Wildcard selector

If you want to require all modules in a directory, you can do:

```lua
pm.import("@Folder/*")
```

`@` escapes the import of `Folder` and searches inside of it for `"*"`. Since this is a special selector, it will require all child `ModuleScripts` of `Folder` and store them in a table that maps the name of the module to it's return result.

### Ex:

Assume `Folder` is a folder that contains the following modules:

**inside module named "thing"**
```lua
return function()
	print("Hello, world!")
end
```

Calling import:

```lua
pm.import("@Folder/*").thing()
```