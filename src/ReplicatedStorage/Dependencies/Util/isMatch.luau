

return function(import)
  -- local bothAreStrings = require(script.Parent.Types.bothAreString)()
  local bothAreStrings = import("@Util/@Types/bothAreStrings")

  
  --[[
    @desc: Determine if a and b match, according to the options table.
    @param a <string>
    @param b <string>
    @param options <Table>
      caseSensitive - (default: true) whether case sensitivity is used in the comparison (true = yes)
      usePatterns - (default: false) whether pattern matching is enabled (true = yes)
      
    @returns: validMatch <boolean>
  ]]
  local function isMatch(a, b, options)
    options = options or {}

    if (options.caseSensitive == nil) then options.caseSensitive = true end
    if (options.usePatterns == nil) then options.usePatterns = false end

    if (not bothAreStrings(a, b)) then
      return a == b
    end

    if (options.caseSensitive) then
      a = a:lower()
      b = b:lower()
    end

    if (not options.usePatterns) then
      return a == b
    end

    return a:match(b) ~= nil
  end

  return isMatch
end
