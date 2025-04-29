/// @desription Keyboard Input

// Getting input from keyboard (WASD)
keyRight = keyboard_check(vk_right);
keyLeft = keyboard_check(vk_left);
keyJump = keyboard_check_pressed(vk_space);

keyActivate = keyboard_check_pressed(ord("E")); // Generic 'Activate' key... change me later (chages state currently)

// Player's coordinates - for debug ONLY 
playerX = floor(x);
playerY = floor(y);

// Sets which state the player should be in
script_execute(state);