/// @description Insert description here
// You can write your code in this editor

var backgroundBase = layer_get_id("BackgroundBase");
var backgroundClouds = layer_get_id("BackgroundClouds");
var backgroundMountain_2 = layer_get_id("BackgroundMountain_2");
var backgroundMountain_1 = layer_get_id("BackgroundMountain_1");
var backgroundMountain = layer_get_id("BackgroundMountain");

layer_x (backgroundBase, lerp(0, camera_get_view_x(view_camera[0]), 0));
layer_x (backgroundMountain_2, lerp(0, camera_get_view_x(view_camera[0]), -0.07));
layer_x (backgroundMountain_1, lerp(0, camera_get_view_x(view_camera[0]), -0.09));
layer_x (backgroundMountain, lerp(0, camera_get_view_x(view_camera[0]), -0.1));