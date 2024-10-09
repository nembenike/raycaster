module main

import irishgreencitrus.raylibv as r
import math

const screen_width = 800
const screen_height = 450
const move_speed = 0.05  // movement speed
const rot_speed = 0.03   // rotation speed

// RAYLIB KEYCODES
const key_w = 87
const key_s = 83
const key_a = 65
const key_d = 68
const key_left = 263
const key_right = 262

struct Player {
mut:
    x f32 = 5.0       // pos
    y f32 = 2.0       // pos
    dir_x f32 = -1.0  // dir
    dir_y f32 = 0.0   // dir
    plane_x f32 = 0.0 // camera plane
    plane_y f32 = 0.66 // camera plane
}

@[heap]
struct GameMap {
pub:
    width int = 10
    height int = 10
    grid [][]int = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 1, 1, 1, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ]
}

fn handle_input(mut player Player, game_map GameMap) {
	// MOVEMENT

    if r.is_key_down(key_w) {
        new_x := player.x + player.dir_x * move_speed
        new_y := player.y + player.dir_y * move_speed
        if game_map.grid[int(new_x)][int(player.y)] == 0 {
            player.x = new_x
        }
        if game_map.grid[int(player.x)][int(new_y)] == 0 {
            player.y = new_y
        }
    }
    
    if r.is_key_down(key_s) {
        new_x := player.x - player.dir_x * move_speed
        new_y := player.y - player.dir_y * move_speed
        if game_map.grid[int(new_x)][int(player.y)] == 0 {
            player.x = new_x
        }
        if game_map.grid[int(player.x)][int(new_y)] == 0 {
            player.y = new_y
        }
    }
    
    if r.is_key_down(key_a) {
        new_x := player.x - player.plane_x * move_speed
        new_y := player.y - player.plane_y * move_speed
        if game_map.grid[int(new_x)][int(player.y)] == 0 {
            player.x = new_x
        }
        if game_map.grid[int(player.x)][int(new_y)] == 0 {
            player.y = new_y
        }
    }
    
    if r.is_key_down(key_d) {
        new_x := player.x + player.plane_x * move_speed
        new_y := player.y + player.plane_y * move_speed
        if game_map.grid[int(new_x)][int(player.y)] == 0 {
            player.x = new_x
        }
        if game_map.grid[int(player.x)][int(new_y)] == 0 {
            player.y = new_y
        }
    }

	// ROTATION
    
	if r.is_key_down(key_right) {
		old_dir_x := player.dir_x
		player.dir_x = f32(player.dir_x * f32(math.cos(-rot_speed)) - player.dir_y * f32(math.sin(-rot_speed)))
		player.dir_y = f32(old_dir_x * f32(math.sin(-rot_speed)) + player.dir_y * f32(math.cos(-rot_speed)))
		old_plane_x := player.plane_x
		player.plane_x = f32(player.plane_x * f32(math.cos(-rot_speed)) - player.plane_y * f32(math.sin(-rot_speed)))
		player.plane_y = f32(old_plane_x * f32(math.sin(-rot_speed)) + player.plane_y * f32(math.cos(-rot_speed)))
	}

	if r.is_key_down(key_left) {
		old_dir_x := player.dir_x
		player.dir_x = f32(player.dir_x * f32(math.cos(rot_speed)) - player.dir_y * f32(math.sin(rot_speed)))
		player.dir_y = f32(old_dir_x * f32(math.sin(rot_speed)) + player.dir_y * f32(math.cos(rot_speed)))
		old_plane_x := player.plane_x
		player.plane_x = f32(player.plane_x * f32(math.cos(rot_speed)) - player.plane_y * f32(math.sin(rot_speed)))
		player.plane_y = f32(old_plane_x * f32(math.sin(rot_speed)) + player.plane_y * f32(math.cos(rot_speed)))
	}
}

fn main() {
    mut player := Player{}
    game_map := GameMap{}
    
    r.init_window(screen_width, screen_height, 'Raycasting'.str)
    r.set_target_fps(60)

    for !r.window_should_close() {
        // INPUT HANDLING
        handle_input(mut player, game_map)
        
        r.begin_drawing()
        // DRAW CEILING
        r.draw_rectangle(0, 0, screen_width, screen_height/2, r.Color{135, 206, 235, 255})
        // DRAW FLOOR
        r.draw_rectangle(0, screen_height/2, screen_width, screen_height/2, r.Color{100, 100, 100, 255})
        
        draw_rays(player, game_map)

        // DRAW DEBUG
        r.draw_text('Player pos: ${player.x:.1f}, ${player.y:.1f}'.str, 10, 10, 20, r.Color{255, 255, 255, 255})
        r.draw_text('Player dir: ${player.dir_x:.1f}, ${player.dir_y:.1f}'.str, 10, 30, 20, r.Color{255, 255, 255, 255})
        
        r.end_drawing()
    }
    r.close_window()
}

fn draw_rays(player Player, game_map GameMap) {
    for x in 0 .. screen_width {
        // CALCULATE RAY POSITION AND DIRECTION
        camera_x := 2.0 * f32(x) / f32(screen_width) - 1.0
        ray_dir_x := player.dir_x + player.plane_x * camera_x
        ray_dir_y := player.dir_y + player.plane_y * camera_x

        // CHECK BOX OF MAP PLAYER IS IN
        mut map_x := int(player.x)
        mut map_y := int(player.y)

        // LENGTH OF RAY FROM CURRENT POSITION TO NEXT X OR Y SIDE
        delta_dist_x := if ray_dir_x == 0 { 1e30 } else { math.abs(1.0 / ray_dir_x) }
        delta_dist_y := if ray_dir_y == 0 { 1e30 } else { math.abs(1.0 / ray_dir_y) }

        // CALCULATE STEP AND INITIAL SIDE DISTANCE
        mut step_x := if ray_dir_x < 0 { -1 } else { 1 }
        mut step_y := if ray_dir_y < 0 { -1 } else { 1 }
        
        mut side_dist_x := if ray_dir_x < 0 {
            (player.x - f32(map_x)) * delta_dist_x
        } else {
            (f32(map_x) + 1.0 - player.x) * delta_dist_x
        }
        
        mut side_dist_y := if ray_dir_y < 0 {
            (player.y - f32(map_y)) * delta_dist_y
        } else {
            (f32(map_y) + 1.0 - player.y) * delta_dist_y
        }

        // PERFORM DDA
        mut hit := 0
        mut side := 0
        for hit == 0 {
            if side_dist_x < side_dist_y {
                side_dist_x += delta_dist_x
                map_x += step_x
                side = 0
            } else {
                side_dist_y += delta_dist_y
                map_y += step_y
                side = 1
            }
            
            if map_x >= 0 && map_y >= 0 && map_x < game_map.width && map_y < game_map.height {
                if game_map.grid[map_x][map_y] > 0 {
                    hit = 1
                }
            }
        }

        // CALCULATE DISTANCE TO WALL
        perp_wall_dist := if side == 0 {
            (f32(map_x) - player.x + (1.0 - f32(step_x)) / 2.0) / ray_dir_x
        } else {
            (f32(map_y) - player.y + (1.0 - f32(step_y)) / 2.0) / ray_dir_y
        }

        // CALCULATE WALL HEIGHT
        line_height := int(screen_height / (perp_wall_dist + 0.00001))
        
        // CALCULATE LOWEST AND HIGHEST PIXEL TO FILL IN CURRENT STRIPE
        mut draw_start := -line_height / 2 + screen_height / 2
        if draw_start < 0 {
            draw_start = 0
        }
        
        mut draw_end := line_height / 2 + screen_height / 2
        if draw_end >= screen_height {
            draw_end = screen_height - 1
        }

        // CHOOSE WALL COLOR
        color := if side == 0 { 
            r.Color{200, 0, 0, 255}  // DARK RED FOR VERTICAL WALLSD
        } else { 
            r.Color{150, 0, 0, 255}  // EVEN DARGER RED FOR HORIZONTAL WALLS
        }
        
        // DRAW THE LINE
        r.draw_line(x, draw_start, x, draw_end, color)
    }
}