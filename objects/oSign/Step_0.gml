/// @desc oSign - Step Event

#region Player Interaction
if (place_meeting(x, y, oPlayer)) {
    // Player is touching the sign
    if (keyboard_check_pressed(vk_enter)) {
        if (!show_textbox) {
            show_textbox = true;

            if (is_undefined(global.sign_texts)) {
                text_full = "[Error: map not initialized]";
            } else if (ds_map_exists(global.sign_texts, text_id)) {
                text_full = global.sign_texts[? text_id];
            } else {
                text_full = "[Missing text ID: " + text_id + "]";
            }

            text_displayed = "";
            char_index = 0;
            text_timer = 0;
            
            // Log sign interaction to debug console
            var p = instance_nearest(x, y, oPlayer);
            if (p != noone) {
                with (p) {
                    debug_log("Sign read: " + other.text_id, c_orange);
                }
            }
        }
        else if (char_index < string_length(text_full)) {
            char_index = string_length(text_full);
            text_displayed = text_full;
        }
        else {
            show_textbox = false;
            
            // Log when sign reading is finished
            var p = instance_nearest(x, y, oPlayer);
            if (p != noone) {
                with (p) {
                    debug_log("Finished reading sign: " + other.text_id, c_orange);
                }
            }
        }
    }
}
else {
    // Player walked away from the sign
    if (show_textbox) {
        show_textbox = false;
        
        // Log when sign reading is interrupted by walking away
        var p = instance_nearest(x, y, oPlayer);
        if (p != noone) {
            with (p) {
                debug_log("Interrupted sign reading: " + other.text_id, c_red);
            }
        }
    }
}
#endregion

#region Typing Effect
if (show_textbox) {
    text_timer += 1;

    if (text_timer >= text_speed) {
        text_timer = 0;

        if (char_index < string_length(text_full)) {
            char_index += 1;
            text_displayed = string_copy(text_full, 1, char_index);
        }
    }
}
#endregion