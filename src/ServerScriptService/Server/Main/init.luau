
return function(import, pm)
  local StringEscaper = import("@String/@Classes/StringEscaper*")
  local enums = import("../@Enums/@Network/*/NetworkRequest")
  -- local types = import("@Util/@Types/*")
  local diff = import("@Util/@Types/testType*")

  --[[
    We need to think about how to handle modules that don't return functions, mixed
    with modules that do return functions.

      If you import a module like "@Folder/Module" then "require(Folder/Module).default" is implied
      If you import a module like "@Folder/Module*" then "require(Folder/Module)" is implied

      But how does this work when importing all children using the "*" wild card?

      What should this return?

        import("@Folder/*")
  ]]

  print("String Escaper: ", StringEscaper)
  print("types: ", diff)
  print("enums", enums);
end