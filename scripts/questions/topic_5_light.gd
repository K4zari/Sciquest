extends RefCounted
class_name Topic5Light

static var questions: Array[Dictionary] = [
	{
		"question": "How does light travel?",
		"question_ms": "Bagaimanakah cahaya bergerak?",
		"options": ["In curved lines", "In zigzag lines", "In straight lines", "In circular paths"],
		"options_ms": ["Dalam garis lengkung", "Dalam garis zigzag", "Dalam garis lurus", "Dalam laluan bulat"],
		"correct": 2,
		"explanation": "Light always travels in straight lines. This is why shadows have sharp edges.",
		"explanation_ms": "Cahaya sentiasa bergerak dalam garis lurus. Inilah sebab mengapa bayang-bayang mempunyai tepi yang tajam."
	},
	{
		"question": "What happens when light hits a mirror?",
		"question_ms": "Apakah yang berlaku apabila cahaya mengenai cermin?",
		"options": ["It is absorbed", "It is reflected", "It disappears", "It bends inside"],
		"options_ms": ["Ia diserap", "Ia dipantulkan", "Ia hilang", "Ia membelok ke dalam"],
		"correct": 1,
		"explanation": "Mirrors have a smooth, shiny surface that reflects light. The light bounces back in a predictable direction.",
		"explanation_ms": "Cermin mempunyai permukaan yang licin dan berkilat yang memantulkan cahaya. Cahaya melantun kembali dalam arah yang boleh dijangka."
	},
	{
		"question": "Which material allows all light to pass through it?",
		"question_ms": "Bahan manakah yang membenarkan semua cahaya menembusinya?",
		"options": ["Wood", "Metal", "Clear glass", "Cardboard"],
		"options_ms": ["Kayu", "Logam", "Kaca jernih", "Kadbod"],
		"correct": 2,
		"explanation": "Clear glass is transparent — it allows almost all light to pass through, which is why we can see through it.",
		"explanation_ms": "Kaca jernih adalah lutsinar — ia membenarkan hampir semua cahaya menembusinya, itulah sebab kita boleh melihat melaluinya."
	},
	{
		"question": "A material that blocks all light is called...",
		"question_ms": "Bahan yang menghalang semua cahaya dipanggil...",
		"options": ["Transparent", "Translucent", "Opaque", "Reflective"],
		"options_ms": ["Lutsinar", "Lut cahaya", "Legap", "Memantul"],
		"correct": 2,
		"explanation": "Opaque materials, like wood and metal, block all light from passing through them, forming shadows.",
		"explanation_ms": "Bahan legap, seperti kayu dan logam, menghalang semua cahaya daripada menembusinya, lalu membentuk bayang-bayang."
	},
	{
		"question": "What is a shadow?",
		"question_ms": "Apakah bayang-bayang?",
		"options": ["Light reflected off a surface", "A dark area formed when an object blocks light", "Light passing through an object", "Coloured light spread across a wall"],
		"options_ms": ["Cahaya yang dipantulkan daripada permukaan", "Kawasan gelap yang terbentuk apabila objek menghalang cahaya", "Cahaya yang menembusi objek", "Cahaya berwarna yang tersebar pada dinding"],
		"correct": 1,
		"explanation": "A shadow forms when an opaque object blocks the path of light, creating a dark area behind it.",
		"explanation_ms": "Bayang-bayang terbentuk apabila objek legap menghalang laluan cahaya, mewujudkan kawasan gelap di belakangnya."
	},
	{
		"question": "Frosted glass that lets some light through but you cannot see clearly through it is called...",
		"question_ms": "Kaca beku yang membenarkan sedikit cahaya menembusi tetapi tidak dapat dilihat dengan jelas melaluinya dipanggil...",
		"options": ["Opaque", "Transparent", "Translucent", "Reflective"],
		"options_ms": ["Legap", "Lutsinar", "Lut cahaya", "Memantul"],
		"correct": 2,
		"explanation": "Translucent materials let some light pass through but scatter it, so you cannot see a clear image. Frosted glass and tissue paper are examples.",
		"explanation_ms": "Bahan lut cahaya membenarkan sedikit cahaya menembusinya tetapi menyerakkannya, jadi anda tidak dapat melihat imej yang jelas. Kaca beku dan kertas tisu adalah contohnya."
	},
	{
		"question": "Which colour of light can be seen in a rainbow?",
		"question_ms": "Warna cahaya manakah yang dapat dilihat dalam pelangi?",
		"options": ["Only shades of red and blue", "Red, orange, yellow, green, blue, indigo, violet", "Only plain white light", "Only black, grey and white"],
		"options_ms": ["Hanya warna merah dan biru", "Merah, jingga, kuning, hijau, biru, nila, ungu", "Hanya cahaya putih biasa", "Hanya hitam, kelabu dan putih"],
		"correct": 1,
		"explanation": "White light (sunlight) is made of 7 colours: red, orange, yellow, green, blue, indigo, and violet. A prism or raindrops split them apart.",
		"explanation_ms": "Cahaya putih (cahaya matahari) terdiri daripada 7 warna: merah, jingga, kuning, hijau, biru, nila, dan ungu. Prisma atau titisan hujan memisahkannya."
	},
	{
		"question": "What is refraction?",
		"question_ms": "Apakah pembiasan cahaya?",
		"options": ["Light bouncing off a surface", "Light being absorbed by a surface", "Light bending when it passes from one material to another", "Light creating shadows behind objects"],
		"options_ms": ["Cahaya yang melantun daripada permukaan", "Cahaya yang diserap oleh permukaan", "Cahaya yang membelok apabila melalui daripada satu bahan ke bahan lain", "Cahaya yang menghasilkan bayang-bayang"],
		"correct": 2,
		"explanation": "Refraction happens when light changes speed as it moves from one material to another (like from air to water), causing it to bend.",
		"explanation_ms": "Pembiasan berlaku apabila cahaya berubah kelajuan semasa ia bergerak daripada satu bahan ke bahan lain (seperti daripada udara ke air), menyebabkannya membelok."
	},
	{
		"question": "A periscope works by using...",
		"question_ms": "Periskop berfungsi dengan menggunakan...",
		"options": ["Refraction of light", "Two mirrors to reflect light", "Transparent glass", "Electric light"],
		"options_ms": ["Pembiasan cahaya", "Dua cermin untuk memantulkan cahaya", "Kaca lutsinar", "Cahaya elektrik"],
		"correct": 1,
		"explanation": "A periscope uses two mirrors positioned at angles to reflect light around corners, letting you see over or around obstacles.",
		"explanation_ms": "Periskop menggunakan dua cermin yang diletakkan pada sudut tertentu untuk memantulkan cahaya di sekeliling sudut, membolehkan anda melihat melebihi atau di sekeliling halangan."
	},
	{
		"question": "Why does a straw look bent when placed in a glass of water?",
		"question_ms": "Mengapakah straw kelihatan bengkok apabila diletakkan dalam segelas air?",
		"options": ["The water pushes the straw", "Light refracts when moving from water to air", "The straw is melting", "The glass is curved"],
		"options_ms": ["Air menolak straw", "Cahaya terbias semasa bergerak daripada air ke udara", "Straw itu melebur", "Gelas itu melengkung"],
		"correct": 1,
		"explanation": "Light bends (refracts) when it moves from water to air. This makes the straw appear bent even though it is straight.",
		"explanation_ms": "Cahaya membelok (terbias) apabila ia bergerak daripada air ke udara. Ini menyebabkan straw kelihatan bengkok walaupun ia lurus."
	},
	{
		"question": "Which device uses a lens to focus light and make objects look bigger?",
		"question_ms": "Alat manakah yang menggunakan kanta untuk memfokuskan cahaya dan menjadikan objek kelihatan lebih besar?",
		"options": ["Mirror", "Periscope", "Magnifying glass", "Prism"],
		"options_ms": ["Cermin", "Periskop", "Kaca pembesar", "Prisma"],
		"correct": 2,
		"explanation": "A magnifying glass uses a convex lens to bend (refract) light, making objects appear larger than they are.",
		"explanation_ms": "Kaca pembesar menggunakan kanta cembung untuk membelokkan (membiaskan) cahaya, menjadikan objek kelihatan lebih besar daripada saiz sebenarnya."
	},
	{
		"question": "What is the speed of light approximately?",
		"question_ms": "Berapakah kelajuan cahaya secara anggaran?",
		"options": ["300 km/s", "300,000 km/s", "3,000 km/s", "30 km/s"],
		"options_ms": ["300 km/s", "300,000 km/s", "3,000 km/s", "30 km/s"],
		"correct": 1,
		"explanation": "Light travels at approximately 300,000 kilometres per second — the fastest speed in the universe!",
		"explanation_ms": "Cahaya bergerak pada kelajuan lebih kurang 300,000 kilometer sesaat — kelajuan terpantas di alam semesta!"
	},
	{
		"question": "The Law of Reflection states that the angle of incidence equals...",
		"question_ms": "Hukum Pantulan menyatakan bahawa sudut tuju adalah sama dengan...",
		"options": ["The angle of refraction", "The angle of reflection", "90 degrees", "The size of the mirror"],
		"options_ms": ["Sudut pembiasan", "Sudut pantulan", "90 darjah", "Saiz cermin"],
		"correct": 1,
		"explanation": "When light reflects off a surface, the angle at which it hits (angle of incidence) equals the angle at which it bounces off (angle of reflection).",
		"explanation_ms": "Apabila cahaya dipantulkan daripada permukaan, sudut datangnya (sudut tuju) adalah sama dengan sudut pantulannya (sudut pantulan)."
	},
	{
		"question": "Which of these is a luminous object (produces its own light)?",
		"question_ms": "Yang manakah merupakan objek bercahaya (menghasilkan cahayanya sendiri)?",
		"options": ["Moon", "Mirror", "The Sun", "Book"],
		"options_ms": ["Bulan", "Cermin", "Matahari", "Buku"],
		"correct": 2,
		"explanation": "The Sun is luminous — it produces its own light. The Moon is non-luminous; it only reflects sunlight.",
		"explanation_ms": "Matahari adalah bercahaya — ia menghasilkan cahayanya sendiri. Bulan adalah tidak bercahaya; ia hanya memantulkan cahaya matahari."
	},
	{
		"question": "What tool separates white light into its spectrum of colours?",
		"question_ms": "Alat apakah yang memisahkan cahaya putih kepada spektrum warna-warnanya?",
		"options": ["Lens", "Mirror", "Prism", "Magnifying glass"],
		"options_ms": ["Kanta", "Cermin", "Prisma", "Kaca pembesar"],
		"correct": 2,
		"explanation": "A prism refracts white light at different angles for each colour, separating it into the visible spectrum: red, orange, yellow, green, blue, indigo, violet.",
		"explanation_ms": "Prisma membiaskan cahaya putih pada sudut berbeza bagi setiap warna, memisahkannya kepada spektrum yang kelihatan: merah, jingga, kuning, hijau, biru, nila, ungu."
	},
]
