
CarTweaks = _G['CarTweaks'] or {}

CarTweaks.addRecipeToMagazine = function()
  local recipe = "Make Spare Engine Parts";
  local mag = instanceItem("Base.MetalworkMag4");
  local teachedRecipes = mag:getTeachedRecipes();
  teachedRecipes:add(recipe);
  mag:setTeachedRecipes(teachedRecipes);
end

CarTweaks.addRecipeToMagazine();