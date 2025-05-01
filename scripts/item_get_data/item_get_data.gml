function item_get_data(_name) {
    if (ds_map_exists(global.item_data, _name)) {
        return global.item_data[? _name];
    }
    return undefined;
}