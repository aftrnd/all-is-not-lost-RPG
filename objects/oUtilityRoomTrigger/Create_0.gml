/// @description Initialize Room Trigger
// This object will transport the player to another room

// These variables will be set for each instance in the room editor
// through the Variable Definitions in GameMaker
// destination_room = -1;  // Set to the target room
// destination_x = 0;      // X position in the destination room
// destination_y = 0;      // Y position in the destination room
// transition_speed = 0.05; // Speed of the fade effect
// y_offset = 0;           // Additional Y offset to apply (can be negative)
//                         // Use this to adjust for sprite origin differences
//                         // Example: If player appears too low, try y_offset of -12

// Internal flag to prevent multiple triggers
triggered = false; 