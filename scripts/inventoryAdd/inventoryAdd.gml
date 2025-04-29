/// @desc Tries to stack or add an item to inventory
/// @param _item (struct with name/count)

function inventory_add_item(_item) {
    // Try stacking
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

    // Try placing in empty slot
    for (var i = 0; i < array_length(inventory); i++) {
        if (inventory[i] == noone) {
            inventory[i] = item_create(_item.name, _item.count);
            return true;
        }
    }

    return false;
}