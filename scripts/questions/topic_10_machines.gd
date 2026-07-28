extends RefCounted
class_name Topic10Machines

# KSSR Year 4 Science — Topic 10.2.2 & 10.2.3 (Machines).
# Level 10 has no boss battle, and question_bank.gd only serves "easy" and
# "medium" questions to regular enemies — so this bank intentionally contains
# no "hard" questions (they would never be shown).
static var questions: Array[Dictionary] = [
	# ── 10.2.2 — Simple machines solve everyday problems ─────────────────────
	{
		"question": "A worker needs to move a heavy box up onto a lorry. Which simple machine solves this problem best?",
		"question_ms": "Seorang pekerja perlu memindahkan kotak berat ke atas lori. Mesin mudah yang manakah paling sesuai untuk menyelesaikan masalah ini?",
		"options": ["A wedge", "An inclined plane (ramp)", "A screw", "Scissors"],
		"options_ms": ["Baji", "Satah condong (tanjakan)", "Skru", "Gunting"],
		"correct": 1,
		"explanation": "Everyday problems can be solved using simple machines. A ramp (inclined plane) lets the worker push the heavy box up with less effort instead of lifting it.",
		"explanation_ms": "Masalah harian boleh diselesaikan menggunakan mesin mudah. Tanjakan (satah condong) membolehkan pekerja menolak kotak berat ke atas dengan daya yang kurang berbanding mengangkatnya.",
		"difficulty": "easy"
	},
	{
		"question": "Why do we use simple machines to solve everyday problems?",
		"question_ms": "Mengapakah kita menggunakan mesin mudah untuk menyelesaikan masalah harian?",
		"options": ["They make work easier and faster", "They make work slower but safer", "They look nice", "They use a lot of electricity"],
		"options_ms": ["Ia menjadikan kerja lebih mudah dan cepat", "Ia menjadikan kerja lebih lambat tetapi selamat", "Ia kelihatan cantik", "Ia menggunakan banyak elektrik"],
		"correct": 0,
		"explanation": "Simple machines help us solve everyday problems by making work easier and faster to do.",
		"explanation_ms": "Mesin mudah membantu kita menyelesaikan masalah harian dengan menjadikan kerja lebih mudah dan cepat dilakukan.",
		"difficulty": "easy"
	},
	{
		"question": "A worker uses a trolley AND a ramp together to move boxes. Compared to using only one machine, the work becomes...",
		"question_ms": "Seorang pekerja menggunakan troli DAN tanjakan bersama-sama untuk memindahkan kotak. Berbanding menggunakan satu mesin sahaja, kerja itu menjadi...",
		"options": ["Harder and slower", "Even easier and faster", "Exactly the same", "Impossible to do"],
		"options_ms": ["Lebih susah dan lambat", "Lebih mudah dan cepat lagi", "Sama sahaja", "Mustahil dilakukan"],
		"correct": 1,
		"explanation": "The more simple machines used, the easier and faster work can be done. Combining the trolley and the ramp makes the job even easier.",
		"explanation_ms": "Semakin banyak mesin mudah digunakan, semakin mudah dan cepat kerja dapat dilakukan. Menggabungkan troli dan tanjakan menjadikan kerja itu lebih mudah lagi.",
		"difficulty": "medium"
	},
	{
		"question": "Lifting a pail of water from a deep well is hard work. Which simple machine solves this problem?",
		"question_ms": "Mengangkat baldi air dari perigi yang dalam adalah kerja yang susah. Mesin mudah yang manakah menyelesaikan masalah ini?",
		"options": ["A pulley", "A wedge", "A screw", "An axe"],
		"options_ms": ["Takal", "Baji", "Skru", "Kapak"],
		"correct": 0,
		"explanation": "A pulley changes the direction of the force — you pull the rope down and the pail of water rises up easily.",
		"explanation_ms": "Takal mengubah arah daya — anda menarik tali ke bawah dan baldi air naik ke atas dengan mudah.",
		"difficulty": "medium"
	},
	# ── 10.2.3 — Complex machine definition ──────────────────────────────────
	{
		"question": "What is a complex machine?",
		"question_ms": "Apakah mesin kompleks?",
		"options": ["A machine that is very big", "A machine that uses petrol", "A combination of more than one simple machine", "A machine with a computer inside"],
		"options_ms": ["Mesin yang sangat besar", "Mesin yang menggunakan petrol", "Gabungan lebih daripada satu mesin mudah", "Mesin yang mempunyai komputer di dalamnya"],
		"correct": 2,
		"explanation": "A tool that consists of a combination of more than one simple machine is called a complex machine.",
		"explanation_ms": "Alat yang terdiri daripada gabungan lebih daripada satu mesin mudah dipanggil mesin kompleks.",
		"difficulty": "easy"
	},
	{
		"question": "Which of these is a complex machine?",
		"question_ms": "Antara berikut, yang manakah mesin kompleks?",
		"options": ["A ramp", "A bicycle", "A single pulley on a flagpole", "A door wedge"],
		"options_ms": ["Tanjakan", "Basikal", "Takal tunggal pada tiang bendera", "Baji pintu"],
		"correct": 1,
		"explanation": "A bicycle combines several simple machines (gear, screw, wheel and axle), so it is a complex machine. The others are single simple machines.",
		"explanation_ms": "Basikal menggabungkan beberapa mesin mudah (gear, skru, roda dan gandar), jadi ia adalah mesin kompleks. Yang lain hanyalah mesin mudah tunggal.",
		"difficulty": "medium"
	},
	{
		"question": "A tool that is made of only ONE simple machine is called...",
		"question_ms": "Alat yang diperbuat daripada SATU mesin mudah sahaja dipanggil...",
		"options": ["A complex machine", "A simple machine", "A sustainable machine", "An engine"],
		"options_ms": ["Mesin kompleks", "Mesin mudah", "Mesin lestari", "Enjin"],
		"correct": 1,
		"explanation": "A complex machine must combine MORE than one simple machine. A tool with only one is just a simple machine.",
		"explanation_ms": "Mesin kompleks mesti menggabungkan LEBIH daripada satu mesin mudah. Alat dengan satu sahaja hanyalah mesin mudah.",
		"difficulty": "medium"
	},
	# ── 10.2.3 — Component breakdowns of complex machines ────────────────────
	{
		"question": "An axe is a complex machine made of which simple machines?",
		"question_ms": "Kapak ialah mesin kompleks yang diperbuat daripada mesin mudah yang manakah?",
		"options": ["Lever and wedge", "Pulley and screw", "Gear and wheel", "Inclined plane and pulley"],
		"options_ms": ["Tuas dan baji", "Takal dan skru", "Gear dan roda", "Satah condong dan takal"],
		"correct": 0,
		"explanation": "An axe combines a lever (the handle) and a wedge (the sharp blade that splits wood).",
		"explanation_ms": "Kapak menggabungkan tuas (pemegang) dan baji (mata tajam yang membelah kayu).",
		"difficulty": "easy"
	},
	{
		"question": "Scissors are a complex machine that combines which simple machines?",
		"question_ms": "Gunting ialah mesin kompleks yang menggabungkan mesin mudah yang manakah?",
		"options": ["Pulley and gear", "Screw and wedge", "Inclined plane and wheel", "Gear and wedge"],
		"options_ms": ["Takal dan gear", "Skru dan baji", "Satah condong dan roda", "Gear dan baji"],
		"correct": 1,
		"explanation": "Scissors combine a screw (the pivot joining the two blades) and wedges (the sharp cutting blades).",
		"explanation_ms": "Gunting menggabungkan skru (pangsi yang mencantumkan dua bilah) dan baji (bilah pemotong yang tajam).",
		"difficulty": "medium"
	},
	{
		"question": "A wheelbarrow is a complex machine made of which simple machines?",
		"question_ms": "Kereta sorong ialah mesin kompleks yang diperbuat daripada mesin mudah yang manakah?",
		"options": ["Lever, screw, and wheel and axle", "Wedge, pulley, and gear", "Inclined plane only", "Pulley and screw only"],
		"options_ms": ["Tuas, skru, serta roda dan gandar", "Baji, takal, dan gear", "Satah condong sahaja", "Takal dan skru sahaja"],
		"correct": 0,
		"explanation": "A wheelbarrow combines a lever (the handles), screws (holding it together), and a wheel and axle (to roll the load).",
		"explanation_ms": "Kereta sorong menggabungkan tuas (pemegang), skru (yang mencantumkannya), serta roda dan gandar (untuk menggerakkan beban).",
		"difficulty": "medium"
	},
	{
		"question": "A ladder is a complex machine that combines which simple machines?",
		"question_ms": "Tangga ialah mesin kompleks yang menggabungkan mesin mudah yang manakah?",
		"options": ["Pulley and gear", "Lever and wheel", "Inclined plane and screw", "Wedge and pulley"],
		"options_ms": ["Takal dan gear", "Tuas dan roda", "Satah condong dan skru", "Baji dan takal"],
		"correct": 2,
		"explanation": "A ladder or stairs combines an inclined plane (the slope you climb) and screws (that hold the parts together).",
		"explanation_ms": "Tangga menggabungkan satah condong (cerun yang anda naiki) dan skru (yang memegang bahagian-bahagiannya).",
		"difficulty": "medium"
	},
	{
		"question": "A bicycle is a complex machine made of which simple machines?",
		"question_ms": "Basikal ialah mesin kompleks yang diperbuat daripada mesin mudah yang manakah?",
		"options": ["Wedge, lever, and pulley", "Gear, screw, and wheel and axle", "Inclined plane and wedge", "Pulley and inclined plane"],
		"options_ms": ["Baji, tuas, dan takal", "Gear, skru, serta roda dan gandar", "Satah condong dan baji", "Takal dan satah condong"],
		"correct": 1,
		"explanation": "A bicycle combines gears (to drive the chain), screws (to hold parts together), and wheels and axles (to roll).",
		"explanation_ms": "Basikal menggabungkan gear (untuk memutar rantai), skru (untuk mencantumkan bahagian), serta roda dan gandar (untuk bergerak).",
		"difficulty": "medium"
	},
	{
		"question": "Which simple machine is found in BOTH an axe and a pair of scissors?",
		"question_ms": "Mesin mudah yang manakah terdapat pada KEDUA-DUA kapak dan gunting?",
		"options": ["Pulley", "Gear", "Wheel and axle", "Wedge"],
		"options_ms": ["Takal", "Gear", "Roda dan gandar", "Baji"],
		"correct": 3,
		"explanation": "Both the axe blade and the scissor blades are wedges — they split or cut materials apart.",
		"explanation_ms": "Kedua-dua mata kapak dan bilah gunting ialah baji — ia membelah atau memotong bahan.",
		"difficulty": "easy"
	},
	# ── 10.2.3 — Sustainable machines ────────────────────────────────────────
	{
		"question": "Which of these is NOT a characteristic of a sustainable machine?",
		"question_ms": "Antara berikut, yang manakah BUKAN ciri mesin lestari?",
		"options": ["Durable and not easily broken", "Cost-effective", "Causes pollution to the environment", "Easy and safe to use"],
		"options_ms": ["Tahan lasak dan tidak mudah rosak", "Menjimatkan kos", "Menyebabkan pencemaran kepada alam sekitar", "Mudah dan selamat digunakan"],
		"correct": 2,
		"explanation": "A sustainable machine must NOT cause adverse effects to the environment. It should be durable, cost-effective, and easy and safe to use.",
		"explanation_ms": "Mesin lestari TIDAK boleh menyebabkan kesan buruk kepada alam sekitar. Ia mestilah tahan lasak, menjimatkan kos, serta mudah dan selamat digunakan.",
		"difficulty": "easy"
	},
	{
		"question": "Why is a bicycle an example of a sustainable machine?",
		"question_ms": "Mengapakah basikal merupakan contoh mesin lestari?",
		"options": ["It can move at a very fast speed", "It does not need fossil fuels and does not pollute the environment", "It is built from strong metal parts", "It has many different gears"],
		"options_ms": ["Ia boleh bergerak pada kelajuan yang sangat tinggi", "Ia tidak memerlukan bahan api fosil dan tidak mencemarkan alam sekitar", "Ia diperbuat daripada bahagian logam yang kuat", "Ia mempunyai banyak gear berbeza"],
		"correct": 1,
		"explanation": "A bicycle is easy to use and does not require fossil fuels to move, so it will not pollute the environment.",
		"explanation_ms": "Basikal mudah digunakan dan tidak memerlukan bahan api fosil untuk bergerak, jadi ia tidak akan mencemarkan alam sekitar.",
		"difficulty": "easy"
	},
	{
		"question": "A better complex machine is one that is...",
		"question_ms": "Mesin kompleks yang lebih baik ialah mesin yang...",
		"options": ["Durable, cost-effective, environmentally friendly, and safe to use", "Big, heavy, expensive, and powerful", "Fast, loud, and shiny", "New, imported, and complicated"],
		"options_ms": ["Tahan lasak, menjimatkan kos, mesra alam, dan selamat digunakan", "Besar, berat, mahal, dan berkuasa", "Laju, bising, dan berkilat", "Baharu, diimport, dan rumit"],
		"correct": 0,
		"explanation": "A better complex machine has sustainable characteristics: durable, not easily broken, cost-effective, environmentally friendly, and easy and safe to use.",
		"explanation_ms": "Mesin kompleks yang lebih baik mempunyai ciri lestari: tahan lasak, tidak mudah rosak, menjimatkan kos, mesra alam, serta mudah dan selamat digunakan.",
		"difficulty": "medium"
	},
	{
		"question": "Riding a bicycle instead of taking a car helps the environment because...",
		"question_ms": "Menunggang basikal berbanding menaiki kereta membantu alam sekitar kerana...",
		"options": ["The bicycle releases no smoke or pollution", "The bicycle is cheaper to buy", "The bicycle is smaller", "The bicycle can go anywhere"],
		"options_ms": ["Basikal tidak mengeluarkan asap atau pencemaran", "Basikal lebih murah untuk dibeli", "Basikal lebih kecil", "Basikal boleh pergi ke mana-mana sahaja"],
		"correct": 0,
		"explanation": "A bicycle does not burn fossil fuels, so it releases no smoke and does not pollute the environment like a car does.",
		"explanation_ms": "Basikal tidak membakar bahan api fosil, jadi ia tidak mengeluarkan asap dan tidak mencemarkan alam sekitar seperti kereta.",
		"difficulty": "easy"
	},
	{
		"question": "Which machine is the most environmentally friendly choice for travelling to a school nearby?",
		"question_ms": "Mesin yang manakah pilihan paling mesra alam untuk pergi ke sekolah yang berdekatan?",
		"options": ["A motorcycle", "A car", "A bicycle", "A bus"],
		"options_ms": ["Motosikal", "Kereta", "Basikal", "Bas"],
		"correct": 2,
		"explanation": "A bicycle is a sustainable machine — it needs no fossil fuel, makes no pollution, and is easy and safe to use for short trips.",
		"explanation_ms": "Basikal ialah mesin lestari — ia tidak memerlukan bahan api fosil, tidak menghasilkan pencemaran, serta mudah dan selamat digunakan untuk perjalanan dekat.",
		"difficulty": "medium"
	},
]
