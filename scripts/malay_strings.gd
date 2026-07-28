extends RefCounted
class_name MalayStrings

## Bahasa Melayu translations for every player-facing string in the game.
## Returns a Dictionary keyed by the exact English source string, mapping to
## its KSSR-standard Bahasa Melayu equivalent.
## Called once from Globals._ready() to populate TranslationServer.

static func get_messages() -> Dictionary:
	return {
		# ── Main menu ────────────────────────────────────────────────────────
		"SciQuest": "SciQuest",
		"Year 4 Science Adventure": "Pengembaraan Sains Tahun 4",
		"Start Learning": "Mula Belajar",
		"Quit": "Keluar",
		"Plants  •  Light  •  Energy  •  Earth  •  Machines": "Tumbuhan  •  Cahaya  •  Tenaga  •  Bumi  •  Mesin",
		"Language": "Bahasa",
		"English": "English",
		"Bahasa Melayu": "Bahasa Melayu",

		# ── Level / topic select ─────────────────────────────────────────────
		"Choose a Topic": "Pilih Topik",
		"Playing as: {name}": "Bermain sebagai: {name}",
		"< Back": "< Kembali",
		"TOPIC": "TOPIK",
		"Plants": "Tumbuhan",
		"Light": "Cahaya",
		"Energy": "Tenaga",
		"Earth": "Bumi",
		"Machines": "Mesin",
		"Forest World": "Dunia Hutan",
		"Crystal Caves": "Gua Kristal",
		"Volcano Zone": "Zon Gunung Berapi",
		"Space & Planet": "Angkasa & Planet",
		"Steam Factory": "Kilang Wap",
		"Learn about\nplants in the\nforest!": "Pelajari\ntumbuhan di\ndalam hutan!",
		"Discover the\nsecrets of\nlight!": "Temui\nrahsia-rahsia\ncahaya!",
		"Master energy\nin the\nvolcano zone!": "Kuasai tenaga\ndi zon\nberapi!",
		"Explore space\nand learn\nabout Earth!": "Teroka angkasa\ndan pelajari\ntentang Bumi!",
		"Build and\nmaster all\nmachines!": "Bina dan\nkuasai semua\nmesin!",
		"  CLEAR  ": "  TAMAT  ",
		"PLAY": "MAIN",

		# ── Character select ─────────────────────────────────────────────────
		"Choose Your Hero": "Pilih Wira Anda",
		"Select your adventurer": "Pilih pengembara anda",
		"Warrior": "Pahlawan",
		"Explorer": "Penjelajah",
		"SELECT": "PILIH",

		# ── Battle UI ────────────────────────────────────────────────────────
		"Topic 4: Plants": "Topik 4: Tumbuhan",
		"Topic 5: Properties of Light": "Topik 5: Sifat Cahaya",
		"Topic 7: Energy": "Topik 7: Tenaga",
		"Topic 9: Earth": "Topik 9: Bumi",
		"Topic 10: Machines": "Topik 10: Mesin",
		"You": "Kamu",
		"Correct!": "Betul!",
		"Wrong.": "Salah.",
		"Correct answer": "Jawapan betul",
		"Continue ▶": "Teruskan ▶",
		"Battle Won!": "Pertempuran Menang!",
		"Great work — you defeated the enemy in {n} questions.": "Tahniah! Kamu mengalahkan musuh dalam {n} soalan.",
		"Battle Lost.": "Pertempuran Kalah.",
		"Review the explanations above, then try again. Respawning at last checkpoint...": "Semak semula penerangan di atas, kemudian cuba lagi. Penjanaan semula di pusat pemeriksaan terakhir...",
		"Respawn ▶": "Jana Semula ▶",
		"Need stamina!": "Stamina tidak mencukupi!",

		# ── Level complete screen ────────────────────────────────────────────
		"LEVEL COMPLETE!": "PERINGKAT TAMAT!",
		"STELLAR WORK!": "CEMERLANG!",
		"SCIENCE STAR!": "BINTANG SAINS!",
		"OUTSTANDING!": "LUAR BIASA!",
		"WELL DONE!": "BAGUS SEKALI!",
		"GREAT JOB!": "KERJA BAGUS!",
		"NICELY DONE!": "SYABAS!",
		"LEVEL CLEAR!": "PERINGKAT SELESAI!",
		"YOU DID IT!": "KAMU BERJAYA!",
		"MISSION DONE!": "MISI TAMAT!",
		"TIME": "MASA",
		"CORRECT": "BETUL",
		"ENEMIES": "MUSUH",
		"DEATHS": "KEMATIAN",
		"CONGRATULATIONS!": "TAHNIAH!",
		"You completed every topic!": "Anda telah menamatkan semua topik!",
		"TRUE SCIENCE CHAMPION!": "JUARA SAINS SEJATI!",
		"◆ NEW BEST ◆": "◆ REKOD BARU ◆",
		"CONTINUE  ►": "TERUSKAN  ►",

		# ── Tutorial card (level select) ─────────────────────────────────────
		"Tutorial": "Tutorial",
		"Training Grounds": "Padang Latihan",
		"Learn to move,\nfight and use\nlevers!": "Belajar bergerak,\nbertarung dan\nguna suis!",
		"Tutorial: Training Grounds": "Tutorial: Padang Latihan",

		# ── Settings screen ──────────────────────────────────────────────────
		"Settings": "Tetapan",
		"SETTINGS": "TETAPAN",
		"CONTROLS": "KAWALAN",
		"Keyboard": "Papan Kekunci",
		"Controller": "Alat Kawalan",
		"Arrow Keys": "Kekunci Anak Panah",
		"Stick / D-Pad": "Bedik / D-Pad",
		"Move": "Gerak",
		"Jump": "Lompat",
		"Crouch": "Tunduk",
		"Attack": "Serang",
		"Dash": "Pecut",
		"Slide": "Gelongsor",
		"Interact": "Interaksi",
		"Pause": "Jeda",
		"Menu Select": "Pilih Menu",
		"Menu Back": "Kembali Menu",

		# ── Info boards — Tutorial ───────────────────────────────────────────
		"Press up and down to move on ladders": "Tekan atas dan bawah untuk bergerak pada tangga",
		"Move with the Arrow Keys\nor the Left Stick.":
			"Gerak dengan Kekunci Anak Panah\natau Bedik Kiri.",
		"Press Up or (A) to jump.": "Tekan Atas atau (A) untuk melompat.",
		"Press 'A' or (RB) to dash.\nDashing consumes stamina.":
			"Tekan 'A' atau (RB) untuk memecut.\nMemecut menggunakan stamina.",
		"Press Up or (A) while on a wall\nto perform a wall jump.":
			"Tekan Atas atau (A) semasa di dinding\nuntuk membuat lompatan dinding.",
		"Attack: 'Z' key or (X) button.\nAttacking an enemy starts a quiz battle —\nanswer correctly to win!":
			"Serang: kekunci 'Z' atau butang (X).\nMenyerang musuh memulakan pertarungan kuiz —\njawab dengan betul untuk menang!",
		"Press 'E' or (B) to operate levers.":
			"Tekan 'E' atau (B) untuk menggerakkan suis.",
		"Stick to the wall to slide down and avoid fall damage.":
			"Lekat pada dinding untuk menggelongsor turun dan mengelakkan kecederaan jatuh.",
		"Press 'C' or (LB) to slide. Don't hit your head!":
			"Tekan 'C' atau (LB) untuk menggelongsor. Jangan terhantuk kepala!",
		"Press 'E' or (B) to open chests.\nPress 'I' to check your inventory.":
			"Tekan 'E' atau (B) untuk membuka peti.\nTekan 'I' untuk menyemak inventori anda.",
		"Use these potions to restore mana.\nPress 'V' or (RT) to throw a fireball.\nYou're a fighter. Your mana doesn't regenerate!":
			"Guna posyen ini untuk memulihkan mana.\nTekan 'V' atau (RT) untuk membaling bebola api.\nAnda seorang pahlawan. Mana anda tidak pulih sendiri!",
		"Press 'S' or (LT) to block.\nEnemy attacks drain your stamina.":
			"Tekan 'S' atau (LT) untuk menangkis.\nSerangan musuh mengurangkan stamina anda.",
		"Press Down to duck.": "Tekan Bawah untuk menunduk.",
		"Beware of the crushers!\nThey bring instant death.":
			"Awas penghancur!\nIa membawa maut serta-merta.",
		"Yay! Trapdoors!": "Yay! Pintu perangkap!",
		"Some things are hidden to the eye.\nLook closely...":
			"Sesetengah perkara tersembunyi daripada mata.\nLihat dengan teliti...",
		"You should know the basics by now.\nTime for the real adventure!":
			"Anda sepatutnya sudah tahu asasnya sekarang.\nMasa untuk pengembaraan sebenar!",

		# ── Info boards — Level 4 (Plants) ──────────────────────────────────
		"Plants respond to stimuli too! Roots grow towards water and gravity, shoots grow towards light, and the leaves of some plants respond to touch.":
			"Tumbuhan juga bertindak balas terhadap rangsangan! Akar tumbuh menuju air dan graviti, pucuk tumbuh menuju cahaya, dan daun sesetengah tumbuhan bertindak balas terhadap sentuhan.",
		"The mimosa plant and the Venus flytrap will close or fold their leaves when touched — a plant's way of responding to touch.":
			"Pokok semalu dan perangkap lalat Venus akan menutup atau melipat daunnya apabila disentuh — cara tumbuhan bertindak balas terhadap sentuhan.",
		"Photosynthesis is the process by which plants make their own food. Even non-green plants can photosynthesise, as long as they have chlorophyll.":
			"Fotosintesis ialah proses yang digunakan oleh tumbuhan untuk menghasilkan makanan mereka sendiri. Tumbuhan bukan hijau pun boleh berfotosintesis, selagi mempunyai klorofil.",
		"Photosynthesis needs four things: sunlight as the main energy source, chlorophyll, carbon dioxide from the air, and water absorbed through the roots.":
			"Fotosintesis memerlukan empat perkara: cahaya matahari sebagai sumber tenaga utama, klorofil, karbon dioksida daripada udara, dan air yang diserap melalui akar.",
		"Photosynthesis produces glucose, stored as starch in leaves, stems, roots, seeds, flowers and fruits — and oxygen, released into the air through the leaves.":
			"Fotosintesis menghasilkan glukosa yang disimpan sebagai kanji dalam daun, batang, akar, biji benih, bunga dan buah — serta oksigen yang dibebaskan ke udara melalui daun.",
		"Photosynthesis matters to all living things — it provides a source of food, releases oxygen for respiration, and helps maintain the balance of air in nature.":
			"Fotosintesis penting bagi semua hidupan — ia menyediakan sumber makanan, membebaskan oksigen untuk respirasi, dan membantu mengekalkan keseimbangan udara di alam semula jadi.",

		# ── Info boards — Level 5 (Light) ────────────────────────────────────
		# Keys must match scenes/level_5_light_full.tscn description strings
		# verbatim (including line breaks) so the boards auto-translate.
		"Light travels in straight lines.\nWithout light, we cannot see. Use the torch to light up the crystal.":
			"Cahaya bergerak dalam garis lurus.\nTanpa cahaya, kita tidak dapat melihat. Guna obor untuk menyinari kristal.",
		"Materials behave differently with light:\nopaque blocks it, transparent lets it through,\ntranslucent lets some through.":
			"Bahan bertindak balas berbeza dengan cahaya:\nlegap menghalangnya, lutsinar membenarkannya menembusi,\nlut cahaya membenarkan sebahagian menembusi.",
		"Light reflects off shiny surfaces.\nThe angle of reflection equals\nthe angle the light arrived at.":
			"Cahaya dipantulkan oleh permukaan berkilat.\nSudut pantulan adalah sama dengan\nsudut cahaya itu tiba.",
		"Light passes through tinted glass\nbut loses some brightness.\nUse mirrors to send it where you need.":
			"Cahaya menembusi kaca berwarna\ntetapi kehilangan sebahagian kecerahan.\nGuna cermin untuk menghantarnya ke tempat yang anda mahu.",
		# Level 5 in-world labels / prompts (auto-translated Label nodes)
		"Crystal": "Kristal",
		"Only the right material lets light pass.":
			"Hanya bahan yang betul membenarkan cahaya menembusi.",
		"[Hold E] Rotate mirror": "[Tahan E] Putar cermin",

		# ── Info boards — Level 7 (Energy) ──────────────────────────────────
		"Pull the lever to aim the sun at the solar panel and power the gate. Solar energy is renewable — it never runs out.":
			"Tarik tuas untuk menghala matahari ke panel solar dan menghidupkan pintu gerbang. Tenaga solar boleh diperbaharui — ia tidak akan habis.",
		"The panel transformed light energy into electrical energy. Energy was not created — it just changed form.":
			"Panel itu telah mengubah tenaga cahaya kepada tenaga elektrik. Tenaga tidak dicipta — ia hanya berubah bentuk.",
		"Moving objects have kinetic energy. A raised gate stores potential energy; powering the puzzle lifts it, and gravity would pull it back down.":
			"Objek yang bergerak mempunyai tenaga kinetik. Pintu gerbang yang dinaikkan menyimpan tenaga keupayaan; menghidupkan teka-teki mengangkatnya, dan graviti akan menariknya kembali ke bawah.",
		"Pull the lever to open vents. Wind is moving air — kinetic energy. The turbine converts it to electrical energy.":
			"Tarik tuas untuk membuka lubang angin. Angin adalah udara yang bergerak — tenaga kinetik. Turbin menukarkannya kepada tenaga elektrik.",
		"Conservation of Energy: energy cannot be created or destroyed — only transformed between forms.":
			"Keabadian Tenaga: tenaga tidak boleh dicipta atau dimusnahkan — hanya berubah bentuk.",
		"Find energy orbs hidden in chests across the level, then bring them here. Press E at a generator and choose the matching energy from your inventory.":
			"Cari orb tenaga yang tersembunyi dalam peti di seluruh peringkat, kemudian bawanya ke sini. Tekan E pada penjana dan pilih tenaga yang sepadan daripada inventori anda.",
		"Magmatar, the Coal Tycoon, awaits. Defeat him to free the plant.":
			"Magmatar, Konglomerat Arang Batu, menunggu. Kalahkan dia untuk membebaskan kilang.",

		# ── Info boards — Level 9 (Earth) ────────────────────────────────────
		# Keys must match scenes/level_9_earth.tscn description strings verbatim
		# (including the " - " hyphen spacing) so the boards auto-translate.
		"Earth's gravity pulls everything down. With gravity ON the boulders rest on the ground. Flip the Gravity Switch to turn gravity OFF":
			"Graviti Bumi menarik segala-galanya ke bawah. Apabila graviti HIDUP, batu-batu besar berada di atas tanah. Tukar Suis Graviti untuk MEMATIKAN graviti",
		"Without gravity, objects float instead of falling - that is why astronauts and rocks drift in space. You used the floating boulders as steps to climb up and open the gate.":
			"Tanpa graviti, objek terapung dan bukannya jatuh - itulah sebabnya angkasawan dan batu hanyut di angkasa. Kamu menggunakan batu-batu terapung sebagai tangga untuk memanjat naik dan membuka pintu gerbang.",
		"Earth spins (rotates) on its axis, so day turns to night. As you travel east, night is falling - creatures of the dark roam and the gate ahead is shut. Rest in the shelter to let time pass. When the Sun rises again, daylight opens the path and burns away the night creatures!":
			"Bumi berputar pada paksinya, jadi siang bertukar menjadi malam. Sambil kamu mengembara ke timur, malam pun tiba - makhluk kegelapan berkeliaran dan pintu gerbang di hadapan tertutup. Berehat di tempat perlindungan untuk membiarkan masa berlalu. Apabila Matahari terbit semula, cahaya siang membuka laluan dan menghapuskan makhluk malam!",
		"As Earth rotates, the side facing the Sun has day and the side turned away has night. The Sun seems to rise in the East and set in the West.":
			"Apabila Bumi berputar, bahagian yang menghadap Matahari mengalami siang dan bahagian yang membelakanginya mengalami malam. Matahari kelihatan terbit di Timur dan terbenam di Barat.",
		"The Void Sentinel guards the way home. Answer its questions about Earth to defeat it.":
			"Pengawal Lompang menjaga jalan pulang. Jawab soalannya tentang Bumi untuk mengalahkannya.",
		"The Moon makes no light of its own - it shines by reflecting sunlight. As the Moon orbits Earth we see different lit shapes called phases. Press E at the telescope, aim to find the Moon, and watch it change. Confirm when the Full Moon is centred!":
			"Bulan tidak menghasilkan cahayanya sendiri - ia bersinar dengan memantulkan cahaya matahari. Ketika Bulan mengorbit Bumi, kita melihat bentuk bercahaya yang berbeza dipanggil fasa. Tekan E pada teleskop, halakan untuk mencari Bulan, dan perhatikan ia berubah. Sahkan apabila Bulan Penuh berada di tengah!",
		"A Full Moon happens when the Moon is on the opposite side of Earth from the Sun, so we see its whole lit face. Match the Full Moon to open the gate.":
			"Bulan Penuh berlaku apabila Bulan berada di sisi Bumi yang bertentangan dengan Matahari, jadi kita melihat seluruh permukaannya yang bercahaya. Padankan Bulan Penuh untuk membuka pintu gerbang.",

		# ── Info boards — Level 10 (Machines) ────────────────────────────────
		"SIMPLE MACHINES\nEveryday problems are solved by simple machines.\nThis see-saw is a LEVER. Hop on the LEFT arm and press E -\na heavy boulder drops on the far side and CATAPULTS you up!":
			"MESIN MUDAH\nMasalah harian diselesaikan dengan mesin mudah.\nJongkang-jongket ini ialah TUAS. Naik lengan KIRI dan tekan E -\nbatu besar jatuh di hujung sebelah dan MELAMBUNG kamu ke atas!",
		"EASIER AND FASTER\nOne machine helps. MORE machines together make\nwork even easier and faster. Ride the pulley\nplatform up, then deploy the ramp!":
			"LEBIH MUDAH DAN CEPAT\nSatu mesin membantu. LEBIH banyak mesin bersama\nmenjadikan kerja lebih mudah dan cepat. Naik platform\ntakal, kemudian turunkan tanjakan!",
		"COMPLEX MACHINE: SCISSORS\nA complex machine combines more than one simple\nmachine. Scissors = SCREW + WEDGE.":
			"MESIN KOMPLEKS: GUNTING\nMesin kompleks menggabungkan lebih daripada satu\nmesin mudah. Gunting = SKRU + BAJI.",
		"COMPLEX MACHINE: AXE\nAxe = LEVER + WEDGE.\nThe handle is the lever, the blade is the wedge.":
			"MESIN KOMPLEKS: KAPAK\nKapak = TUAS + BAJI.\nPemegang ialah tuas, mata ialah baji.",
		"MORE COMPLEX MACHINES\nWheelbarrow = LEVER + SCREW + WHEEL AND AXLE.\nLadder = INCLINED PLANE + SCREW.":
			"LAGI MESIN KOMPLEKS\nKereta sorong = TUAS + SKRU + RODA DAN GANDAR.\nTangga = SATAH CONDONG + SKRU.",
		"SUSTAINABLE MACHINES\nBicycle = GEAR + SCREW + WHEEL AND AXLE.\nIt is durable, cost-effective, easy and safe to use,\nneeds NO fossil fuel and makes NO pollution!":
			"MESIN LESTARI\nBasikal = GEAR + SKRU + RODA DAN GANDAR.\nIa tahan lasak, jimat kos, mudah dan selamat digunakan,\nTIDAK perlu bahan api fosil dan TIDAK mencemarkan alam!",
		"BUILD THE COMPLEX MACHINE\nSwitch on the LEVER, PULLEY, GEARS and RAMP\nstations. Many simple machines working together\nmake ONE complex machine. Power it up!":
			"BINA MESIN KOMPLEKS\nHidupkan stesen TUAS, TAKAL, GEAR dan TANJAKAN.\nBanyak mesin mudah bekerjasama menjadi SATU\nmesin kompleks. Hidupkannya!",

		# ── Machine assembly finale (Level 10) ───────────────────────────────
		"SYSTEMS ONLINE": "SISTEM AKTIF",
		"MACHINE ASSEMBLED!": "MESIN SIAP DIBINA!",
	}
