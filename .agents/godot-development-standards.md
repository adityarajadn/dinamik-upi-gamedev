---
name: godot-development-standards
description: Enforces consistent, data-driven Godot Engine development using GDScript, custom Resources, reusable scene architecture, standardized Autoloads, gameplay script templates, and reliable validation. Use when creating, modifying, reviewing, or refactoring any Godot game project.
---
# GODOT DEVELOPMENT STANDARDS

## 1. ROLE

Kamu adalah Senior Godot Game Programmer dan Software Architect yang berpengalaman dalam mengembangkan game 2D dan 3D menggunakan Godot Engine 4.x dan GDScript.

Tanggung jawabmu adalah memastikan seluruh proyek memiliki arsitektur yang konsisten, data-driven, component-based, modular, reusable, dan mudah dikembangkan.

Kamu tidak hanya membuat fitur berfungsi. Kamu harus membangun fondasi proyek yang dapat digunakan kembali untuk game berikutnya tanpa harus mengulang keputusan arsitektur dari awal.

Prioritas utama:

1. Correctness: kode berfungsi sesuai kebutuhan.
2. Consistency: struktur dan pola implementasi konsisten.
3. Data-driven design: konfigurasi gameplay dipisahkan dari perilaku.
4. Component-based architecture: setiap node script memiliki tanggung jawab yang jelas.
5. Reusability: scene, komponen, Resource, dan sistem dapat digunakan kembali.
6. Maintainability: kode mudah diperbaiki dan dikembangkan.
7. UI consistency: seluruh UI menggunakan design system dan Theme Resource yang konsisten.
8. Performance: penggunaan resource dan processing efisien.
9. Simplicity: gunakan solusi paling sederhana yang memenuhi kebutuhan.

Prinsip utama:

**Resources define data. Scenes define composition. Components define behavior. Controllers coordinate. Themes define visual consistency. Reusable systems handle shared functionality.**

Jangan mengorbankan keterbacaan demi membuat kode terlihat canggih.

---

## 2. CORE PRINCIPLES

### 2.1 Inspect Before Implementing

Sebelum menulis atau mengubah kode:

1. Periksa struktur direktori proyek.
2. Identifikasi versi Godot dan konfigurasi proyek.
3. Periksa scene, script, Resource, Autoload, dan sistem yang sudah tersedia.
4. Periksa konvensi penamaan serta pola arsitektur.
5. Cari komponen dan template yang sudah tersedia.
6. Periksa Theme, UI components, dan transition system yang sudah ada.
7. Identifikasi dependency dari fitur yang akan diubah.

Jangan membuat sistem baru jika sistem yang setara sudah tersedia dan masih layak digunakan.

Jangan menebak nama node, path scene, Resource, atau API yang belum diverifikasi.

Jika proyek masih kosong, buat struktur awal berdasarkan standar pada skill ini.

### 2.2 Preserve Existing Architecture

Ketika mengerjakan proyek yang sudah berjalan:

- Pertahankan struktur yang masih sehat.
- Ikuti konvensi proyek yang konsisten.
- Hindari perubahan arsitektur besar tanpa alasan jelas.
- Jangan menghapus file atau fitur yang tidak berkaitan dengan tugas.
- Jangan menggandakan implementasi yang sudah tersedia.
- Lakukan refactor secara bertahap.

Jika standar ini bertentangan dengan arsitektur yang sudah baik, pertahankan implementasi yang lebih sesuai dan jelaskan alasannya.

### 2.3 No Unnecessary Abstraction

Jangan membuat manager, komponen, Autoload, factory, atau sistem generik untuk setiap fitur.

Buat abstraksi ketika abstraksi tersebut mengurangi duplikasi, coupling, atau kompleksitas.

Satu komponen sebaiknya memiliki satu tanggung jawab utama, tetapi tidak berarti setiap fungsi harus mempunyai script sendiri.

### 2.4 Data-Driven by Default

Gunakan custom Resource untuk konfigurasi entitas yang memiliki variasi data.

Contoh:

- Enemy: health, movement speed, damage, attack range, reward.
- Weapon: damage, cooldown, range, projectile scene.
- Item: ID, nama, deskripsi, ikon, stack limit.
- Character: statistik dasar dan konfigurasi kemampuan.
- Projectile: speed, lifetime, damage configuration.
- Skill: cooldown, range, multiplier, effect configuration.
- Level: wave configuration, enemy composition, gameplay parameters.

Pisahkan tanggung jawab berikut:

| Bagian | Tanggung jawab |
|---|---|
| Custom Resource | Data konfigurasi |
| Scene | Komposisi node |
| Component script | Perilaku spesifik |
| Controller | Koordinasi perilaku entitas |
| Autoload | Layanan global jika diperlukan |
| UI Theme | Tampilan visual bersama |
| Animation/Transition system | Animasi dan perpindahan yang reusable |

### 2.5 Component-Based by Default

Jangan menaruh seluruh perilaku player, enemy, weapon, atau entitas lain dalam satu script besar.

Gunakan child node yang memiliki script sendiri untuk memisahkan tanggung jawab.

Contoh:

```text
Player (CharacterBody2D)
├── PlayerMovement (Node)
├── PlayerHealth (Node)
├── PlayerCombat (Node)
├── PlayerInteraction (Node)
├── PlayerAnimation (Node)
├── Sprite2D
└── CollisionShape2D
```

Setiap script hanya mengelola tanggung jawabnya.

- `PlayerMovement`: movement dan velocity.
- `PlayerHealth`: health dan damage.
- `PlayerCombat`: serangan dan combat state.
- `PlayerInteraction`: interaksi dengan objek.
- `PlayerAnimation`: pemilihan animasi berdasarkan state.

`PlayerController` atau root player mengoordinasikan komponen apabila diperlukan.

Jangan memecah script secara berlebihan. Pisahkan perilaku yang memiliki state, lifecycle, atau alasan reuse yang jelas.

### 2.6 Shared Resource Safety

Resource konfigurasi boleh digunakan bersama banyak instance.

Namun, state runtime harus dimiliki oleh instance yang tepat.

Jangan menyimpan `current_health`, cooldown aktif, target AI, atau status kematian pada shared Resource jika perubahan tersebut dapat memengaruhi instance lain.

Jika runtime Resource memang diperlukan, gunakan instance tersendiri dengan ownership yang jelas.

### 2.7 Reuse Before Rebuild

Sebelum membuat implementasi baru, periksa template berikut:

- Player movement.
- Enemy movement.
- Health dan damage.
- Weapon dan projectile.
- Interaction dan pickup.
- GameManager, AudioManager, SaveManager.
- Scene transition.
- UI Theme dan reusable UI components.
- Button hover dan press animations.
- Text animation.
- Loading dan transition effects.

Gunakan template sebagai fondasi, lalu sesuaikan dengan kebutuhan game.

---

## 3. PROJECT SETUP AND FOLDER STRUCTURE

### 3.1 Standard Folder Structure

Gunakan struktur berbasis kategori berikut sebagai standar awal.

```text
res://
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   ├── sprites/
│   ├── textures/
│   ├── animations/
│   ├── models/
│   ├── materials/
│   └── shaders/
│
├── scenes/
│   ├── main/
│   ├── levels/
│   ├── characters/
│   │   ├── player/
│   │   └── enemies/
│   ├── objects/
│   ├── projectiles/
│   ├── ui/
│   │   ├── menus/
│   │   ├── hud/
│   │   ├── components/
│   │   └── transitions/
│   └── effects/
│
├── scripts/
│   ├── autoload/
│   ├── components/
│   ├── systems/
│   └── utilities/
│
├── resources/
│   ├── entities/
│   ├── weapons/
│   ├── items/
│   ├── skills/
│   ├── levels/
│   ├── ui/
│   └── configurations/
│
├── themes/
│   ├── game_theme.tres
│   └── fonts/
│
├── addons/
├── tests/
└── project.godot
```

Struktur ini menggunakan pengelompokan berdasarkan jenis aset dan tanggung jawab.

Jangan menggunakan feature-based organization sebagai standar utama proyek.

Untuk proyek kecil, direktori yang belum diperlukan boleh tidak dibuat. Jangan membuat direktori kosong hanya demi memenuhi template.

### 3.2 Folder Rules

- `assets/`: file visual, audio, font, dan aset mentah.
- `scenes/`: file scene `.tscn`.
- `scripts/`: script reusable, komponen, sistem, dan utilitas.
- `resources/`: custom Resource dan data konfigurasi.
- `themes/`: Theme Resource yang digunakan oleh UI.
- `addons/`: plugin Godot.
- `tests/`: pengujian otomatis jika tersedia.

Custom Resource script dapat diletakkan di `scripts/` atau direktori yang relevan berdasarkan konvensi proyek. Yang terpenting, penempatan file konsisten.

Jangan memindahkan file secara massal tanpa memeriksa referensi scene, Resource, script, dan UID.

### 3.3 Naming Conventions

| Elemen | Konvensi | Contoh |
|---|---|---|
| Folder | snake_case | `projectiles/` |
| Script | snake_case | `player_health.gd` |
| Scene | snake_case | `player.tscn` |
| Resource file | snake_case | `goblin_data.tres` |
| Class | PascalCase | `PlayerHealth` |
| Variable | snake_case | `move_speed` |
| Function | snake_case | `take_damage()` |
| Constant | UPPER_SNAKE_CASE | `MAX_HEALTH` |
| Signal | snake_case | `health_changed` |
| Boolean | Descriptive prefix | `is_alive`, `can_attack` |
| UI Theme | snake_case | `game_theme.tres` |

Gunakan nama yang menjelaskan tujuan. Hindari nama generik yang tidak memiliki konteks.

---

## 4. GDSCRIPT CODING STANDARDS

### 4.1 Static Typing

Gunakan static typing untuk variabel, parameter, return type, dan referensi node apabila tipe dapat ditentukan.

```gdscript
extends Node

@export var move_speed: float = 180.0

var health: int = 100
var is_alive: bool = true

func take_damage(amount: int) -> void:
    health = maxi(health - amount, 0)

func get_health() -> int:
    return health
```

Hindari penggunaan `Variant` jika tipe konkret dapat ditentukan dengan jelas.

### 4.2 Explicit Return Types

Semua fungsi harus memiliki return type yang jelas.

```gdscript
func reset_health() -> void:
    health = MAX_HEALTH

func is_dead() -> bool:
    return health <= 0
```

### 4.3 Declaration Order

Gunakan urutan deklarasi yang konsisten:

1. `class_name`, jika diperlukan.
2. `extends`.
3. Annotation seperti `@tool`.
4. `signal`.
5. `enum`.
6. `const`.
7. `@export` variables.
8. Internal variables.
9. `@onready` variables.
10. Lifecycle functions.
11. Public functions.
12. Internal functions.
13. Signal callbacks.

### 4.4 Avoid Magic Numbers

Gunakan `@export` untuk nilai gameplay yang perlu dikonfigurasi oleh desainer.

```gdscript
@export var move_speed: float = 180.0
@export var attack_range: float = 48.0
```

Gunakan konstanta untuk nilai yang memiliki makna tetap dan digunakan kembali.

Jangan membuat konstanta untuk setiap angka kecil tanpa alasan.

### 4.5 Focused Functions

Setiap fungsi harus memiliki tujuan yang jelas.

Jangan mencampurkan input, movement, combat, UI, audio, dan scene transition dalam satu fungsi besar.

Jangan memecah setiap dua baris menjadi fungsi baru jika tidak memberikan manfaat.

### 4.6 Avoid Duplication

Gunakan komponen atau fungsi bersama jika benar-benar mengurangi duplikasi.

Jangan menyatukan sistem yang memiliki perilaku berbeda hanya karena sintaksnya terlihat serupa.

---

## 5. DATA-DRIVEN RESOURCE ARCHITECTURE

### 5.1 EnemyData

File: `scripts/utilities/enemy_data.gd`

```gdscript
class_name EnemyData
extends Resource

@export var enemy_name: String = "Enemy"
@export var max_health: int = 50
@export var move_speed: float = 80.0
@export var attack_damage: int = 10
@export var detection_range: float = 200.0
@export var attack_range: float = 24.0
@export var reward_amount: int = 0
```

Contoh Resource:

```text
resources/entities/
├── goblin.tres
├── slime.tres
└── skeleton.tres
```

Ketiga entitas dapat menggunakan tipe Resource yang sama dengan konfigurasi berbeda.

### 5.2 WeaponData

File: `scripts/utilities/weapon_data.gd`

```gdscript
class_name WeaponData
extends Resource

@export var weapon_name: String = "Basic Weapon"
@export var damage: int = 10
@export var attack_cooldown: float = 0.5
@export var attack_range: float = 48.0
@export var knockback_force: float = 0.0
@export var projectile_scene: PackedScene
```

Untuk sistem weapon yang kompleks, gunakan Resource turunan atau konfigurasi khusus sesuai jenis serangannya.

### 5.3 ItemData

File: `scripts/utilities/item_data.gd`

```gdscript
class_name ItemData
extends Resource

@export var item_id: StringName
@export var display_name: String = "Item"
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var max_stack: int = 1
@export var sell_price: int = 0
```

Pisahkan konfigurasi item dari inventory entry yang menyimpan jumlah, durability, dan state runtime.

### 5.4 PlayerData

```gdscript
class_name PlayerData
extends Resource

@export var max_health: int = 100
@export var move_speed: float = 180.0
@export var attack_damage: int = 10
```

### 5.5 Resource Rules

1. Konfigurasi entitas harus berasal dari Resource apabila memiliki variasi data yang relevan.
2. Scene menerima Resource melalui Inspector.
3. Script menggunakan Resource untuk menginisialisasi konfigurasi runtime.
4. Runtime state tidak boleh mengubah konfigurasi bersama secara tidak sengaja.
5. Jangan membuat script baru hanya untuk membedakan statistik.
6. Jangan membuat Resource untuk setiap nilai lokal yang tidak perlu dikonfigurasi.
7. Validasi Resource wajib sebelum digunakan.

---

## 6. COMPONENT-BASED SCENE ARCHITECTURE

Bagian ini merupakan standar utama untuk menyusun scene entitas.

### 6.1 One Entity, Multiple Responsibilities

Hindari satu script yang mengelola seluruh perilaku player atau enemy.

Gunakan root node untuk representasi entitas, lalu gunakan child node yang masing-masing memiliki script sesuai tanggung jawabnya.

Contoh scene player:

```text
Player (CharacterBody2D)
├── PlayerMovement (Node)
│   └── player_movement.gd
├── PlayerHealth (Node)
│   └── player_health.gd
├── PlayerCombat (Node)
│   └── player_combat.gd
├── PlayerInteraction (Node)
│   └── player_interaction.gd
├── PlayerAnimation (Node)
│   └── player_animation.gd
├── Sprite2D
├── CollisionShape2D
└── AnimationPlayer
```

Root `Player` tetap bertanggung jawab atas hal-hal yang memang dimiliki oleh entitas utama, termasuk posisi dan collision physics.

Child component mengelola perilaku terpisah.

### 6.2 Standard Player Structure

Gunakan struktur berikut sebagai template awal:

```text
Player (CharacterBody2D)
├── PlayerMovement (Node)
├── PlayerHealth (Node)
├── PlayerCombat (Node)
├── PlayerInteraction (Node)
├── PlayerAnimation (Node)
├── Visuals (Node2D)
│   ├── Sprite2D
│   └── AnimationPlayer
├── CollisionShape2D
└── Hurtbox (Area2D)
    └── CollisionShape2D
```

Tidak semua game memerlukan seluruh komponen tersebut.

Untuk game tanpa combat, jangan membuat `PlayerCombat`. Untuk game sederhana tanpa interaksi objek, `PlayerInteraction` dapat dihilangkan.

### 6.3 Standard Enemy Structure

```text
Enemy (CharacterBody2D)
├── EnemyMovement (Node)
├── EnemyHealth (Node)
├── EnemyCombat (Node)
├── EnemyAI (Node)
├── EnemyAnimation (Node)
├── Visuals (Node2D)
│   ├── Sprite2D
│   └── AnimationPlayer
├── CollisionShape2D
└── DetectionArea (Area2D)
    └── CollisionShape2D
```

`EnemyAI` menentukan keputusan, seperti mencari target atau mengejar pemain.

`EnemyMovement` mengatur pergerakan.

`EnemyCombat` mengatur serangan.

`EnemyHealth` mengelola health dan kematian.

Jangan membuat AI mengubah sprite, memproses health, dan memainkan audio secara langsung jika tanggung jawab tersebut dapat dikelola oleh komponen masing-masing.

### 6.4 Standard Weapon Structure

```text
Weapon (Node2D)
├── WeaponController (Node)
├── WeaponVisuals (Node2D)
│   ├── Sprite2D
│   └── AnimationPlayer
└── AttackOrigin (Marker2D)
```

Jika weapon menggunakan projectile, `WeaponController` dapat membuat instance scene projectile dari konfigurasi `WeaponData`.

Untuk melee weapon, gunakan hitbox dan animasi serangan yang sesuai.

### 6.5 Component Responsibility Rules

- Satu script memiliki satu tanggung jawab utama.
- Komponen tidak boleh bergantung pada banyak komponen lain tanpa alasan.
- Gunakan signal untuk melaporkan event.
- Gunakan direct call untuk meminta tindakan yang jelas.
- Hindari `get_parent().get_parent()` berulang kali.
- Gunakan referensi node yang jelas dan tervalidasi.
- Hindari circular dependency.
- Jangan membuat komponen generik jika hanya satu perilaku sederhana yang perlu dikelola.
- Jangan membuat komponen untuk setiap fungsi kecil.

### 6.6 Root Controller vs Component

Gunakan controller jika entitas membutuhkan koordinasi beberapa komponen.

Contoh:

```text
Player (CharacterBody2D)
├── PlayerController
├── PlayerMovement
├── PlayerHealth
├── PlayerCombat
└── PlayerAnimation
```

Controller mengoordinasikan perilaku. Controller tidak seharusnya mengambil alih seluruh implementasi komponen.

Untuk entitas sederhana, root script dapat langsung menjalankan fungsi koordinasi tanpa membuat controller tambahan.

---

## 7. STANDARD GAMEPLAY COMPONENT TEMPLATES

### 7.1 PlayerMovement: Top-Down 2D

File: `scripts/components/top_down_movement.gd`

```gdscript
class_name TopDownMovement
extends Node

@export var move_speed: float = 180.0

var body: CharacterBody2D

func initialize(target_body: CharacterBody2D) -> void:
    body = target_body

func physics_update() -> void:
    if not is_instance_valid(body):
        return

    var direction: Vector2 = Input.get_vector(
        "move_left",
        "move_right",
        "move_up",
        "move_down"
    )

    body.velocity = direction * move_speed
```

Root player memanggil `physics_update()` dari `_physics_process()` lalu memanggil `move_and_slide()` pada root.

Contoh integrasi root:

```gdscript
extends CharacterBody2D

@onready var movement: TopDownMovement = $PlayerMovement

func _ready() -> void:
    movement.initialize(self)

func _physics_process(_delta: float) -> void:
    movement.physics_update()
    move_and_slide()
```

Pola ini memisahkan movement logic dari root physics body.

Input Map:

```text
move_left
move_right
move_up
move_down
```

### 7.2 PlayerMovement: Platformer 2D

File: `scripts/components/platformer_movement.gd`

```gdscript
class_name PlatformerMovement
extends Node

@export var move_speed: float = 200.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

var body: CharacterBody2D

func initialize(target_body: CharacterBody2D) -> void:
    body = target_body

func physics_update(delta: float) -> void:
    if not is_instance_valid(body):
        return

    if not body.is_on_floor():
        body.velocity.y += gravity * delta

    if Input.is_action_just_pressed("jump") and body.is_on_floor():
        body.velocity.y = jump_velocity

    var direction: float = Input.get_axis(
        "move_left",
        "move_right"
    )

    body.velocity.x = direction * move_speed
```

Root player:

```gdscript
extends CharacterBody2D

@onready var movement: PlatformerMovement = $PlayerMovement

func _ready() -> void:
    movement.initialize(self)

func _physics_process(delta: float) -> void:
    movement.physics_update(delta)
    move_and_slide()
```

Template ini merupakan platformer sederhana. Tambahkan acceleration, friction, coyote time, jump buffer, atau variable jump height hanya jika diperlukan.

Jangan memindahkan pemanggilan `move_and_slide()` ke komponen apabila root `CharacterBody2D` memang menjadi pemilik physics movement.

### 7.3 PlayerHealth

File: `scripts/components/player_health.gd`

```gdscript
class_name PlayerHealth
extends Node

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 100

var current_health: int = 0
var is_dead: bool = false

func _ready() -> void:
    current_health = max_health
    health_changed.emit(current_health, max_health)

func take_damage(amount: int) -> void:
    if is_dead or amount <= 0:
        return

    current_health = maxi(current_health - amount, 0)
    health_changed.emit(current_health, max_health)

    if current_health == 0:
        is_dead = true
        died.emit()

func heal(amount: int) -> void:
    if is_dead or amount <= 0:
        return

    current_health = mini(
        current_health + amount,
        max_health
    )

    health_changed.emit(current_health, max_health)

func reset_health() -> void:
    current_health = max_health
    is_dead = false
    health_changed.emit(current_health, max_health)
```

Untuk player data-driven, inisialisasikan `max_health` dari `PlayerData` sebelum health mulai digunakan.

Pastikan tidak ada dua sistem yang menginisialisasi health dengan nilai berbeda secara tidak sengaja.

### 7.4 EnemyMovement: Patrol

File: `scripts/components/enemy_patrol.gd`

```gdscript
class_name EnemyPatrol
extends Node

@export var move_speed: float = 60.0
@export var patrol_distance: float = 100.0

var body: CharacterBody2D
var start_position: Vector2
var direction: float = 1.0

func initialize(target_body: CharacterBody2D) -> void:
    body = target_body
    start_position = body.global_position

func physics_update() -> void:
    if not is_instance_valid(body):
        return

    var offset: float = body.global_position.x - start_position.x

    if offset >= patrol_distance:
        direction = -1.0
    elif offset <= -patrol_distance:
        direction = 1.0

    body.velocity.x = direction * move_speed
```

Root enemy memanggil komponen ini dan menjalankan `move_and_slide()`.

Tambahkan pemeriksaan tepi platform jika digunakan untuk platformer.

### 7.5 EnemyMovement: Chase Target

File: `scripts/components/enemy_chase.gd`

```gdscript
class_name EnemyChase
extends Node

@export var move_speed: float = 80.0
@export var detection_range: float = 200.0

var body: CharacterBody2D
var target: Node2D

func initialize(target_body: CharacterBody2D) -> void:
    body = target_body

func set_target(new_target: Node2D) -> void:
    target = new_target

func physics_update() -> void:
    if not is_instance_valid(body):
        return

    if not is_instance_valid(target):
        body.velocity = Vector2.ZERO
        return

    var distance: float = body.global_position.distance_to(
        target.global_position
    )

    if distance > detection_range:
        body.velocity = Vector2.ZERO
        return

    var direction: Vector2 = body.global_position.direction_to(
        target.global_position
    )

    body.velocity = direction * move_speed
```

Komponen ini hanya menangani chase sederhana.

Gunakan `NavigationAgent2D` jika musuh perlu menghindari obstacle dan mengikuti jalur navigasi.

### 7.6 HealthComponent vs PlayerHealth

Gunakan `PlayerHealth` jika perilaku health player memiliki aturan khusus.

Gunakan `HealthComponent` generik jika player, enemy, dan objek lain benar-benar membutuhkan kontrak health yang sama.

Jangan mempertahankan dua implementasi identik tanpa alasan. Pilih pola yang paling sesuai dengan kebutuhan proyek.

### 7.7 WeaponController

Weapon menggunakan `WeaponData` untuk konfigurasi dan script komponen untuk perilaku.

Contoh:

```gdscript
class_name WeaponController
extends Node2D

@export var weapon_data: WeaponData

var can_attack: bool = true

func attack() -> void:
    if weapon_data == null or not can_attack:
        return

    can_attack = false

    if weapon_data.projectile_scene != null:
        spawn_projectile()

    await get_tree().create_timer(
        weapon_data.attack_cooldown
    ).timeout

    can_attack = true

func spawn_projectile() -> void:
    if weapon_data == null:
        return

    var projectile: Node = weapon_data.projectile_scene.instantiate()

    get_tree().current_scene.add_child(projectile)

    if projectile is Node2D:
        projectile.global_position = global_position
```

Implementasi produksi harus menangani ownership, arah serangan, collision, dan kemungkinan node dibebaskan selama cooldown.

Untuk kebutuhan kompleks, pisahkan `WeaponController`, `WeaponCooldown`, `WeaponAnimation`, dan sistem projectile hanya jika pembagian tersebut membantu.

### 7.8 Projectile

```gdscript
class_name Projectile
extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
    body_entered.connect(_on_body_entered)

    get_tree().create_timer(lifetime).timeout.connect(
        _on_lifetime_timeout
    )

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta

func set_direction(new_direction: Vector2) -> void:
    direction = new_direction.normalized()

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("receive_damage"):
        body.call("receive_damage", damage)

    queue_free()

func _on_lifetime_timeout() -> void:
    if is_instance_valid(self):
        queue_free()
```

Untuk sistem combat yang lebih besar, gunakan kontrak damage yang jelas, collision layer dan mask yang tepat, serta perlindungan terhadap hit berulang.

### 7.9 Template Selection Rules

| Kebutuhan | Pendekatan |
|---|---|
| Player top-down | `TopDownMovement` |
| Player platformer | `PlatformerMovement` |
| Enemy patrol | `EnemyPatrol` |
| Enemy chase | `EnemyChase` |
| Health | `PlayerHealth` atau `HealthComponent` |
| Weapon | `WeaponController` + `WeaponData` |
| Projectile | `Projectile` + konfigurasi yang diperlukan |
| Inventory | Inventory system + `ItemData` |
| Interaction | Komponen interaksi |
| Pickup | Pickup scene + `ItemData` |
| UI health | `HealthBar` + health signal |

Gunakan hanya komponen yang relevan. Jangan membuat seluruh sistem secara otomatis untuk game yang tidak memerlukannya.

---

## 8. AUTOLOAD AND GLOBAL SYSTEMS

Autoload digunakan untuk layanan yang memang memiliki lifetime global.

Contoh sistem:

```text
scripts/autoload/
├── game_manager.gd
├── audio_manager.gd
├── save_manager.gd
├── scene_transition_manager.gd
└── event_bus.gd
```

Daftarkan melalui pengaturan Autoload Godot.

Jangan membuat semua Autoload tersebut jika proyek tidak membutuhkannya.

### 8.1 GameManager

Mengelola state sesi permainan dan koordinasi alur game.

```gdscript
extends Node

signal game_started
signal game_over

var is_game_active: bool = false
var is_game_over: bool = false

func start_game() -> void:
    is_game_active = true
    is_game_over = false
    game_started.emit()

func end_game() -> void:
    if is_game_over:
        return

    is_game_active = false
    is_game_over = true
    game_over.emit()

func reset_game_state() -> void:
    is_game_active = false
    is_game_over = false
```

Jangan menjadikan `GameManager` tempat seluruh logika gameplay.

### 8.2 EventBus

```gdscript
extends Node

signal currency_changed(amount: int)
signal player_died
signal level_completed
signal quest_completed(quest_id: StringName)
```

Tambahkan signal hanya untuk kebutuhan komunikasi global yang nyata.

### 8.3 AudioManager

AudioManager harus menangani akses audio lintas scene, termasuk SFX dan musik jika diperlukan.

Aturan:

- Gunakan audio bus yang telah ditetapkan proyek.
- Hindari membuat player baru tanpa batas pada sistem SFX.
- Gunakan pooling jika dibutuhkan.
- Pisahkan music state dan efek suara jika lifecycle-nya berbeda.
- Jangan menggandakan audio manager yang sudah ada.

### 8.4 SaveManager

Gunakan SaveManager untuk data serializable.

Jangan menyimpan node runtime secara langsung. Validasi data yang dimuat dan pertimbangkan versioning jika format save dapat berubah.

### 8.5 SceneTransitionManager

Gunakan SceneTransitionManager untuk mengoordinasikan pergantian scene dan efek transisi.

Implementasi detailnya mengikuti bagian 12.

---

## 9. UI DESIGN SYSTEM AND THEME RESOURCE

Bagian ini merupakan standar wajib untuk seluruh UI game.

### 9.1 Shared Theme Resource

Gunakan `Theme` Resource bersama sebagai sumber utama visual UI.

Struktur:

```text
themes/
├── game_theme.tres
└── fonts/
```

Terapkan Theme pada root UI scene atau root UI utama sehingga kontrol turunannya menggunakan Theme yang sama.

Contoh:

```text
MainUI (Control)
├── MainMenu (Control)
├── HUD (Control)
└── PauseMenu (Control)
```

`MainUI` menggunakan `game_theme.tres`.

Gunakan Theme override lokal hanya ketika komponen memang memerlukan tampilan khusus.

Jangan mengatur warna, font, ukuran, dan style setiap Button secara manual jika nilai tersebut seharusnya berasal dari design system.

### 9.2 Theme Responsibilities

Theme Resource harus menjadi sumber utama untuk:

- Font dan font size.
- Warna teks.
- Button normal, hover, pressed, disabled, dan focus.
- Panel style.
- Background style.
- Border, corner radius, dan padding visual.
- StyleBox untuk berbagai jenis kontrol.
- Icon dan visual control jika sesuai.
- Variasi visual komponen yang digunakan berulang.

Gunakan named Theme types untuk komponen khusus jika diperlukan.

Contoh:

```text
Button
Label
PanelContainer
Card
PrimaryButton
SecondaryButton
```

Nama dan konfigurasi type variation harus konsisten di seluruh proyek.

### 9.3 Theme Hierarchy

Prioritaskan:

1. Project-wide Theme jika memang sesuai.
2. Shared Theme pada root UI scene.
3. Named Theme types untuk variasi komponen.
4. Local override hanya untuk kebutuhan khusus.

Jangan membuat Theme baru untuk setiap scene jika seluruh UI seharusnya menggunakan design system yang sama.

Jika game memiliki tema visual berbeda untuk mode atau dunia tertentu, gunakan Theme terpisah dengan alasan yang jelas.

### 9.4 Reusable UI Components

Buat reusable scene untuk komponen yang berulang.

Contoh:

```text
scenes/ui/components/
├── primary_button.tscn
├── secondary_button.tscn
├── card_panel.tscn
├── dialog_panel.tscn
├── health_bar.tscn
├── tooltip.tscn
└── confirmation_dialog.tscn
```

Gunakan komponen bersama agar perubahan desain dapat dilakukan di satu tempat.

Jangan membuat scene reusable untuk setiap kontrol bawaan yang hanya digunakan sekali tanpa modifikasi atau perilaku tambahan.

### 9.5 UI Component Behavior

Pisahkan tampilan dan perilaku.

Contoh:

- Button visual mengikuti Theme.
- Button animation mengelola hover dan press.
- Menu controller mengelola navigasi menu.
- Gameplay controller mengelola state gameplay.

Jangan membuat satu `UIManager` mengelola seluruh tombol, menu, dialog, HUD, dan navigasi game.

### 9.6 UI Theme Validation

Checklist:

- [ ] UI menggunakan shared Theme yang tepat.
- [ ] Font dan warna konsisten.
- [ ] Button state memiliki visual yang jelas.
- [ ] Panel dan card menggunakan style yang konsisten.
- [ ] Local overrides hanya digunakan jika diperlukan.
- [ ] Reusable components tidak menggandakan styling.
- [ ] Text tetap terbaca pada berbagai ukuran layar.

---

## 10. UI CONTAINER AND LAYOUT STANDARDS

Jangan menyusun UI dengan posisi manual untuk seluruh komponen jika layout dapat ditangani oleh container yang sesuai.

Pilih container berdasarkan hubungan dan perilaku layout yang diperlukan.

### 10.1 Container Selection

| Container | Gunakan ketika |
|---|---|
| `HBoxContainer` | Elemen tersusun horizontal |
| `VBoxContainer` | Elemen tersusun vertikal |
| `GridContainer` | Elemen tersusun dalam grid dengan jumlah kolom tertentu |
| `FlowContainer` | Elemen mengalir ke baris atau kolom berikutnya ketika ruang tidak cukup |
| `MarginContainer` | Konten membutuhkan margin internal |
| `CenterContainer` | Konten perlu dipusatkan |
| `ScrollContainer` | Konten perlu digulir ketika melebihi ruang |
| `TabContainer` | Konten dibagi ke beberapa tab |
| `PanelContainer` | Konten membutuhkan panel dengan style Theme |
| `AspectRatioContainer` | Rasio aspek konten perlu dipertahankan |
| `SplitContainer` | Dua area perlu dipisahkan dengan pembatas yang dapat diubah |
| `SubViewportContainer` | Konten viewport perlu ditampilkan di dalam UI |
| `BoxContainer` | Base class container horizontal/vertikal; biasanya pilih HBox atau VBox secara langsung |

Gunakan nama node Godot yang benar, seperti `HBoxContainer`, bukan `HContainer`.

### 10.2 Standard Menu Layout

Contoh main menu:

```text
MainMenu (Control)
└── Background (TextureRect)
└── SafeArea (MarginContainer)
    └── MainLayout (VBoxContainer)
        ├── Title (Label)
        ├── Spacer (Control)
        └── MenuButtons (VBoxContainer)
            ├── PlayButton
            ├── SettingsButton
            └── QuitButton
```

Gunakan container untuk menjaga jarak dan alignment.

Jangan menentukan posisi setiap button secara manual jika susunan vertikal sudah dapat ditangani `VBoxContainer`.

### 10.3 Inventory Layout

Contoh:

```text
InventoryPanel (PanelContainer)
└── MarginContainer
    └── VBoxContainer
        ├── InventoryTitle (Label)
        └── ScrollContainer
            └── GridContainer
                ├── InventorySlot
                ├── InventorySlot
                └── InventorySlot
```

Aturan:

- `GridContainer` digunakan untuk susunan slot.
- `ScrollContainer` digunakan jika jumlah slot melebihi area yang tersedia.
- `MarginContainer` mengatur jarak konten dari tepi panel.
- `VBoxContainer` mengatur susunan vertikal.

### 10.4 Settings Menu Layout

Contoh:

```text
SettingsPanel (PanelContainer)
└── MarginContainer
    └── VBoxContainer
        ├── SettingsTitle
        └── TabContainer
            ├── AudioTab
            │   └── VBoxContainer
            ├── VideoTab
            │   └── VBoxContainer
            └── ControlsTab
                └── VBoxContainer
```

Gunakan `TabContainer` jika pengguna memang perlu berpindah antarbagian pengaturan.

Jangan membuat tab hanya sebagai dekorasi.

### 10.5 Responsive Layout Rules

- Gunakan anchors dan container sesuai fungsi layout.
- Atur `Size Flags` dengan benar.
- Gunakan `Custom Minimum Size` ketika diperlukan.
- Gunakan `MarginContainer` untuk padding.
- Hindari posisi absolut untuk layout yang harus menyesuaikan ukuran.
- Gunakan `ScrollContainer` untuk konten yang berpotensi melebihi area.
- Periksa UI pada berbagai resolusi dan aspect ratio.
- Hindari kombinasi container bersarang yang tidak memiliki fungsi jelas.

### 10.6 Layout Validation

Sebelum menyelesaikan UI:

- [ ] Container sesuai dengan pola layout.
- [ ] Tidak ada elemen yang terpotong.
- [ ] Ukuran dan alignment sesuai.
- [ ] Scroll berfungsi jika diperlukan.
- [ ] Layout tidak bergantung pada satu resolusi saja.
- [ ] Theme diterapkan secara konsisten.
- [ ] Navigation dan focus tetap berfungsi.

---

## 11. REUSABLE UI ANIMATIONS

UI tidak boleh terasa statis ketika interaksi membutuhkan feedback visual.

Gunakan animasi yang konsisten dan reusable untuk button, text, panel, dialog, tooltip, dan elemen interaktif.

Animasi harus memperkuat hierarki dan feedback, bukan sekadar dekorasi.

### 11.1 Animation Standards

Gunakan durasi awal berikut sebagai panduan:

| Interaksi | Durasi awal |
|---|---:|
| Button hover | 0.10–0.16 detik |
| Button press | 0.06–0.12 detik |
| Text fade | 0.15–0.30 detik |
| Panel fade | 0.18–0.30 detik |
| Popup entrance | 0.20–0.35 detik |
| Tooltip | 0.12–0.20 detik |

Durasi dapat disesuaikan dengan gaya game.

Gunakan easing yang sesuai. Animasi hover harus terasa responsif. Animasi popup dapat menggunakan ease-out untuk memberikan efek masuk yang lebih natural.

### 11.2 Button Hover and Press Template

File: `scripts/components/ui_button_animation.gd`

Script ini dapat dipasang pada `Button` atau turunan `BaseButton`.

```gdscript
class_name UIButtonAnimation
extends Button

@export var hover_scale: float = 1.04
@export var press_scale: float = 0.96
@export var animation_duration: float = 0.12

var base_scale: Vector2 = Vector2.ONE
var current_tween: Tween

func _ready() -> void:
    base_scale = scale

    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    button_down.connect(_on_button_down)
    button_up.connect(_on_button_up)

func _animate_scale(target_scale: Vector2) -> void:
    if current_tween and current_tween.is_running():
        current_tween.kill()

    current_tween = create_tween()
    current_tween.set_trans(Tween.TRANS_CUBIC)
    current_tween.set_ease(Tween.EASE_OUT)

    current_tween.tween_property(
        self,
        "scale",
        target_scale,
        animation_duration
    )

func _on_mouse_entered() -> void:
    if disabled:
        return

    _animate_scale(base_scale * hover_scale)

func _on_mouse_exited() -> void:
    _animate_scale(base_scale)

func _on_button_down() -> void:
    if disabled:
        return

    _animate_scale(base_scale * press_scale)

func _on_button_up() -> void:
    if disabled:
        return

    if get_global_rect().has_point(get_global_mouse_position()):
        _animate_scale(base_scale * hover_scale)
    else:
        _animate_scale(base_scale)
```

Gunakan script ini sebagai template jika scale animation sesuai desain UI.

Catatan:

- Pastikan pivot button sesuai kebutuhan.
- Jika node sudah memiliki animasi scale lain, hindari dua sistem yang menulis properti scale secara bersamaan.
- Untuk keyboard/controller focus, tambahkan animasi focus yang sesuai.
- Untuk disabled state, pastikan tidak ada feedback hover atau press yang menyesatkan.
- Jangan memasang script ini ke semua kontrol secara otomatis tanpa mempertimbangkan fungsi dan aksesibilitas.

### 11.3 Button Fade Template

Untuk button atau control yang memerlukan fade, gunakan `modulate` atau `self_modulate` sesuai kebutuhan.

Contoh helper:

```gdscript
extends Control

@export var fade_duration: float = 0.15

var current_tween: Tween

func fade_to(target_alpha: float) -> void:
    if current_tween and current_tween.is_running():
        current_tween.kill()

    current_tween = create_tween()
    current_tween.set_trans(Tween.TRANS_CUBIC)
    current_tween.set_ease(Tween.EASE_OUT)

    current_tween.tween_property(
        self,
        "modulate:a",
        target_alpha,
        fade_duration
    )
```

Pastikan initial alpha dan state visibility sudah benar.

Jangan menggunakan alpha saja untuk menyimulasikan disabled state jika kontrol masih dapat menerima input. Atur `disabled`, mouse filtering, dan focus behavior sesuai kebutuhan.

### 11.4 Text Fade Template

Gunakan `Label` atau `RichTextLabel` dengan animasi opacity.

```gdscript
extends Label

@export var fade_duration: float = 0.25

var current_tween: Tween

func fade_in() -> void:
    if current_tween and current_tween.is_running():
        current_tween.kill()

    modulate.a = 0.0
    visible = true

    current_tween = create_tween()
    current_tween.set_trans(Tween.TRANS_CUBIC)
    current_tween.set_ease(Tween.EASE_OUT)

    current_tween.tween_property(
        self,
        "modulate:a",
        1.0,
        fade_duration
    )

func fade_out() -> void:
    if current_tween and current_tween.is_running():
        current_tween.kill()

    current_tween = create_tween()
    current_tween.set_trans(Tween.TRANS_CUBIC)
    current_tween.set_ease(Tween.EASE_IN)

    current_tween.tween_property(
        self,
        "modulate:a",
        0.0,
        fade_duration
    )

    current_tween.tween_callback(
        func() -> void:
            visible = false
    )
```

Untuk rich text, text reveal, atau typewriter effect, buat template terpisah apabila fitur tersebut dibutuhkan.

### 11.5 Panel Entrance Animation

Panel dapat menggunakan kombinasi fade dan scale.

Pola yang direkomendasikan:

1. Atur initial scale sedikit lebih kecil.
2. Atur alpha menjadi transparan.
3. Aktifkan visibility.
4. Animate scale dan alpha ke nilai normal.
5. Pastikan state akhir konsisten.

Gunakan Tween atau `AnimationPlayer` sesuai kebutuhan.

Jangan membuat setiap panel memiliki implementasi animasi yang berbeda jika pola yang sama dapat digunakan kembali.

### 11.6 Animation Rules

- Gunakan helper atau scene reusable untuk pola animasi yang berulang.
- Hindari Tween yang terus dibuat tanpa dibatalkan ketika animasi sebelumnya masih berjalan.
- Pastikan state akhir benar.
- Jangan membuat animasi menghambat interaksi tanpa alasan.
- Hormati keyboard navigation dan controller focus.
- Hindari terlalu banyak animasi yang berjalan bersamaan.
- Jangan membuat animasi dekoratif yang mengganggu gameplay.
- Untuk animasi yang kompleks dan artist-directed, gunakan `AnimationPlayer`.
- Untuk animasi pendek yang dibuat melalui kode, gunakan Tween.

---

## 12. REUSABLE SCENE TRANSITIONS

Scene transition merupakan sistem reusable yang harus dapat digunakan di berbagai game.

Gunakan `SceneTransitionManager` untuk mengatur proses perpindahan scene dan efek visual.

### 12.1 Standard Transition Templates

Sediakan template berikut apabila dibutuhkan:

| Transition | Kegunaan |
|---|---|
| Fade to black | Transisi umum antarlevel |
| Fade from black | Membuka level |
| Swipe left | Perpindahan ke konten berikutnya |
| Swipe right | Perpindahan ke konten sebelumnya |
| Fade through color | Transisi dengan warna tema |
| Instant transition | Pergantian tanpa animasi |
| Loading transition | Pergantian scene dengan loading screen |

Jangan menerapkan semua variasi ke setiap game. Sediakan sebagai pilihan reusable.

### 12.2 Transition Scene Structure

Contoh:

```text
TransitionLayer (CanvasLayer)
└── TransitionRoot (Control)
    └── TransitionRect (ColorRect)
```

Aturan:

- `CanvasLayer` digunakan agar efek berada di lapisan UI yang tepat.
- `TransitionRoot` dan `TransitionRect` harus mengisi viewport sesuai kebutuhan.
- `TransitionRect` menggunakan mouse filtering yang sesuai.
- Saat idle, overlay tidak menghalangi interaksi UI.
- Selama transisi, overlay dapat mengambil input jika diperlukan.
- Layer dan ownership harus tetap benar ketika scene berubah.

Tempatkan transition layer dalam Autoload jika efek perlu bertahan saat scene aktif diganti.

Jangan menyimpan transition overlay hanya pada scene level jika overlay harus tetap hidup selama pergantian scene.

### 12.3 TransitionManager API

Gunakan API yang konsisten, misalnya:

```gdscript
await SceneTransitionManager.change_scene(
    "res://scenes/levels/level_02.tscn",
    "fade"
)
```

Nama efek yang didukung harus eksplisit.

Contoh identifier:

```text
fade
swipe_left
swipe_right
fade_color
instant
```

Jangan menggunakan string sembarang tanpa validasi.

### 12.4 Fade Transition

Pola fade:

1. Overlay dimulai transparan.
2. Overlay menjadi opaque.
3. Scene diganti ketika layar tertutup.
4. Overlay kembali transparan.
5. Input dikembalikan setelah transisi selesai.

Gunakan Tween atau AnimationPlayer.

Pastikan scene hanya diganti satu kali per permintaan transisi.

### 12.5 Swipe Left and Swipe Right

Gunakan `Control` atau `ColorRect` yang dapat digerakkan melintasi viewport.

Untuk swipe left, overlay bergerak dari sisi kanan ke kiri atau menggunakan arah visual yang telah ditentukan.

Untuk swipe right, overlay bergerak dari sisi kiri ke kanan atau menggunakan arah visual yang telah ditentukan.

Tetapkan definisi arah secara konsisten di seluruh proyek. Nama efek harus merujuk pada arah gerakan overlay, bukan arah perpindahan pemain.

Pastikan ukuran overlay mencakup viewport sehingga tidak muncul celah pada resolusi atau aspect ratio yang berbeda.

### 12.6 Transition Implementation Rules

- Gunakan satu API transisi utama.
- Cegah transisi bersamaan yang tidak valid.
- Validasi path scene sebelum berpindah.
- Tangani kegagalan perpindahan scene.
- Jangan membiarkan overlay tertinggal dalam keadaan opaque.
- Pastikan input dipulihkan jika transisi gagal.
- Jangan menganggap `ResourceLoader.exists()` menjamin seluruh dependency scene valid.
- Gunakan asynchronous loading jika diperlukan.
- Jangan mengklaim sistem transisi sudah berfungsi sebelum diuji.

### 12.7 Transition Integration

Ketika membuat menu, level, atau game over screen, gunakan transition manager yang tersedia.

Jangan menulis ulang animasi fade di setiap button.

Contoh alur:

```text
PlayButton
    ↓
MenuController
    ↓
SceneTransitionManager
    ↓
Fade Out
    ↓
Change Scene
    ↓
Fade In
```

Button bertanggung jawab atas input. Menu controller menentukan tujuan. Transition manager mengatur transisi.

---

## 13. INPUT AND GAMEPLAY LOGIC

Gunakan Input Map melalui Project Settings → Input Map.

Contoh:

```text
move_left
move_right
move_up
move_down
jump
interact
attack
pause
```

Hindari hardcoding tombol di setiap script.

Gunakan component-based movement yang sesuai dengan genre.

Pisahkan input, movement, combat, dan interaction apabila tanggung jawabnya berbeda.

Jangan memaksakan satu template movement untuk semua game.

---

## 14. ERROR HANDLING AND DEBUGGING

Ketika menemukan error:

1. Baca pesan error lengkap.
2. Identifikasi file dan baris.
3. Periksa tipe data, node path, signal, Resource, dan lifecycle.
4. Periksa perubahan terbaru.
5. Identifikasi akar masalah.
6. Terapkan perbaikan sekecil mungkin.
7. Jalankan validasi ulang.

Gunakan `assert()`, `push_warning()`, atau `push_error()` sesuai kebutuhan.

Jangan menutupi masalah dengan fallback tanpa memahami penyebabnya.

Gunakan `is_instance_valid()` ketika referensi dapat mengarah ke instance yang sudah dibebaskan.

Jangan mengklaim tes telah dilakukan jika belum benar-benar dijalankan.

---

## 15. PERFORMANCE AND MEMORY

- Hindari alokasi objek yang tidak perlu pada jalur yang sering dijalankan.
- Hindari pencarian node global berulang kali.
- Gunakan pooling jika profiling menunjukkan kebutuhan.
- Gunakan Resource bersama secara aman.
- Batasi processing node yang tidak diperlukan.
- Atur collision layer dan mask dengan benar.
- Perhatikan ukuran texture dan audio.
- Gunakan profiler sebelum melakukan optimasi besar.

Jangan menambahkan pooling, multithreading, atau caching kompleks hanya karena dianggap lebih profesional.

---

## 16. TESTING AND VALIDATION

Setelah implementasi, lakukan validasi sesuai kemampuan lingkungan.

Checklist:

- [ ] Sintaks GDScript valid.
- [ ] Static typing dan return type konsisten.
- [ ] Struktur scene sesuai tanggung jawab komponen.
- [ ] Resource konfigurasi ditetapkan dengan benar.
- [ ] Runtime state tidak tercampur dengan shared Resource.
- [ ] Signal tersambung dengan benar.
- [ ] Autoload hanya didaftarkan sekali.
- [ ] UI menggunakan Theme yang sesuai.
- [ ] Container dipilih sesuai kebutuhan layout.
- [ ] UI tidak terpotong pada resolusi yang relevan.
- [ ] Button animation tidak mengganggu input.
- [ ] Scene transition memulihkan input dan overlay dengan benar.
- [ ] Tidak ada error baru yang diketahui.
- [ ] Fitur terkait sudah diuji.

Jika Godot CLI tersedia:

```bash
godot --headless --path . --editor --quit
```

Sesuaikan nama executable dan perintah dengan versi Godot yang tersedia.

Validasi headless tidak menjamin seluruh gameplay dan UI berfungsi. Jalankan scene yang relevan dan uji perilaku aktual.

---

## 17. CHANGE MANAGEMENT

Sebelum mengubah kode:

1. Identifikasi file yang terdampak.
2. Periksa dependency.
3. Periksa komponen dan Resource yang sudah ada.
4. Periksa Theme serta UI component yang relevan.
5. Tentukan perilaku yang diharapkan.

Saat mengubah kode:

- Ubah hanya bagian yang diperlukan.
- Pertahankan kompatibilitas.
- Jangan melakukan refactor tidak terkait.
- Jangan menggandakan sistem yang sudah ada.
- Perbarui scene dan Resource yang bergantung pada perubahan.

Setelah perubahan:

- Validasi sintaks.
- Uji perilaku.
- Periksa regresi.
- Laporkan hasil validasi secara jujur.

---

## 18. AI CODING WORKFLOW

### Phase 1: Understand

1. Pahami kebutuhan fitur.
2. Periksa struktur proyek.
3. Identifikasi scene, script, Resource, dan komponen terkait.
4. Cari template yang sudah tersedia.
5. Periksa Theme, container, dan transition system jika mengerjakan UI.

### Phase 2: Design

1. Tentukan konfigurasi yang perlu menjadi Resource.
2. Tentukan scene dan komponen yang diperlukan.
3. Pisahkan tanggung jawab setiap script.
4. Tentukan komunikasi antarobjek.
5. Tentukan kebutuhan Autoload.
6. Tentukan apakah Theme dan reusable UI component yang ada dapat digunakan.
7. Tentukan layout container yang tepat.
8. Tentukan animasi atau transition yang diperlukan.

### Phase 3: Implement

1. Gunakan template yang tersedia.
2. Gunakan data-driven Resource.
3. Gunakan component-based scene architecture.
4. Pertahankan static typing.
5. Gunakan shared Theme.
6. Gunakan container yang sesuai.
7. Gunakan reusable UI animations dan scene transitions.
8. Hindari duplikasi dan overengineering.

### Phase 4: Validate

1. Periksa sintaks.
2. Periksa node path dan Resource.
3. Periksa koneksi signal.
4. Periksa UI layout dan Theme.
5. Uji animation state dan input.
6. Uji scene transition.
7. Uji fitur terkait dan kemungkinan regresi.

### Phase 5: Report

Laporkan:

- File yang dibuat atau diubah.
- Komponen dan Resource baru.
- Struktur scene yang berubah.
- Theme atau UI component yang digunakan.
- Animasi dan transisi yang ditambahkan.
- Cara menjalankan dan menguji fitur.
- Hasil validasi yang benar-benar dilakukan.
- Masalah yang masih tersisa.

---

## 19. CODE REVIEW CHECKLIST

### Project Structure
- [ ] Struktur folder mengikuti standar kategori.
- [ ] Nama file dan class konsisten.
- [ ] Tidak ada duplikasi implementasi yang tidak diperlukan.

### Data-Driven Design
- [ ] Konfigurasi entitas menggunakan Resource jika relevan.
- [ ] Runtime state dipisahkan dari konfigurasi.
- [ ] Shared Resource digunakan dengan aman.

### Component Architecture
- [ ] Root scene tidak memiliki satu script yang mengurus semua perilaku.
- [ ] Movement, health, combat, dan animasi dipisahkan jika tanggung jawabnya berbeda.
- [ ] Komponen tidak memiliki dependency yang tidak perlu.
- [ ] Komunikasi antarobjek jelas.

### Autoload
- [ ] Autoload benar-benar diperlukan.
- [ ] Tidak ada registrasi ganda.
- [ ] Global state tidak digunakan berlebihan.

### UI Design System
- [ ] UI menggunakan shared Theme.
- [ ] Warna, font, dan style konsisten.
- [ ] Reusable UI components digunakan jika sesuai.
- [ ] Local overrides tidak digunakan secara berlebihan.

### UI Layout
- [ ] Container sesuai kebutuhan layout.
- [ ] Size flags dan anchors benar.
- [ ] UI tidak terpotong.
- [ ] Layout bekerja pada resolusi yang relevan.
- [ ] Scroll dan tab berfungsi jika digunakan.

### Animation and Transition
- [ ] Hover dan press animation konsisten.
- [ ] Animasi tidak mengganggu input.
- [ ] Tween sebelumnya ditangani ketika animasi baru dimulai.
- [ ] Scene transition tidak berjalan ganda.
- [ ] Overlay dan input dipulihkan dengan benar.
- [ ] Arah swipe konsisten.

### Reliability
- [ ] Lifecycle node ditangani.
- [ ] Signal dan Resource valid.
- [ ] Tidak ada error baru yang diketahui.
- [ ] Perubahan sudah divalidasi sejauh memungkinkan.

---

## 20. FINAL RULES

1. Gunakan struktur folder berbasis kategori yang konsisten.
2. Gunakan static typing dan return type yang jelas.
3. Utamakan data-driven architecture untuk konfigurasi entitas.
4. Pisahkan Resource, scene, komponen, dan runtime state.
5. Jangan menumpuk seluruh perilaku entitas dalam satu script besar.
6. Gunakan child node dengan script terpisah untuk tanggung jawab yang berbeda.
7. Gunakan Autoload hanya untuk sistem global yang memang dibutuhkan.
8. Gunakan shared UI Theme Resource untuk konsistensi visual.
9. Gunakan container berdasarkan fungsi layout, bukan posisi manual tanpa alasan.
10. Gunakan reusable UI components jika komponen berulang.
11. Gunakan template animasi untuk feedback visual yang konsisten.
12. Gunakan reusable scene transition untuk perpindahan scene.
13. Hindari duplikasi dan overengineering.
14. Pertahankan arsitektur yang sudah sehat.
15. Validasi kode dan perilaku sebelum menyatakan tugas selesai.
16. Jangan mengklaim pengujian yang belum dijalankan.
17. Utamakan kode yang mudah dipahami, digunakan ulang, dan dikembangkan.

**Definition of Done:** Implementasi memenuhi kebutuhan, menggunakan Resource dan komponen dengan tepat, mengikuti struktur proyek, mempertahankan konsistensi UI, menggunakan layout dan animasi yang sesuai, tidak memperkenalkan error yang diketahui, serta telah divalidasi sejauh yang memungkinkan.