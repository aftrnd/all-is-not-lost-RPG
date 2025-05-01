if (place_meeting(x, y, oPlayer)) {
    var p = instance_place(x, y, oPlayer);
    if (p != noone && item_name != "") {
        with (p) {
            var new_item = item_create(other.item_name, other.amount);
            var added = inventory_add_item(new_item);
            if (added) {
                // Log item pickup to debug console
                debug_log("Picked up " + string(other.amount) + "x " + other.item_name, c_fuchsia);
                instance_destroy(other);
            }
        }
    }
}