extends RefCounted
class_name Topic4Plants

# Difficulty values: "easy", "medium", "hard".
# "hard" questions are reserved for boss enemies (is_boss == true).
# Regular enemies draw from "easy" + "medium" only.

static var questions: Array[Dictionary] = [
	# ── EASY / MEDIUM (regular enemies) ──────────────────────────────────────
	{
		"question": "Which part of the plant makes food using sunlight?",
		"question_ms": "Bahagian manakah pada tumbuhan yang menghasilkan makanan menggunakan cahaya matahari?",
		"options": ["Root", "Stem", "Leaf", "Flower"],
		"options_ms": ["Akar", "Batang", "Daun", "Bunga"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "Leaves make food for the plant using sunlight, water, and carbon dioxide — a process called photosynthesis.",
		"explanation_ms": "Daun menghasilkan makanan untuk tumbuhan menggunakan cahaya matahari, air, dan karbon dioksida — satu proses yang dipanggil fotosintesis."
	},
	{
		"question": "What do roots do for a plant?",
		"question_ms": "Apakah fungsi akar bagi tumbuhan?",
		"options": ["Make colourful flowers for bees", "Absorb water and minerals from soil", "Produce seeds for new plants", "Trap and digest small insects"],
		"options_ms": ["Menghasilkan bunga berwarna untuk lebah", "Menyerap air dan mineral daripada tanah", "Menghasilkan biji benih untuk tumbuhan baharu", "Memerangkap dan mencerna serangga kecil"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Roots anchor the plant in the soil and absorb water and minerals that the plant needs to grow.",
		"explanation_ms": "Akar mencengkam tumbuhan di dalam tanah dan menyerap air serta mineral yang diperlukan oleh tumbuhan untuk membesar."
	},
	{
		"question": "What does a plant need to make its own food?",
		"question_ms": "Apakah yang diperlukan oleh tumbuhan untuk menghasilkan makanannya sendiri?",
		"options": ["Moonlight and rain", "Sunlight, water, and carbon dioxide", "Soil, insects, and heat", "Oxygen and sugar"],
		"options_ms": ["Cahaya bulan dan hujan", "Cahaya matahari, air, dan karbon dioksida", "Tanah, serangga, dan haba", "Oksigen dan gula"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Plants use sunlight as energy, water from the soil, and carbon dioxide from the air to make food through photosynthesis.",
		"explanation_ms": "Tumbuhan menggunakan cahaya matahari sebagai tenaga, air daripada tanah, dan karbon dioksida daripada udara untuk menghasilkan makanan melalui fotosintesis."
	},
	{
		"question": "Which part of a plant carries water from the roots to the leaves?",
		"question_ms": "Bahagian manakah pada tumbuhan yang mengangkut air daripada akar ke daun?",
		"options": ["Flower", "Fruit", "Stem", "Seed"],
		"options_ms": ["Bunga", "Buah", "Batang", "Biji benih"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "The stem acts like a pipe, transporting water and minerals from the roots up to the leaves and other parts.",
		"explanation_ms": "Batang bertindak seperti paip, mengangkut air dan mineral daripada akar ke atas menuju daun dan bahagian-bahagian lain."
	},
	{
		"question": "What gas do plants release during photosynthesis?",
		"question_ms": "Gas apakah yang dibebaskan oleh tumbuhan semasa fotosintesis?",
		"options": ["Carbon dioxide", "Nitrogen", "Oxygen", "Hydrogen"],
		"options_ms": ["Karbon dioksida", "Nitrogen", "Oksigen", "Hidrogen"],
		"correct": 2,
		"difficulty": "medium",
		"explanation": "During photosynthesis, plants take in carbon dioxide and release oxygen — which is the air we breathe!",
		"explanation_ms": "Semasa fotosintesis, tumbuhan menyerap karbon dioksida dan membebaskan oksigen — iaitu udara yang kita hirup!"
	},
	{
		"question": "Which type of plant does NOT have roots, stems, or leaves?",
		"question_ms": "Jenis tumbuhan manakah yang TIDAK mempunyai akar, batang, atau daun?",
		"options": ["Fern", "Moss", "Rose", "Mango tree"],
		"options_ms": ["Paku pakis", "Lumut", "Mawar", "Pokok mangga"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Mosses are simple plants that do not have proper roots, stems, or leaves. They absorb water directly through their surface.",
		"explanation_ms": "Lumut adalah tumbuhan ringkas yang tidak mempunyai akar, batang, atau daun yang sebenar. Ia menyerap air terus melalui permukaannya."
	},
	{
		"question": "What is the main job of a flower?",
		"question_ms": "Apakah fungsi utama bunga?",
		"options": ["Absorb sunlight for the plant", "Make seeds for reproduction", "Store water inside the stem", "Carry minerals up the stem"],
		"options_ms": ["Menyerap cahaya matahari untuk tumbuhan", "Menghasilkan biji benih untuk pembiakan", "Menyimpan air di dalam batang", "Mengangkut mineral ke atas batang"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Flowers are the reproductive organs of a plant. They produce seeds that grow into new plants.",
		"explanation_ms": "Bunga adalah organ pembiakan tumbuhan. Ia menghasilkan biji benih yang akan tumbuh menjadi tumbuhan baharu."
	},
	{
		"question": "Which of these plants stores water in its stem?",
		"question_ms": "Tumbuhan manakah yang menyimpan air di dalam batangnya?",
		"options": ["Cactus", "Mushroom", "Fern", "Rice"],
		"options_ms": ["Kaktus", "Cendawan", "Paku pakis", "Padi"],
		"correct": 0,
		"difficulty": "easy",
		"explanation": "Cacti are adapted to dry deserts by storing water in their thick, fleshy stems.",
		"explanation_ms": "Kaktus telah menyesuaikan diri dengan persekitaran padang pasir yang kering dengan menyimpan air di dalam batangnya yang tebal dan berisi."
	},
	{
		"question": "A plant that loses its leaves during dry seasons is called...",
		"question_ms": "Tumbuhan yang menggugurkan daunnya semasa musim kemarau dipanggil...",
		"options": ["Evergreen", "Deciduous", "Aquatic", "Parasitic"],
		"options_ms": ["Tumbuhan malar hijau", "Tumbuhan luruh daun", "Tumbuhan akuatik", "Tumbuhan parasit"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Deciduous plants shed their leaves when there is not enough water, to reduce water loss.",
		"explanation_ms": "Tumbuhan luruh daun menggugurkan daunnya apabila bekalan air tidak mencukupi, bagi mengurangkan kehilangan air."
	},
	{
		"question": "Which part of the plant protects the seed?",
		"question_ms": "Bahagian manakah pada tumbuhan yang melindungi biji benih?",
		"options": ["Leaf", "Root", "Fruit", "Stem"],
		"options_ms": ["Daun", "Akar", "Buah", "Batang"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "The fruit develops from the flower and its main job is to protect the seed inside it.",
		"explanation_ms": "Buah terbentuk daripada bunga dan fungsi utamanya adalah untuk melindungi biji benih yang terdapat di dalamnya."
	},
	{
		"question": "What do we call plants that live in water?",
		"question_ms": "Apakah nama bagi tumbuhan yang hidup di dalam air?",
		"options": ["Desert plants", "Aquatic plants", "Parasitic plants", "Climbing plants"],
		"options_ms": ["Tumbuhan padang pasir", "Tumbuhan akuatik", "Tumbuhan parasit", "Tumbuhan memanjat"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Plants that live in water, such as water hyacinth and lotus, are called aquatic plants.",
		"explanation_ms": "Tumbuhan yang hidup di dalam air, seperti kiambang dan teratai, dipanggil tumbuhan akuatik."
	},
	{
		"question": "What type of plant is a fern?",
		"question_ms": "Apakah jenis tumbuhan paku pakis?",
		"options": ["Flowering plant", "Non-flowering plant", "Aquatic plant", "Parasitic plant"],
		"options_ms": ["Tumbuhan berbunga", "Tumbuhan tidak berbunga", "Tumbuhan akuatik", "Tumbuhan parasit"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Ferns are non-flowering plants. They reproduce using spores, not seeds or flowers.",
		"explanation_ms": "Paku pakis adalah tumbuhan tidak berbunga. Ia membiak menggunakan spora, bukan biji benih atau bunga."
	},
	{
		"question": "Why do leaves appear green?",
		"question_ms": "Mengapakah daun kelihatan berwarna hijau?",
		"options": ["They contain water", "They contain chlorophyll", "They reflect sunlight", "They absorb nitrogen"],
		"options_ms": ["Mengandungi air", "Mengandungi klorofil", "Memantulkan cahaya matahari", "Menyerap nitrogen"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Leaves contain a green pigment called chlorophyll, which absorbs sunlight for photosynthesis.",
		"explanation_ms": "Daun mengandungi pigmen hijau yang dipanggil klorofil, yang menyerap cahaya matahari untuk fotosintesis."
	},
	{
		"question": "Which of these is a flowering plant?",
		"question_ms": "Yang manakah merupakan tumbuhan berbunga?",
		"options": ["Moss", "Fern", "Hibiscus", "Mushroom"],
		"options_ms": ["Lumut", "Paku pakis", "Bunga raya", "Cendawan"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "Hibiscus is a flowering plant. Mosses and ferns do not produce flowers, and mushrooms are fungi, not plants.",
		"explanation_ms": "Bunga raya adalah tumbuhan berbunga. Lumut dan paku pakis tidak menghasilkan bunga, manakala cendawan adalah fungi, bukan tumbuhan."
	},
	{
		"question": "Where does a new plant come from?",
		"question_ms": "Dari manakah asal usul tumbuhan baharu?",
		"options": ["A leaf", "A seed", "A root", "A drop of water"],
		"options_ms": ["Daun", "Biji benih", "Akar", "Setitik air"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "A new plant grows from a seed in a process called germination.",
		"explanation_ms": "Tumbuhan baharu tumbuh daripada biji benih melalui satu proses yang dipanggil percambahan."
	},
	{
		"question": "What helps a climbing plant grow upward on a wall or pole?",
		"question_ms": "Apakah yang membantu tumbuhan memanjat tumbuh ke atas pada dinding atau tiang?",
		"options": ["Tendrils", "Roots", "Flowers", "Fruits"],
		"options_ms": ["Sulur", "Akar", "Bunga", "Buah"],
		"correct": 0,
		"difficulty": "medium",
		"explanation": "Climbing plants like passion fruit use tendrils — thin coiling stems — to wrap around supports and climb upward.",
		"explanation_ms": "Tumbuhan memanjat seperti markisa menggunakan sulur — batang nipis yang melingkar — untuk membelit penyangga dan memanjat ke atas."
	},
	{
		"question": "Which part of the plant grows below the ground?",
		"question_ms": "Bahagian manakah pada tumbuhan yang tumbuh di bawah tanah?",
		"options": ["Leaf", "Stem", "Root", "Flower"],
		"options_ms": ["Daun", "Batang", "Akar", "Bunga"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "Roots grow below the ground to anchor the plant and absorb water and minerals from the soil.",
		"explanation_ms": "Akar tumbuh di bawah tanah untuk mencengkam tumbuhan dan menyerap air serta mineral daripada tanah."
	},
	{
		"question": "What do bees and butterflies help plants do?",
		"question_ms": "Apakah yang dibantu oleh lebah dan rama-rama kepada tumbuhan?",
		"options": ["Photosynthesize", "Pollinate flowers", "Absorb water", "Grow taller"],
		"options_ms": ["Berfotosintesis", "Menyebuk bunga", "Menyerap air", "Membesar dengan lebih tinggi"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Bees and butterflies carry pollen from one flower to another. This pollination helps plants make seeds.",
		"explanation_ms": "Lebah dan rama-rama membawa debunga daripada satu bunga ke bunga yang lain. Pendebungaan ini membantu tumbuhan menghasilkan biji benih."
	},
	{
		"question": "Which plant grows from a bulb?",
		"question_ms": "Tumbuhan manakah yang tumbuh daripada bebawang?",
		"options": ["Onion", "Mango", "Banana", "Coconut"],
		"options_ms": ["Bawang", "Mangga", "Pisang", "Kelapa"],
		"correct": 0,
		"difficulty": "medium",
		"explanation": "Onions grow from bulbs — short underground stems with fleshy leaves that store food.",
		"explanation_ms": "Bawang tumbuh daripada bebawang — batang pendek bawah tanah dengan daun berisi yang menyimpan makanan."
	},
	{
		"question": "What do leaves give off through tiny holes called stomata?",
		"question_ms": "Apakah yang dibebaskan oleh daun melalui liang-liang kecil yang dipanggil stomata?",
		"options": ["Water vapour", "Soil", "Sugar", "Sand"],
		"options_ms": ["Wap air", "Tanah", "Gula", "Pasir"],
		"correct": 0,
		"difficulty": "medium",
		"explanation": "Leaves release water vapour through tiny holes called stomata. This is part of transpiration.",
		"explanation_ms": "Daun membebaskan wap air melalui liang-liang kecil yang dipanggil stomata. Ini adalah sebahagian daripada proses transpirasi."
	},
	{
		"question": "Which of these is NOT a part of a plant?",
		"question_ms": "Yang manakah BUKAN bahagian tumbuhan?",
		"options": ["Root", "Gill", "Leaf", "Stem"],
		"options_ms": ["Akar", "Insang", "Daun", "Batang"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Gills are found on fish, not plants. Plants have roots, stems, leaves, flowers, fruits, and seeds.",
		"explanation_ms": "Insang terdapat pada ikan, bukan tumbuhan. Tumbuhan mempunyai akar, batang, daun, bunga, buah, dan biji benih."
	},
	{
		"question": "Why do plants need sunlight?",
		"question_ms": "Mengapakah tumbuhan memerlukan cahaya matahari?",
		"options": ["To stay warm at night", "To make food through photosynthesis", "To attract animals", "To grow flowers"],
		"options_ms": ["Untuk kekal hangat pada waktu malam", "Untuk menghasilkan makanan melalui fotosintesis", "Untuk menarik haiwan", "Untuk menumbuhkan bunga"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Plants need sunlight as the energy source for photosynthesis — the process that makes their food.",
		"explanation_ms": "Tumbuhan memerlukan cahaya matahari sebagai sumber tenaga untuk fotosintesis — proses yang menghasilkan makanan mereka."
	},
	{
		"question": "Which of these plants reproduces using spores instead of seeds?",
		"question_ms": "Tumbuhan manakah yang membiak menggunakan spora dan bukan biji benih?",
		"options": ["Rose", "Fern", "Mango", "Sunflower"],
		"options_ms": ["Mawar", "Paku pakis", "Mangga", "Bunga matahari"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Ferns reproduce using tiny spores released from the underside of their leaves, not seeds.",
		"explanation_ms": "Paku pakis membiak menggunakan spora kecil yang dibebaskan daripada bahagian bawah daunnya, bukan biji benih."
	},
	{
		"question": "What is the food made by leaves called?",
		"question_ms": "Apakah nama makanan yang dihasilkan oleh daun?",
		"options": ["Water", "Glucose", "Oxygen", "Sand"],
		"options_ms": ["Air", "Glukosa", "Oksigen", "Pasir"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "During photosynthesis, leaves make a sugar called glucose. The plant uses it for energy and growth.",
		"explanation_ms": "Semasa fotosintesis, daun menghasilkan sejenis gula yang dipanggil glukosa. Tumbuhan menggunakannya untuk tenaga dan pertumbuhan."
	},
	{
		"question": "Which of these animals helps spread seeds?",
		"question_ms": "Haiwan manakah yang membantu menyebarkan biji benih?",
		"options": ["Birds", "Fish", "Snakes", "Ants only"],
		"options_ms": ["Burung", "Ikan", "Ular", "Semut sahaja"],
		"correct": 0,
		"difficulty": "easy",
		"explanation": "Birds eat fruit and drop the seeds in new places, helping plants spread to new areas.",
		"explanation_ms": "Burung memakan buah dan menjatuhkan biji benih di tempat-tempat baharu, membantu tumbuhan menyebar ke kawasan baharu."
	},

	# ── HARD (BringerOfDeath / boss enemies only) ────────────────────────────
	{
		"question": "Which process describes the movement of water from roots to leaves and out through tiny pores?",
		"question_ms": "Proses manakah yang menggambarkan pergerakan air daripada akar ke daun dan keluar melalui liang-liang kecil?",
		"options": ["Photosynthesis", "Respiration", "Transpiration", "Germination"],
		"options_ms": ["Fotosintesis", "Respirasi", "Transpirasi", "Percambahan"],
		"correct": 2,
		"difficulty": "hard",
		"explanation": "Transpiration is the process where water evaporates from leaves through tiny holes called stomata.",
		"explanation_ms": "Transpirasi adalah proses di mana air tersejat daripada daun melalui liang-liang kecil yang dipanggil stomata."
	},
	{
		"question": "Plants that get nutrients from other plants or organisms are called...",
		"question_ms": "Tumbuhan yang mendapatkan nutrien daripada tumbuhan atau organisma lain dipanggil...",
		"options": ["Carnivorous", "Parasitic", "Water plants", "Desert plants"],
		"options_ms": ["Karnivor", "Parasit", "Tumbuhan air", "Tumbuhan padang pasir"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "Parasitic plants like mistletoe grow on other plants and take water and nutrients from them.",
		"explanation_ms": "Tumbuhan parasit seperti dedalu tumbuh pada tumbuhan lain dan mengambil air serta nutrien daripadanya."
	},
	{
		"question": "Which of these is a carnivorous plant that traps insects?",
		"question_ms": "Yang manakah merupakan tumbuhan karnivor yang memerangkap serangga?",
		"options": ["Bamboo", "Venus flytrap", "Pineapple", "Wheat"],
		"options_ms": ["Buluh", "Perangkap lalat Venus", "Nanas", "Gandum"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "The Venus flytrap snaps shut when insects touch its trigger hairs, then digests them for nitrogen.",
		"explanation_ms": "Perangkap lalat Venus mengatup apabila serangga menyentuh rambut pencetusnya, kemudian mencernakan serangga itu untuk mendapatkan nitrogen."
	},
	{
		"question": "Photosynthesis makes glucose, which the plant stores as starch. Where can this starch be stored?",
		"question_ms": "Fotosintesis menghasilkan glukosa, yang disimpan oleh tumbuhan sebagai kanji. Di manakah kanji ini boleh disimpan?",
		"options": ["Only inside the green leaves", "In leaves, stems, roots, seeds and fruits", "Only inside the colourful flowers", "It is not stored at all"],
		"options_ms": ["Hanya di dalam daun hijau", "Di dalam daun, batang, akar, biji benih dan buah", "Hanya di dalam bunga berwarna", "Ia tidak disimpan langsung"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "The glucose made in photosynthesis is stored as starch in many parts of the plant — leaves, stems, roots, seeds, flowers and fruits.",
		"explanation_ms": "Glukosa yang dihasilkan dalam fotosintesis disimpan sebagai kanji di banyak bahagian tumbuhan — daun, batang, akar, biji benih, bunga dan buah."
	},
	{
		"question": "Which of these adaptations helps a desert plant survive?",
		"question_ms": "Penyesuaian manakah yang membantu tumbuhan padang pasir untuk terus hidup?",
		"options": ["Wide flat leaves", "Long shallow roots only", "Thick waxy skin and spines", "Hollow stems for air"],
		"options_ms": ["Daun yang lebar dan rata", "Akar panjang dan cetek sahaja", "Kulit berlilin yang tebal dan duri", "Batang berongga untuk udara"],
		"correct": 2,
		"difficulty": "hard",
		"explanation": "Desert plants have a thick waxy skin to reduce water loss, and spines instead of leaves to deter animals and minimize evaporation.",
		"explanation_ms": "Tumbuhan padang pasir mempunyai kulit berlilin yang tebal untuk mengurangkan kehilangan air, dan duri sebagai ganti daun untuk menghalang haiwan serta meminimumkan penyejatan."
	},
	{
		"question": "Photosynthesis releases a gas that all living things need to breathe. Which gas is it?",
		"question_ms": "Fotosintesis membebaskan satu gas yang diperlukan oleh semua hidupan untuk bernafas. Apakah gas itu?",
		"options": ["Carbon dioxide", "Oxygen", "Nitrogen", "Hydrogen"],
		"options_ms": ["Karbon dioksida", "Oksigen", "Nitrogen", "Hidrogen"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "During photosynthesis plants take in carbon dioxide and release oxygen into the air. Animals and humans need that oxygen to breathe.",
		"explanation_ms": "Semasa fotosintesis, tumbuhan menyerap karbon dioksida dan membebaskan oksigen ke udara. Haiwan dan manusia memerlukan oksigen itu untuk bernafas."
	},
	{
		"question": "Mistletoe is an example of which type of plant?",
		"question_ms": "Dedalu adalah contoh bagi jenis tumbuhan yang manakah?",
		"options": ["Aquatic", "Epiphytic", "Parasitic", "Carnivorous"],
		"options_ms": ["Akuatik", "Epufit", "Parasit", "Karnivor"],
		"correct": 2,
		"difficulty": "hard",
		"explanation": "Mistletoe is a parasitic plant — it grows on the branches of trees and steals water and nutrients from its host.",
		"explanation_ms": "Dedalu adalah tumbuhan parasit — ia tumbuh pada dahan pokok dan mencuri air serta nutrien daripada tumbuhan perumahnya."
	},
]
