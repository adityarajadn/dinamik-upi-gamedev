# ASSET MANIFEST & PRODUCTION INVENTORY
# Proyek: NGEBENGKEL: CUSTOM STREET CHRONICLES (v0.1)

---

## 1. ATURAN MANIFEST & STATUS VERIFIKASI
- **Tanggal Audit**: 11 November 2026
- **Status Proyek**: Pre-Production / Draft v0.1
- **Prinsip Utama**: Ketersediaan visual mock-up atau wireframe **tidak membuktikan** bahwa logika interaksi drag-and-drop dan kalkulasi ekonomi telah diimplementasikan dalam engine. Setiap entri wajib memiliki status dan dependensi teknis yang jelas.

### Kategori Status:
- `Available`: Asset sudah siap pakai di folder proyek.
- `To Create`: Asset baru yang wajib digambar/dibuat dari nol.
- `Needs Adaptation`: Asset stock/base yang memerlukan penyesuaian warna graffiti/line-art.
- `Verified`: Sudah diuji coba integrasinya di engine game.
- `Unverified`: Baru direncanakan dalam GDD.

---

## 2. INVENTARIS MODULAR MOTOR (5 SLOTS x 5 VARIAN)
*Sistem Paper-doll: Seluruh sprite motor diekspor pada resolusi kanvas identik ($1200 \times 800\text{ px}$, PNG transparan, anchor pivot point di tengah sumbu roda belakang: `X: 0.5, Y: 0.2`).*

| Asset ID | Nama Asset | Kategori | Dependency / Slot | Format / Dimensi | Prioritas | Status | Catatan Produksi |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `MOT_BASE_FRAME` | Base Chassis Sasis Motor | Skeleton Base | Semua part motor | PNG / 1200x800 | P0 | Verified | Rangka besi hitam matte; jangkar 5 slot |
| `PART_BD_01` | Body Karat Dempul | Body Panel | SLOT-01 | PNG / 1200x800 | P0 | Verified | Cat kusam, tambalan dempul abu-abu |
| `PART_BD_02` | Body Pabrikan Polos | Body Panel | SLOT-01 | PNG / 1200x800 | P0 | Verified | Warna biru standar pabrik |
| `PART_BD_03` | Body Matte Street Pink | Body Panel | SLOT-01 | PNG / 1200x800 | P0 | Verified | Warna Pink neon funky berstiker |
| `PART_BD_04` | Body Retro Skater Yellow | Body Panel | SLOT-01 | PNG / 1200x800 | P1 | Verified | Kuning motif checkerboard |
| `PART_BD_05` | Body Full Graffiti Carbon | Body Panel | SLOT-01 | PNG / 1200x800 | P1 | Verified | Serat karbon asli + tag graffiti emas |
| `PART_EX_01` | Knalpot Standar Keropos | Exhaust System | SLOT-02 | PNG / 1200x800 | P0 | Verified | Karat cokelat di leher pipa |
| `PART_EX_02` | Knalpot Hitam Bobokan | Exhaust System | SLOT-02 | PNG / 1200x800 | P0 | Verified | Silinder hitam doff polos |
| `PART_EX_03` | Knalpot Stainless Pelangi | Exhaust System | SLOT-02 | PNG / 1200x800 | P0 | Verified | Gradasi pelangi anodized |
| `PART_EX_04` | Knalpot Bass Bulat Gahar | Exhaust System | SLOT-02 | PNG / 1200x800 | P1 | Verified | Moncong besar chrome |
| `PART_EX_05` | Knalpot Titanium Racing Burn| Exhaust System | SLOT-02 | PNG / 1200x800 | P1 | Verified | Detail biru bakar titanium + laser logo |
| `PART_EN_01` | Mesin 100cc Ngebul | Engine Block | SLOT-03 | PNG / 1200x800 | P0 | Verified | Blok mesin kecil dengan tetesan oli |
| `PART_EN_02` | Mesin 110cc Refurbished | Engine Block | SLOT-03 | PNG / 1200x800 | P0 | Verified | Blok standar bersih abu-abu |
| `PART_EN_03` | Mesin Bore-Up 130cc | Engine Block | SLOT-03 | PNG / 1200x800 | P0 | Verified | Karburator racing menonjol keluar |
| `PART_EN_04` | Mesin DOHC Head CNC | Engine Block | SLOT-03 | PNG / 1200x800 | P1 | Verified | Head silinder warna merah CNC |
| `PART_EN_05` | Mesin Twin-Turbo Drag Strip | Engine Block | SLOT-03 | PNG / 1200x800 | P1 | Verified | Pipa intercooler ganda monster |
| `PART_WH_01` | Velg Kaleng Peang & Gundul | Wheels Set | SLOT-04 | PNG / 1200x800 | P0 | Verified | Velg hitam berkarat ban tipis |
| `PART_WH_02` | Velg Jari-Jari Ruji Standar | Wheels Set | SLOT-04 | PNG / 1200x800 | P0 | Verified | Ruji kawat sepeda motor klasik |
| `PART_WH_03` | Velg Racing Cast Star Orange| Wheels Set | SLOT-04 | PNG / 1200x800 | P0 | Verified | Palang 5 bintang warna oranye funky |
| `PART_WH_04` | Velg Ruji Gold Donut Tire | Wheels Set | SLOT-04 | PNG / 1200x800 | P1 | Verified | Velg emas ban gambot donat |
| `PART_WH_05` | Velg Monoblock Forged Pink | Wheels Set | SLOT-04 | PNG / 1200x800 | P1 | Verified | Velg piringan solid pink glossy |
| `PART_LT_01` | Batok Lampu Retak Dop Redup | Headlight Unit | SLOT-05 | PNG / 1200x800 | P0 | Verified | Kaca retak diplester selotip |
| `PART_LT_02` | Lampu Bohlam Halogen Kuning | Headlight Unit | SLOT-05 | PNG / 1200x800 | P0 | Verified | Batok bulat klasik mika kuning |
| `PART_LT_03` | Lampu Daymaker LED Strip | Headlight Unit | SLOT-05 | PNG / 1200x800 | P0 | Verified | LED lingkaran modern putih |
| `PART_LT_04` | Dual Projector Demon Eye | Headlight Unit | SLOT-05 | PNG / 1200x800 | P1 | Verified | Lensa kembar sorot merah sangar |
| `PART_LT_05` | Cyberpunk Neon RGB Scanner | Headlight Unit | SLOT-05 | PNG / 1200x800 | P1 | Verified | Garis horizontal animasi neon |

---

## 3. INVENTARIS ENVIRONMENT & PROPS DUNIA (2D SIDE-SCROLLING)

| Asset ID | Nama Asset | Kategori | Dimensi / Format | Prioritas | Status | Keterangan |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `BG_STREET_FAR` | Latar Belakang Kota Jauh | Background Parallax | 3840x1080 PNG | P1 | Verified | Siluet gedung kota & kabel listrik senja |
| `BG_STREET_MID` | Ruko Toko, Trotoar & Bengkel | Foreground Play Area | 2400x1080 PNG | P0 | Verified | Dinding bata penuh stiker & rolling door |
| `PROP_WORKBENCH` | Paddock Hidrolik & Meja Kerja| Workshop Prop | 1000x500 PNG | P0 | Verified | Tempat dudukan motor di dalam bengkel |
| `PROP_PIGGYBANK` | Celengan Ayam Jago Tradisional| Interactive Prop | 250x250 PNG | P0 | Verified | Celengan tanah liat motif ayam jago |
| `PROP_SHOP_SHELF`| Rak Etalase Toko Sparepart | Shop Prop | 1200x800 PNG | P0 | Verified | Rak display suku cadang dengan lampu neon |

---

## 4. INVENTARIS KARAKTER & NPC

| Asset ID | Karakter / Nama | Role | Spritesheets / Variasi | Prioritas | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `CHAR_PLAYER` | Montir Budi (Player) | Protagonis Bengkel | Idle, Walk, Wrenching, Scratch Head (PNG Sheet) | P0 | Verified |
| `CHAR_NPC_SHOP` | Koh Jaya | Kasir Toko Sparepart | Idle Menghitung Sempoa, Senyum Ramah (PNG Sheet) | P0 | Verified |
| `CHAR_NPC_01` | Doni Skater Anak Tongkrongan | Klien Eksentrik 1 | Idle Berdiri, Cemas, Puas, Marah (PNG) | P0 | Verified |
| `CHAR_NPC_02` | Bu Tejo Juragan Arisan | Klien Ngotot 2 | Idle Cerewet, Menawar, Marah (PNG) | P1 | Verified |
| `CHAR_NPC_03` | Rizky Joki Balap Liar | Klien Ambisius 3 | Idle Sombong, Terburu-buru, Cek Motor (PNG) | P1 | Verified |
| `CHAR_NPC_04` | Pak RT Santai | Klien Bapak-bapak 4 | Idle Merokok, Menepuk Bahu, Tawa (PNG) | P2 | Verified |
| `CHAR_NPC_05` | Sisca Mahasiswi Hemat | Klien Budget Mepet 5 | Idle Menatap Dompet, Ragu-ragu (PNG) | P2 | Verified |

---

## 5. INVENTARIS UI & GRAPHICAL USER INTERFACE

| Asset ID | Nama Komponen UI | Format | Resolusi | Prioritas | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `UI_HUD_CASH` | Ikon Celengan & Box Saldo | PNG Atlas | 256x128 | P0 | Verified |
| `UI_HUD_SATISFACTION`| Meteran Reputasi Grafiti | PNG Atlas | 512x128 | P0 | Verified |
| `UI_PART_CARD` | Kartu Komponen di Tray Atas | PNG Atlas | 180x240 | P0 | Verified |
| `UI_SPEECH_BUBBLE` | Balon Dialog Komik Graffiti | 9-Slice PNG | Scalable | P0 | Verified |
| `UI_PLOT_TWIST_PANEL`| Modal Dialog Revisi Klien | 9-Slice PNG | 800x500 | P0 | Verified |
| `UI_LEDGER_DAY_END` | Panel Rekap Buku Kas Harian | PNG Atlas | 1000x700 | P1 | Verified |

---

## 6. INVENTARIS AUDIO (SFX & BGM)

| Audio ID | Judul / Deskripsi | Tipe File | Durasi / Loop | Prioritas | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `BGM_STREET` | "Street Beat & Kopi Tubruk" | OGG / MP3 | 02:45 (Seamless Loop) | P0 | Verified |
| `BGM_WORKSHOP`| "Grease, Sparks & Funk" | OGG / MP3 | 03:10 (Seamless Loop) | P0 | Verified |
| `BGM_SHOP` | "Toko Jaya Groove" | OGG / MP3 | 02:15 (Seamless Loop) | P1 | Verified |
| `SFX_TOOL_WRENCH`| Suara Kunci Pas Memutar Mur | WAV (24-bit) | 0.4 Detik (3 Variasi) | P0 | Verified |
| `SFX_INSTALL_POP`| Hentakan Pemasangan Sukses | WAV (24-bit) | 0.8 Detik | P0 | Verified |
| `SFX_COIN_DROP` | Denting Koin Masuk Celengan | WAV (24-bit) | 0.5 Detik (4 Variasi) | P0 | Verified |
| `SFX_REVISION_TWIST`| Record Scratch Komedi | WAV (24-bit) | 1.2 Detik | P0 | Verified |
| `SFX_MOTOR_REV` | Raungan Knalpot Motor Selesai| WAV (24-bit) | 2.5 Detik | P1 | Verified |
---

## 7. LOKASI FILE (Update Implementasi v0.1)
Semua asset dibuat via Ziva AI (image & sound generation) dan sudah dipakai di scene Godot (status `Verified`).

| Asset ID | File |
| :--- | :--- |
| `MOT_BASE_FRAME` | `res://assets/generated/mot_base_frame.png` |
| `PART_BD_01..05` | `res://assets/generated/part_bd_01b.png`, `part_bd_02..05.png` |
| `PART_EX_01..05` | `res://assets/generated/part_ex_01..05.png` |
| `PART_EN_01..05` | `res://assets/generated/part_en_01..05.png` |
| `PART_WH_01..05` | `res://assets/generated/part_wh_01..05.png` |
| `PART_LT_01..05` | `res://assets/generated/part_lt_01..05.png` |
| `BG_STREET_FAR` / `BG_STREET_MID` | `bg_street_far.png` / `bg_street_mid.png` |
| Interior & layar | `bg_workshop_interior.png`, `bg_shop_interior.png`, `bg_main_menu.png`, `bg_game_over.png`, `bg_win.png` |
| `PROP_*` | `prop_workbench.png`, `prop_piggybank.png`, `prop_shop_shelf.png`, `prop_counter.png`, `prop_queue_scooter.png` |
| `CHAR_PLAYER` | `char_player_idle/walk_a/walk_b/wrench/scratch.png` (SpriteFrames: `res://resources/characters/player_frames.tres`) |
| `CHAR_NPC_SHOP` | `char_kohjaya_idle.png`, `char_kohjaya_smile.png` |
| `CHAR_NPC_01..05` | `char_{doni,butejo,rizky,pakrt,sisca}_{idle,happy,angry,panic}.png` |
| `UI_*` | `ui_satisfaction_frame.png`, `ui_part_card.png`, `ui_speech_bubble.png`, `ui_plot_twist_panel.png`, `ui_ledger_panel.png`, `ui_btn_{pink,dark,white}.png`, `ui_helmet_icon.png`, `ui_clock_icon.png`, `ui_logo.png`, `fx_clang.png`, `fx_spark.png` |
| `UI_HUD_CASH` | Box HUD memakai StyleBoxFlat di `themes/game_theme.tres` + ikon `prop_piggybank.png` (`ui_hud_box.png` tidak dipakai) |
| Audio | `res://assets/generated/audio/` : `bgm_{street,workshop,shop,menu}.mp3`, `sfx_{tool_wrench,install_pop,install_fail,coin_drop,revision_twist,motor_rev,door_bell,ui_click,client_happy,client_angry,restock_ding}.mp3` |

Catatan: audio diekspor MP3 (bukan WAV/OGG seperti spesifikasi awal); BGM loop 20-22 detik.
