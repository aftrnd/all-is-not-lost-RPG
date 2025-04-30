/// @desc oPlayer - Properties
// You can write your code in this editor

#region Variables
// Player's Coordinates 
playerX = 0;
playerY = 0;

// Developer Menu
drawDebugMenu = false;

// Player States
spriteDefault = sPlayer;
spriteFrozen = sPlayerFrozen;

// Define initial state
state = playerStateDefault;
#endregion

#region Properties
playerGravity = 0.25; // Global value for player's gravity. Higher is more gravity (Might make a global value)
horizontalSpeed = 0; // Current horizontal speed
verticalSpeed = 0; // Current vertical speed
walkingSpeed = 1.45; // Speed the player walks
jumpSpeed = -5.0; // Speed the player moves off the ground
allowJump = 0; // Jump frame buffer
#endregion

#region Hotbar & Player Inventory
hotbar_size = 5;
inventory_size = 10;
total_slots = hotbar_size + inventory_size;
inventory = array_create(total_slots, noone);
#endregion

#region Inventory Management
function inventory_add_item(item) {
    return inventory_add_item(item);
}
#endregion