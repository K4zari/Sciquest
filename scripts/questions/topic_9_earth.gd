extends RefCounted
class_name Topic9Earth

static var questions: Array[Dictionary] = [
	# --- Earth's gravity (9.1) — the focus of Zone A ---
	{
		"question": "What force pulls objects down toward the centre of the Earth?",
		"question_ms": "Daya apakah yang menarik objek ke bawah menuju pusat Bumi?",
		"options": ["Magnetism", "Gravity", "Wind", "Friction"],
		"options_ms": ["Kemagnetan", "Graviti", "Angin", "Geseran"],
		"correct": 1,
		"explanation": "Earth's gravity is the force that pulls every object towards the centre of the Earth. It is why things fall down instead of floating.",
		"explanation_ms": "Graviti Bumi adalah daya yang menarik setiap objek menuju pusat Bumi. Itulah sebab benda-benda jatuh ke bawah dan bukannya terapung.",
		"difficulty": "easy"
	},
	{
		"question": "Why would astronauts float if there were no gravity?",
		"question_ms": "Mengapakah angkasawan akan terapung jika tiada graviti?",
		"options": ["Because nothing would pull them down to the ground", "Because they are far too light to stay down", "Because space is full of water", "Because they wear balloons filled with air"],
		"options_ms": ["Kerana tiada apa-apa yang akan menarik mereka ke bawah ke tanah", "Kerana mereka terlalu ringan untuk kekal di bawah", "Kerana angkasa penuh dengan air", "Kerana mereka memakai belon berisi udara"],
		"correct": 0,
		"explanation": "Gravity keeps objects in their place on the ground. Without a gravitational pull, objects (and astronauts) would simply float away.",
		"explanation_ms": "Graviti mengekalkan objek di tempat mereka di atas tanah. Tanpa daya graviti, objek (dan angkasawan) akan terapung begitu sahaja.",
		"difficulty": "medium"
	},
	{
		"question": "An object thrown straight up into the air will...",
		"question_ms": "Objek yang dicampak lurus ke atas akan...",
		"options": ["Keep going up forever", "Fall back down because of gravity", "Float in the air", "Disappear"],
		"options_ms": ["Terus naik selama-lamanya", "Jatuh kembali ke bawah kerana graviti", "Terapung di udara", "Hilang"],
		"correct": 1,
		"explanation": "Earth's gravitational pull brings the object back down — every object thrown upwards falls back towards the Earth.",
		"explanation_ms": "Daya tarikan graviti Bumi membawa objek itu kembali ke bawah — setiap objek yang dicampak ke atas akan jatuh kembali menuju Bumi.",
		"difficulty": "easy"
	},
	{
		"question": "Why is Earth's gravitational pull important?",
		"question_ms": "Mengapakah daya tarikan graviti Bumi penting?",
		"options": ["It makes the Sun shine", "It keeps objects in their positions on Earth", "It causes rain", "It creates wind"],
		"options_ms": ["Ia menyebabkan Matahari bersinar", "Ia mengekalkan objek pada kedudukan mereka di Bumi", "Ia menyebabkan hujan", "Ia menghasilkan angin"],
		"correct": 1,
		"explanation": "Gravity keeps objects in their positions and stops them from floating away into space.",
		"explanation_ms": "Graviti mengekalkan objek pada kedudukan mereka dan menghalangnya daripada terapung ke angkasa.",
		"difficulty": "hard"
	},
	# --- Rotation, revolution, day & night (9.2) — the focus of Zone B ---
	{
		"question": "What causes day and night on Earth?",
		"question_ms": "Apakah yang menyebabkan siang dan malam di Bumi?",
		"options": ["Earth revolving around the Sun", "The Moon blocking sunlight", "Earth rotating on its axis", "Clouds covering the Sun"],
		"options_ms": ["Bumi beredar mengelilingi Matahari", "Bulan menghalang cahaya matahari", "Bumi berputar pada paksinya", "Awan menutup Matahari"],
		"correct": 2,
		"explanation": "Earth rotates (spins) on its axis once every 24 hours. The side facing the Sun has day; the side facing away has night.",
		"explanation_ms": "Bumi berputar pada paksinya sekali setiap 24 jam. Bahagian yang menghadap Matahari mengalami siang; bahagian yang membelakanginya mengalami malam.",
		"difficulty": "hard"
	},
	{
		"question": "In which direction does Earth rotate on its axis?",
		"question_ms": "Ke arah manakah Bumi berputar pada paksinya?",
		"options": ["East to West", "West to East", "North to South", "It does not rotate"],
		"options_ms": ["Timur ke Barat", "Barat ke Timur", "Utara ke Selatan", "Ia tidak berputar"],
		"correct": 1,
		"explanation": "Earth rotates on its axis from West to East, which is why the Sun appears to rise in the East.",
		"explanation_ms": "Bumi berputar pada paksinya dari Barat ke Timur, itulah sebab Matahari kelihatan terbit di Timur.",
		"difficulty": "hard"
	},
	{
		"question": "How long does Earth take to make one full rotation on its axis?",
		"question_ms": "Berapa lamakah masa yang diambil oleh Bumi untuk membuat satu pusingan penuh pada paksinya?",
		"options": ["1 hour", "24 hours (1 day)", "1 week", "365 days"],
		"options_ms": ["1 jam", "24 jam (1 hari)", "1 minggu", "365 hari"],
		"correct": 1,
		"explanation": "One complete rotation of Earth on its axis takes 24 hours, which is one day.",
		"explanation_ms": "Satu pusingan penuh Bumi pada paksinya mengambil masa 24 jam, iaitu satu hari.",
		"difficulty": "easy"
	},
	{
		"question": "Because Earth rotates, the Sun appears to rise in the ___ and set in the ___.",
		"question_ms": "Kerana Bumi berputar, Matahari kelihatan terbit di ___ dan terbenam di ___.",
		"options": ["West; East", "North; South", "East; West", "South; North"],
		"options_ms": ["Barat; Timur", "Utara; Selatan", "Timur; Barat", "Selatan; Utara"],
		"correct": 2,
		"explanation": "As Earth spins from West to East, the Sun appears to rise in the East and set in the West.",
		"explanation_ms": "Apabila Bumi berputar dari Barat ke Timur, Matahari kelihatan terbit di Timur dan terbenam di Barat.",
		"difficulty": "hard"
	},
	{
		"question": "How long does it take Earth to orbit (go around) the Sun once?",
		"question_ms": "Berapa lamakah masa yang diambil oleh Bumi untuk mengorbit (mengelilingi) Matahari sekali?",
		"options": ["24 hours", "1 month", "365 days (1 year)", "7 days"],
		"options_ms": ["24 jam", "1 bulan", "365 hari (1 tahun)", "7 hari"],
		"correct": 2,
		"explanation": "Earth takes approximately 365 days (one year) to complete one full orbit around the Sun.",
		"explanation_ms": "Bumi mengambil masa lebih kurang 365 hari (satu tahun) untuk melengkapkan satu orbit penuh mengelilingi Matahari.",
		"difficulty": "medium"
	},
	{
		"question": "What is the imaginary line that Earth spins around called?",
		"question_ms": "Apakah nama garisan khayalan yang diputar oleh Bumi?",
		"options": ["The equator line", "The orbit path", "The axis", "The horizon line"],
		"options_ms": ["Khatulistiwa", "Orbit", "Paksi", "Ufuk"],
		"correct": 2,
		"explanation": "The axis is an imaginary line connecting the North Pole and the South Pole, and Earth rotates around it.",
		"explanation_ms": "Paksi adalah garisan khayalan yang menghubungkan Kutub Utara dan Kutub Selatan, dan Bumi berputar mengelilinginya.",
		"difficulty": "medium"
	},
	{
		"question": "What causes seasons on Earth?",
		"question_ms": "Apakah yang menyebabkan musim di Bumi?",
		"options": ["Earth's changing distance from the Sun", "Earth's tilt on its axis as it orbits the Sun", "The gravitational pull of the Moon", "Global wind and weather patterns"],
		"options_ms": ["Perubahan jarak Bumi daripada Matahari", "Kecondongan paksi Bumi semasa mengorbit Matahari", "Daya tarikan graviti Bulan", "Corak angin dan cuaca global"],
		"correct": 1,
		"explanation": "Seasons are caused by Earth's tilted axis (23.5 degrees). As Earth orbits the Sun, different parts receive more direct sunlight at different times of year.",
		"explanation_ms": "Musim disebabkan oleh paksi Bumi yang condong (23.5 darjah). Semasa Bumi mengorbit Matahari, bahagian yang berbeza menerima cahaya matahari yang lebih terus pada waktu yang berbeza dalam setahun.",
		"difficulty": "hard"
	},
	# --- Wider Earth science (shape, layers, rocks, soil, water, planets) ---
	{
		"question": "What is the shape of the Earth?",
		"question_ms": "Apakah bentuk Bumi?",
		"options": ["A perfectly round sphere", "A flat circular disc", "Slightly flattened sphere (oblate spheroid)", "A cube with sharp corners"],
		"options_ms": ["Sfera yang sempurna bulat", "Cakera bulat yang rata", "Sfera yang sedikit gepeng (sferoid oblet)", "Kiub bersudut tajam"],
		"correct": 2,
		"explanation": "Earth is not a perfect sphere — it bulges slightly at the equator and is flattened at the poles, making it an oblate spheroid.",
		"explanation_ms": "Bumi bukan sfera yang sempurna — ia sedikit membesar di khatulistiwa dan gepeng di kutub, menjadikannya sferoid oblet.",
		"difficulty": "medium"
	},
	{
		"question": "Which layer is the outermost solid layer of the Earth?",
		"question_ms": "Lapisan manakah yang merupakan lapisan pepejal paling luar Bumi?",
		"options": ["Mantle", "Core", "Crust", "Outer core"],
		"options_ms": ["Mantel", "Teras", "Kerak", "Teras luar"],
		"correct": 2,
		"explanation": "The crust is the thin, outermost solid layer of Earth. It is where we live, and it includes the land and ocean floor.",
		"explanation_ms": "Kerak adalah lapisan pepejal paling nipis dan paling luar Bumi. Inilah tempat kita tinggal, dan ia merangkumi daratan dan dasar lautan.",
		"difficulty": "easy"
	},
	{
		"question": "What is the hottest layer of the Earth?",
		"question_ms": "Apakah lapisan Bumi yang paling panas?",
		"options": ["Crust", "Mantle", "Outer core", "Inner core"],
		"options_ms": ["Kerak", "Mantel", "Teras luar", "Teras dalam"],
		"correct": 3,
		"explanation": "The inner core is the hottest part of the Earth, reaching temperatures of about 5,000-6,000 degrees Celsius.",
		"explanation_ms": "Teras dalam adalah bahagian Bumi yang paling panas, mencapai suhu sekitar 5,000-6,000 darjah Celsius.",
		"difficulty": "medium"
	},
	{
		"question": "Sedimentary rocks are formed by...",
		"question_ms": "Batu enapan terbentuk oleh...",
		"options": ["Cooling magma", "Heat and pressure on existing rocks", "Layers of sediment compressing over time", "Volcanic eruptions only"],
		"options_ms": ["Magma yang menyejuk", "Haba dan tekanan pada batu sedia ada", "Lapisan enapan yang dimampatkan lama-kelamaan", "Letusan gunung berapi sahaja"],
		"correct": 2,
		"explanation": "Sedimentary rocks form when layers of sediment (sand, mud, shells) are deposited and slowly compacted over millions of years.",
		"explanation_ms": "Batu enapan terbentuk apabila lapisan enapan (pasir, lumpur, cengkerang) didepositkan dan dimampatkan secara perlahan selama jutaan tahun.",
		"difficulty": "medium"
	},
	{
		"question": "What is soil made of?",
		"question_ms": "Apakah bahan penyusun tanah?",
		"options": ["Only crushed rock fragments", "Weathered rock, minerals, humus, water, and air", "Only fine grains of sand", "Only soft, pure clay"],
		"options_ms": ["Hanya serpihan batu hancur", "Batu luluk, mineral, humus, air, dan udara", "Hanya butiran pasir halus", "Hanya tanah liat lembut tulen"],
		"correct": 1,
		"explanation": "Soil is a mixture of weathered rock particles, minerals, humus (decayed organic matter), water, and air.",
		"explanation_ms": "Tanah adalah campuran zarah batu luluk, mineral, humus (bahan organik reput), air, dan udara.",
		"difficulty": "easy"
	},
	{
		"question": "What causes erosion?",
		"question_ms": "Apakah yang menyebabkan hakisan?",
		"options": ["Plants growing across the land", "Wind, water, and ice wearing away rock and soil", "Only sudden earthquakes shaking", "Animals digging in the ground"],
		"options_ms": ["Tumbuhan tumbuh di atas tanah", "Angin, air, dan ais yang menghakis batu dan tanah", "Hanya gegaran gempa bumi", "Haiwan menggali di dalam tanah"],
		"correct": 1,
		"explanation": "Erosion is the process where wind, water, and ice gradually wear away and carry off rock and soil.",
		"explanation_ms": "Hakisan adalah proses di mana angin, air, dan ais secara beransur-ansur menghakis dan membawa pergi batu serta tanah.",
		"difficulty": "easy"
	},
	{
		"question": "Which step of the water cycle involves water turning into water vapour?",
		"question_ms": "Langkah manakah dalam kitaran air yang melibatkan air bertukar menjadi wap air?",
		"options": ["Condensation", "Precipitation", "Evaporation", "Collection"],
		"options_ms": ["Pemeluwapan", "Kerpasan", "Penyejatan", "Pengumpulan"],
		"correct": 2,
		"explanation": "Evaporation is when liquid water is heated by the Sun and turns into water vapour (gas) that rises into the atmosphere.",
		"explanation_ms": "Penyejatan adalah apabila air cecair dipanaskan oleh Matahari dan bertukar menjadi wap air (gas) yang naik ke atmosfera.",
		"difficulty": "medium"
	},
	{
		"question": "Which planet is closest to the Sun?",
		"question_ms": "Planet manakah yang paling dekat dengan Matahari?",
		"options": ["Venus", "Earth", "Mars", "Mercury"],
		"options_ms": ["Zuhrah", "Bumi", "Marikh", "Utarid"],
		"correct": 3,
		"explanation": "Mercury is the closest planet to the Sun. Because of this, it has extreme temperature differences between day and night.",
		"explanation_ms": "Utarid adalah planet yang paling dekat dengan Matahari. Oleh sebab itu, ia mempunyai perbezaan suhu yang melampau antara siang dan malam.",
		"difficulty": "easy"
	},
	{
		"question": "Which gas makes up most of Earth's atmosphere?",
		"question_ms": "Gas apakah yang membentuk sebahagian besar atmosfera Bumi?",
		"options": ["Oxygen", "Carbon dioxide", "Nitrogen", "Hydrogen"],
		"options_ms": ["Oksigen", "Karbon dioksida", "Nitrogen", "Hidrogen"],
		"correct": 2,
		"explanation": "Earth's atmosphere is about 78% nitrogen and 21% oxygen. The remaining 1% includes carbon dioxide and other gases.",
		"explanation_ms": "Atmosfera Bumi mengandungi lebih kurang 78% nitrogen dan 21% oksigen. Baki 1% termasuk karbon dioksida dan gas-gas lain.",
		"difficulty": "medium"
	},
	{
		"question": "What is a fossil?",
		"question_ms": "Apakah fosil?",
		"options": ["A shiny mineral found underground", "Preserved remains or traces of ancient organisms in rock", "A special kind of garden soil", "A rock formed by a volcano"],
		"options_ms": ["Sejenis mineral berkilat dalam tanah", "Sisa atau kesan organisma purba yang terpelihara dalam batu", "Sejenis tanah taman yang istimewa", "Batu yang terbentuk oleh gunung berapi"],
		"correct": 1,
		"explanation": "Fossils are preserved remains, imprints, or traces of ancient plants and animals found in sedimentary rock.",
		"explanation_ms": "Fosil adalah sisa, cap, atau kesan tumbuhan dan haiwan purba yang ditemui dalam batu enapan.",
		"difficulty": "easy"
	},
]
