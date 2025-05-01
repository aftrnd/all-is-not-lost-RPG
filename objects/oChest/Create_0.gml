/// @desc oChest - Create Event
// You can write your code in this editor

#region Variables
is_open = false;      // is the chest open?
ui_open = false;      // is the inventory UI open?
opening = false;      // are we currently opening?
closing = false;      // are we currently closing?
frame_speed = 0.2;    // how fast the chest opens/closes
frame_pos = 0;        // current animation frame
open_distance = 25;   // how close player must be to open
inventory_size = 15;  // max chest size
inventory = array_create(inventory_size, noone);
ui_open = false; // whether UI is currently shown

// Drag and Drop Variables
dragging_item = noone;
drag_origin_index = -1;
drag_offset_x = 0;
drag_offset_y = 0;
#endregion