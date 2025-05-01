function chest_add_item(_item) {
    for (var i = 0; i < array_length(inventory); i++) {
        var slot = inventory[i];
        if (is_struct(slot) && slot.name == _item.name) {
            var max_stack = slot.data.max_stack;
            var available = max_stack - slot.count;

            if (available > 0) {
                var to_add = min(_item.count, available);
                slot.count += to_add;
                _item.count -= to_add;
                if (_item.count <= 0) return true;
            }
        }
    }

    for (var i = 0; i < array_length(inventory); i++) {
        if (inventory[i] == noone) {
            inventory[i] = item_create(_item.name, _item.count);
            return true;
        }
    }

    return false;
}