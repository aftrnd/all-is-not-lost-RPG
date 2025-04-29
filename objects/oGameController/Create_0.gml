// INITIALIZE ITEMS
item_db_init()

// SIGN TEXT
global.sign_texts = ds_map_create();
ds_map_add(global.sign_texts, "greeting", "Hey, Instagram...");
ds_map_add(global.sign_texts, "greeting_02", "What's good");
ds_map_add(global.sign_texts, "warning", "Beware of the deep forest ahead...");
ds_map_add(global.sign_texts, "hint", "Press [SPACE] to jump higher!");