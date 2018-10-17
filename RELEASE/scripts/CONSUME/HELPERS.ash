import <CONSUME/RECORDS.ash>
import <CONSUME/CONSTANTS.ash>

// get the pure adventure value of the item itself, raw
Range get_adventures(item it)
{
	string [int] adv_strs = split_string(it.adventures, "-");
	Range r;
	r.min = adv_strs[0].to_int();
	r.max = adv_strs[(adv_strs.count() > 1) ? 1 : 0].to_int();
	return r;
}

item get_fork_mug(Consumable c)
{
	switch(c.organ)
	{
		case ORGAN_STOMACHE: return $item[ol' scratch's salad fork];
		case ORGAN_LIVER: return $item[frosty's frosty mug];
		default: return $item[none];
	}
}

boolean care_about_ingredients(item it)
{
	// TODO: Care about wads if you have malus access
	boolean [item] dontCare = $items[
		flat dough,
		wad of dough,
		hacked gibson,
		browser cookie,
		hot wad,
		cold wad,
		spooky wad,
		sleaze wad,
		stench wad,
	];
	return !(dontCare contains it);
}

int item_price(item it)
{
	int price = it.mall_price();
	if(price < 100) // mall min is 100
		price = npc_price(it);
	if(price == 0) // not for sale in mall or npc stores...
		price = MAX_MEAT;

	if(it.care_about_ingredients())
	{
		int [item] ingredients = get_ingredients(it);
		if(ingredients.count() > 0)
		{
			int ingredientsPrice = 0;
			foreach ingredient,amount in ingredients
			{
				ingredientsPrice += amount * item_price(ingredient);
			}
			if(ingredientsPrice < price)
				price = ingredientsPrice;
		}
	}

	return price;
}
