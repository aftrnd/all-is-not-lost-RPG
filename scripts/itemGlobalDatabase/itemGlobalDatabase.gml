function item_db_init() {
    global.item_data = ds_map_create();

    global.item_data[? "apple"] = {
        name: "apple",
        category: "consumable",
        max_stack: 10,
        icon: sApple,
        description: "Restores a bit of health."
    };

    global.item_data[? "sword"] = {
        name: "sword",
        category: "weapon",
        max_stack: 1,
        icon: sSword,
        damage: 5,
        description: "A basic sword."
    };
}