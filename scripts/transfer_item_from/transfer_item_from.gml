/// @desc Transfers one item from source inventory to target inventory
/// @param _source      // The instance with the inventory to take from
/// @param _target      // The instance with the inventory to send to
/// @param _slot_index  // Index in source inventory to transfer from

function transfer_item_from(_source, _target, _slot_index) {
    var item = _source.inventory[_slot_index];

    if (item == noone) return false; // nothing to transfer

    var added = false;

    with (_target) {
        added = inventory_add_item(item); // assumes this function is defined globally
    }

    if (added) {
        _source.inventory[_slot_index] = noone;
        return true;
    }

    return false; // target full
}