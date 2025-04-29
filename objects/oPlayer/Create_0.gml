/// @desc Player Properties
// Sets the current state of the player
state = playerStateDefault;

playerGravity = 0.25; // Global value for player's gravity. Higher is more gravity (Might make a global value)

// Player's current variables
horizontalSpeed = 0; // Current horizontal speed
verticalSpeed = 0; // Current vertical speed

// Player Properties
walkingSpeed = 1.45; // Speed the player walks
jumpSpeed = -5.0; // Speed the player moves off the ground

allowJump = 0; // Jump frame buffer

// Player's current coordinates (currently for debug ONLY)
playerX = 0;
playerY = 0;

// Debug menu
drawDebugMenu = false;

// Testing player states
spriteDefault = sPlayer;
spriteFrozen = sPlayerFrozen;