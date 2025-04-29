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
        }
        else if (char_index < string_length(text_full)) {
            char_index = string_length(text_full);
            text_displayed = text_full;
        }
        else {
            show_textbox = false;
        }
    }
}
else {
    // Player is no longer touching the sign
    if (show_textbox) {
        show_textbox = false;
    }
}

// Typing effect
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