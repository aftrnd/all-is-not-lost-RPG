/// @desc oPlayer - Keyboard Input
// You can write your code in this editor

#region Keyboard Bindings
keyRight = keyboard_check(vk_right);
keyLeft = keyboard_check(vk_left);
keyJump = keyboard_check_pressed(vk_space);
keyActivate = keyboard_check_pressed(ord("E")); // Generic 'Activate' key...
#endregion

// Player's Coordinates 
playerX = floor(x);
playerY = floor(y);

// Sets which state the player should be in
script_execute(state);