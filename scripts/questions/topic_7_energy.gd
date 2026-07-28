extends RefCounted
class_name Topic7Energy

static var questions: Array[Dictionary] = [
	{
		"question": "Which of these is a form of energy?",
		"question_ms": "Yang manakah merupakan bentuk tenaga?",
		"options": ["Rock", "Heat", "Water", "Soil"],
		"options_ms": ["Batu", "Haba", "Air", "Tanah"],
		"correct": 1,
		"explanation": "Heat is a form of energy. Other forms include light, sound, electrical, and kinetic energy.",
		"explanation_ms": "Haba adalah bentuk tenaga. Bentuk lain termasuk tenaga cahaya, bunyi, elektrik, dan kinetik.",
		"difficulty": "easy"
	},
	{
		"question": "A moving car has which type of energy?",
		"question_ms": "Kereta yang bergerak mempunyai jenis tenaga yang manakah?",
		"options": ["Potential energy", "Chemical energy", "Kinetic energy", "Sound energy"],
		"options_ms": ["Tenaga keupayaan", "Tenaga kimia", "Tenaga kinetik", "Tenaga bunyi"],
		"correct": 2,
		"explanation": "Kinetic energy is the energy of motion. Any object that is moving — like a car — has kinetic energy.",
		"explanation_ms": "Tenaga kinetik adalah tenaga gerakan. Sebarang objek yang bergerak — seperti kereta — mempunyai tenaga kinetik.",
		"difficulty": "easy"
	},
	{
		"question": "A ball held up high has which type of energy?",
		"question_ms": "Bola yang dipegang tinggi mempunyai jenis tenaga yang manakah?",
		"options": ["Kinetic energy", "Potential energy", "Heat energy", "Light energy"],
		"options_ms": ["Tenaga kinetik", "Tenaga keupayaan", "Tenaga haba", "Tenaga cahaya"],
		"correct": 1,
		"explanation": "An object stored at a height has gravitational potential energy. When released, this converts to kinetic energy.",
		"explanation_ms": "Objek yang disimpan pada ketinggian mempunyai tenaga keupayaan graviti. Apabila dilepaskan, ia bertukar menjadi tenaga kinetik.",
		"difficulty": "easy"
	},
	{
		"question": "Which of these is a renewable source of energy?",
		"question_ms": "Yang manakah merupakan sumber tenaga boleh baharu?",
		"options": ["Coal", "Petrol", "Natural gas", "Solar energy"],
		"options_ms": ["Arang batu", "Petrol", "Gas asli", "Tenaga solar"],
		"correct": 3,
		"explanation": "Solar energy (from the Sun) is renewable because it will never run out. Coal, petrol, and gas are fossil fuels that will eventually be used up.",
		"explanation_ms": "Tenaga solar (daripada Matahari) adalah boleh baharu kerana ia tidak akan habis. Arang batu, petrol, dan gas adalah bahan api fosil yang akan habis suatu hari nanti.",
		"difficulty": "easy"
	},
	{
		"question": "What energy transformation happens in a light bulb?",
		"question_ms": "Apakah penukaran tenaga yang berlaku dalam mentol lampu?",
		"options": ["Heat to light", "Electrical to light and heat", "Sound to light", "Chemical to sound"],
		"options_ms": ["Haba kepada cahaya", "Elektrik kepada cahaya dan haba", "Bunyi kepada cahaya", "Kimia kepada bunyi"],
		"correct": 1,
		"explanation": "In a light bulb, electrical energy is converted into light energy and heat energy.",
		"explanation_ms": "Dalam mentol lampu, tenaga elektrik ditukarkan kepada tenaga cahaya dan tenaga haba.",
		"difficulty": "medium"
	},
	{
		"question": "Which energy transformation happens when you rub your hands together?",
		"question_ms": "Penukaran tenaga apakah yang berlaku apabila anda menggosok tangan anda bersama-sama?",
		"options": ["Kinetic energy to heat energy", "Light energy to heat energy", "Chemical energy to kinetic energy", "Sound to heat"],
		"options_ms": ["Tenaga kinetik kepada tenaga haba", "Tenaga cahaya kepada tenaga haba", "Tenaga kimia kepada tenaga kinetik", "Bunyi kepada haba"],
		"correct": 0,
		"explanation": "Rubbing your hands converts kinetic energy (movement) into heat energy through friction.",
		"explanation_ms": "Menggosok tangan anda menukarkan tenaga kinetik (gerakan) kepada tenaga haba melalui geseran.",
		"difficulty": "medium"
	},
	{
		"question": "What is the main source of energy for Earth?",
		"question_ms": "Apakah sumber tenaga utama bagi Bumi?",
		"options": ["The Moon", "Wind", "The Sun", "Water"],
		"options_ms": ["Bulan", "Angin", "Matahari", "Air"],
		"correct": 2,
		"explanation": "The Sun is Earth's primary source of energy. It provides heat and light that support all life.",
		"explanation_ms": "Matahari adalah sumber tenaga utama Bumi. Ia menyediakan haba dan cahaya yang menyokong semua kehidupan.",
		"difficulty": "easy"
	},
	{
		"question": "Sound energy is produced by...",
		"question_ms": "Tenaga bunyi dihasilkan oleh...",
		"options": ["Electricity", "Vibration of objects", "Reflection of light", "Chemical reactions only"],
		"options_ms": ["Elektrik", "Getaran objek", "Pantulan cahaya", "Tindak balas kimia sahaja"],
		"correct": 1,
		"explanation": "Sound is produced when objects vibrate. The vibrations travel through air (or other materials) to reach our ears.",
		"explanation_ms": "Bunyi dihasilkan apabila objek bergetar. Getaran tersebut bergerak melalui udara (atau bahan lain) untuk sampai ke telinga kita.",
		"difficulty": "easy"
	},
	{
		"question": "Which of these converts chemical energy into electrical energy?",
		"question_ms": "Yang manakah menukarkan tenaga kimia kepada tenaga elektrik?",
		"options": ["Solar panel", "Battery", "Wind turbine", "Light bulb"],
		"options_ms": ["Panel solar", "Bateri", "Turbin angin", "Mentol lampu"],
		"correct": 1,
		"explanation": "A battery stores chemical energy and converts it into electrical energy when connected to a circuit.",
		"explanation_ms": "Bateri menyimpan tenaga kimia dan menukarkannya kepada tenaga elektrik apabila disambungkan kepada litar.",
		"difficulty": "medium"
	},
	{
		"question": "What does the Law of Conservation of Energy state?",
		"question_ms": "Apakah yang dinyatakan oleh Hukum Keabadian Tenaga?",
		"options": ["Energy can be created from nothing", "Energy can be completely destroyed", "Energy cannot be created or destroyed, only transformed", "Energy always turns into light energy"],
		"options_ms": ["Tenaga boleh dicipta daripada tiada apa-apa", "Tenaga boleh dimusnahkan sepenuhnya", "Tenaga tidak boleh dicipta atau dimusnahkan, hanya ditukarkan", "Tenaga sentiasa bertukar menjadi cahaya"],
		"correct": 2,
		"explanation": "The Law of Conservation of Energy states that energy cannot be created or destroyed — it can only change from one form to another.",
		"explanation_ms": "Hukum Keabadian Tenaga menyatakan bahawa tenaga tidak boleh dicipta atau dimusnahkan — ia hanya boleh bertukar daripada satu bentuk kepada bentuk yang lain.",
		"difficulty": "hard"
	},
	{
		"question": "Which energy transformation happens in a solar panel?",
		"question_ms": "Penukaran tenaga apakah yang berlaku dalam panel solar?",
		"options": ["Electrical to light", "Light to electrical", "Heat to sound", "Chemical to heat"],
		"options_ms": ["Elektrik kepada cahaya", "Cahaya kepada elektrik", "Haba kepada bunyi", "Kimia kepada haba"],
		"correct": 1,
		"explanation": "Solar panels convert light energy from the Sun into electrical energy using photovoltaic cells.",
		"explanation_ms": "Panel solar menukarkan tenaga cahaya daripada Matahari kepada tenaga elektrik menggunakan sel fotovolta.",
		"difficulty": "medium"
	},
	{
		"question": "Which of these is NOT a renewable energy source?",
		"question_ms": "Yang manakah BUKAN sumber tenaga boleh baharu?",
		"options": ["Wind energy", "Hydroelectric energy", "Coal", "Solar energy"],
		"options_ms": ["Tenaga angin", "Tenaga hidroelektrik", "Arang batu", "Tenaga solar"],
		"correct": 2,
		"explanation": "Coal is a fossil fuel, which is non-renewable — once used, it cannot be replaced. Wind, water, and solar are renewable.",
		"explanation_ms": "Arang batu adalah bahan api fosil, iaitu tidak boleh baharu — setelah digunakan, ia tidak boleh diganti. Angin, air, dan solar adalah boleh baharu.",
		"difficulty": "medium"
	},
	{
		"question": "What energy does food provide to our bodies?",
		"question_ms": "Apakah tenaga yang disediakan oleh makanan kepada badan kita?",
		"options": ["Electrical energy", "Sound energy", "Chemical energy", "Nuclear energy"],
		"options_ms": ["Tenaga elektrik", "Tenaga bunyi", "Tenaga kimia", "Tenaga nuklear"],
		"correct": 2,
		"explanation": "Food contains chemical energy stored in nutrients. Our body breaks down food to release this energy for movement, growth, and heat.",
		"explanation_ms": "Makanan mengandungi tenaga kimia yang tersimpan dalam nutrien. Badan kita memecahkan makanan untuk membebaskan tenaga ini bagi pergerakan, pertumbuhan, dan haba.",
		"difficulty": "medium"
	},
	{
		"question": "A hydroelectric dam converts which energy into electrical energy?",
		"question_ms": "Empangan hidroelektrik menukarkan tenaga manakah kepada tenaga elektrik?",
		"options": ["Wind energy", "Solar energy", "Kinetic energy of water", "Chemical energy"],
		"options_ms": ["Tenaga angin", "Tenaga solar", "Tenaga kinetik air", "Tenaga kimia"],
		"correct": 2,
		"explanation": "A hydroelectric dam uses the kinetic energy of flowing water to spin turbines, which generate electrical energy.",
		"explanation_ms": "Empangan hidroelektrik menggunakan tenaga kinetik air yang mengalir untuk memutar turbin, yang menghasilkan tenaga elektrik.",
		"difficulty": "medium"
	},
	{
		"question": "Which sense organ detects sound energy?",
		"question_ms": "Organ deria manakah yang mengesan tenaga bunyi?",
		"options": ["Eyes", "Nose", "Skin", "Ears"],
		"options_ms": ["Mata", "Hidung", "Kulit", "Telinga"],
		"correct": 3,
		"explanation": "Our ears detect sound energy. Vibrations travel through the air and cause the eardrum to vibrate, which our brain interprets as sound.",
		"explanation_ms": "Telinga kita mengesan tenaga bunyi. Getaran bergerak melalui udara dan menyebabkan gegendang telinga bergetar, yang ditafsirkan oleh otak kita sebagai bunyi.",
		"difficulty": "easy"
	},
	{
		"question": "A diver stands high on a board, then falls into the pool. What is the energy change as they fall?",
		"question_ms": "Seorang penyelam berdiri tinggi di atas papan, kemudian jatuh ke dalam kolam. Apakah penukaran tenaga semasa dia jatuh?",
		"options": ["Sound energy → Light energy", "Potential energy → Kinetic energy", "Heat energy → Chemical energy", "Electrical energy → Kinetic energy"],
		"options_ms": ["Tenaga bunyi → Tenaga cahaya", "Tenaga keupayaan → Tenaga kinetik", "Tenaga haba → Tenaga kimia", "Tenaga elektrik → Tenaga kinetik"],
		"correct": 1,
		"explanation": "High on the board the diver stores potential energy. As they fall, that potential energy changes into kinetic energy (movement).",
		"explanation_ms": "Tinggi di atas papan, penyelam menyimpan tenaga keupayaan. Semasa dia jatuh, tenaga keupayaan itu bertukar kepada tenaga kinetik (pergerakan).",
		"difficulty": "hard"
	},
	{
		"question": "A solar panel is used in sunlight to power a light bulb. What is the energy change?",
		"question_ms": "Panel solar digunakan di bawah cahaya matahari untuk menghidupkan mentol. Apakah penukaran tenaga itu?",
		"options": ["Solar (light) energy → Electrical energy", "Chemical energy → Sound energy", "Kinetic energy → Heat energy", "Sound energy → Light energy"],
		"options_ms": ["Tenaga solar (cahaya) → Tenaga elektrik", "Tenaga kimia → Tenaga bunyi", "Tenaga kinetik → Tenaga haba", "Tenaga bunyi → Tenaga cahaya"],
		"correct": 0,
		"explanation": "A solar panel changes solar (light) energy from the Sun into electrical energy, which can then power the bulb.",
		"explanation_ms": "Panel solar menukarkan tenaga solar (cahaya) daripada Matahari kepada tenaga elektrik, yang kemudiannya boleh menghidupkan mentol.",
		"difficulty": "hard"
	},
	{
		"question": "A ceiling fan is switched on. Which energy transformation takes place?",
		"question_ms": "Kipas siling dihidupkan. Penukaran tenaga apakah yang berlaku?",
		"options": ["Electrical → Sound", "Electrical → Kinetic", "Chemical → Light", "Heat → Kinetic"],
		"options_ms": ["Elektrik → Bunyi", "Elektrik → Kinetik", "Kimia → Cahaya", "Haba → Kinetik"],
		"correct": 1,
		"explanation": "An electric fan converts electrical energy into the kinetic energy of the spinning blades, which then move the air.",
		"explanation_ms": "Kipas elektrik menukarkan tenaga elektrik kepada tenaga kinetik bilah yang berputar, yang kemudiannya menggerakkan udara.",
		"difficulty": "hard"
	},
	{
		"question": "Which group lists ONLY renewable energy sources?",
		"question_ms": "Kumpulan manakah yang menyenaraikan sumber tenaga boleh baharu SAHAJA?",
		"options": ["Sun, wind, coal", "Water, biomass, wind", "Petroleum, nuclear, gas", "Coal, oil, natural gas"],
		"options_ms": ["Matahari, angin, arang batu", "Air, biojisim, angin", "Petroleum, nuklear, gas", "Arang batu, minyak, gas asli"],
		"correct": 1,
		"explanation": "Water, biomass and wind are all renewable — they can be replaced or never run out. Coal, petroleum, gas and nuclear are non-renewable.",
		"explanation_ms": "Air, biojisim, dan angin semuanya boleh baharu — ia boleh digantikan atau tidak pernah habis. Arang batu, petroleum, gas, dan nuklear adalah tidak boleh baharu.",
		"difficulty": "hard"
	},
	{
		"question": "When a fire is lit, the energy transformation involved is...",
		"question_ms": "Apabila api dinyalakan, penukaran tenaga yang terlibat ialah...",
		"options": ["Light energy → Heat energy", "Chemical energy → Heat energy + Light energy", "Sound energy → Heat energy", "Electrical energy → Chemical energy"],
		"options_ms": ["Tenaga cahaya → Tenaga haba", "Tenaga kimia → Tenaga haba + Tenaga cahaya", "Tenaga bunyi → Tenaga haba", "Tenaga elektrik → Tenaga kimia"],
		"correct": 1,
		"explanation": "Wood and fuel store chemical energy. Burning releases that as heat energy and light energy at the same time.",
		"explanation_ms": "Kayu dan bahan api menyimpan tenaga kimia. Pembakaran membebaskannya sebagai tenaga haba dan tenaga cahaya pada masa yang sama.",
		"difficulty": "hard"
	},
]
