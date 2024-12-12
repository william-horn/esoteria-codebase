
return function(import, pm)
  local customEnum = import("@Util/customEnum")

  local seasons = customEnum { "Spring", "Summer", "Autumn", "Winter" };

  print(seasons.Spring);
  print(seasons.Spring.ToInt32());
  print(seasons.Winter.ToInt32())
end