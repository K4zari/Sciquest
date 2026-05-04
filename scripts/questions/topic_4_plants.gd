extends RefCounted
class_name Topic4Plants

# Difficulty values: "easy", "medium", "hard".
# "hard" questions are reserved for boss enemies (is_boss == true).
# Regular enemies draw from "easy" + "medium" only.

static var questions: Array[Dictionary] = [
	# ── EASY / MEDIUM (regular enemies) ──────────────────────────────────────
	{
		"question": "Which part of the plant makes food using sunlight?",
		"options": ["Root", "Stem", "Leaf", "Flower"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "Leaves make food for the plant using sunlight, water, and carbon dioxide — a process called photosynthesis."
	},
	{
		"question": "What do roots do for a plant?",
		"options": ["Make flowers", "Absorb water and minerals from soil", "Produce seeds", "Trap insects"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Roots anchor the plant in the soil and absorb water and minerals that the plant needs to grow."
	},
	{
		"question": "What does a plant need to make its own food?",
		"options": ["Moonlight and rain", "Sunlight, water, and carbon dioxide", "Soil, insects, and heat", "Oxygen and sugar"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Plants use sunlight as energy, water from the soil, and carbon dioxide from the air to make food through photosynthesis."
	},
	{
		"question": "Which part of a plant carries water from the roots to the leaves?",
		"options": ["Flower", "Fruit", "Stem", "Seed"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "The stem acts like a pipe, transporting water and minerals from the roots up to the leaves and other parts."
	},
	{
		"question": "What gas do plants release during photosynthesis?",
		"options": ["Carbon dioxide", "Nitrogen", "Oxygen", "Hydrogen"],
		"correct": 2,
		"difficulty": "medium",
		"explanation": "During photosynthesis, plants take in carbon dioxide and release oxygen — which is the air we breathe!"
	},
	{
		"question": "Which type of plant does NOT have roots, stems, or leaves?",
		"options": ["Fern", "Moss", "Rose", "Mango tree"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Mosses are simple plants that do not have proper roots, stems, or leaves. They absorb water directly through their surface."
	},
	{
		"question": "What is the main job of a flower?",
		"options": ["Absorb sunlight", "Make seeds for reproduction", "Store water", "Carry minerals"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Flowers are the reproductive organs of a plant. They produce seeds that grow into new plants."
	},
	{
		"question": "Which of these plants stores water in its stem?",
		"options": ["Cactus", "Mushroom", "Fern", "Rice"],
		"correct": 0,
		"difficulty": "easy",
		"explanation": "Cacti are adapted to dry deserts by storing water in their thick, fleshy stems."
	},
	{
		"question": "A plant that loses its leaves during dry seasons is called...",
		"options": ["Evergreen", "Deciduous", "Aquatic", "Parasitic"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Deciduous plants shed their leaves when there is not enough water, to reduce water loss."
	},
	{
		"question": "Which part of the plant protects the seed?",
		"options": ["Leaf", "Root", "Fruit", "Stem"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "The fruit develops from the flower and its main job is to protect the seed inside it."
	},
	{
		"question": "What do we call plants that live in water?",
		"options": ["Desert plants", "Aquatic plants", "Parasitic plants", "Climbing plants"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Plants that live in water, such as water hyacinth and lotus, are called aquatic plants."
	},
	{
		"question": "What type of plant is a fern?",
		"options": ["Flowering plant", "Non-flowering plant", "Aquatic plant", "Parasitic plant"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Ferns are non-flowering plants. They reproduce using spores, not seeds or flowers."
	},
	{
		"question": "Why do leaves appear green?",
		"options": ["They contain water", "They contain chlorophyll", "They reflect sunlight", "They absorb nitrogen"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Leaves contain a green pigment called chlorophyll, which absorbs sunlight for photosynthesis."
	},
	{
		"question": "Which of these is a flowering plant?",
		"options": ["Moss", "Fern", "Hibiscus", "Mushroom"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "Hibiscus is a flowering plant. Mosses and ferns do not produce flowers, and mushrooms are fungi, not plants."
	},
	{
		"question": "Where does a new plant come from?",
		"options": ["A leaf", "A seed", "A root", "A drop of water"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "A new plant grows from a seed in a process called germination."
	},
	{
		"question": "What helps a climbing plant grow upward on a wall or pole?",
		"options": ["Tendrils", "Roots", "Flowers", "Fruits"],
		"correct": 0,
		"difficulty": "medium",
		"explanation": "Climbing plants like passion fruit use tendrils — thin coiling stems — to wrap around supports and climb upward."
	},
	{
		"question": "Which part of the plant grows below the ground?",
		"options": ["Leaf", "Stem", "Root", "Flower"],
		"correct": 2,
		"difficulty": "easy",
		"explanation": "Roots grow below the ground to anchor the plant and absorb water and minerals from the soil."
	},
	{
		"question": "What do bees and butterflies help plants do?",
		"options": ["Photosynthesize", "Pollinate flowers", "Absorb water", "Grow taller"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Bees and butterflies carry pollen from one flower to another. This pollination helps plants make seeds."
	},
	{
		"question": "Which plant grows from a bulb?",
		"options": ["Onion", "Mango", "Banana", "Coconut"],
		"correct": 0,
		"difficulty": "medium",
		"explanation": "Onions grow from bulbs — short underground stems with fleshy leaves that store food."
	},
	{
		"question": "What do leaves give off through tiny holes called stomata?",
		"options": ["Water vapour", "Soil", "Sugar", "Sand"],
		"correct": 0,
		"difficulty": "medium",
		"explanation": "Leaves release water vapour through tiny holes called stomata. This is part of transpiration."
	},
	{
		"question": "Which of these is NOT a part of a plant?",
		"options": ["Root", "Gill", "Leaf", "Stem"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Gills are found on fish, not plants. Plants have roots, stems, leaves, flowers, fruits, and seeds."
	},
	{
		"question": "Why do plants need sunlight?",
		"options": ["To stay warm at night", "To make food through photosynthesis", "To attract animals", "To grow flowers"],
		"correct": 1,
		"difficulty": "easy",
		"explanation": "Plants need sunlight as the energy source for photosynthesis — the process that makes their food."
	},
	{
		"question": "Which of these plants reproduces using spores instead of seeds?",
		"options": ["Rose", "Fern", "Mango", "Sunflower"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "Ferns reproduce using tiny spores released from the underside of their leaves, not seeds."
	},
	{
		"question": "What is the food made by leaves called?",
		"options": ["Water", "Glucose", "Oxygen", "Sand"],
		"correct": 1,
		"difficulty": "medium",
		"explanation": "During photosynthesis, leaves make a sugar called glucose. The plant uses it for energy and growth."
	},
	{
		"question": "Which of these animals helps spread seeds?",
		"options": ["Birds", "Fish", "Snakes", "Ants only"],
		"correct": 0,
		"difficulty": "easy",
		"explanation": "Birds eat fruit and drop the seeds in new places, helping plants spread to new areas."
	},

	# ── HARD (BringerOfDeath / boss enemies only) ────────────────────────────
	{
		"question": "Which process describes the movement of water from roots to leaves and out through tiny pores?",
		"options": ["Photosynthesis", "Respiration", "Transpiration", "Germination"],
		"correct": 2,
		"difficulty": "hard",
		"explanation": "Transpiration is the process where water evaporates from leaves through tiny holes called stomata."
	},
	{
		"question": "Plants that get nutrients from other plants or organisms are called...",
		"options": ["Carnivorous", "Parasitic", "Aquatic", "Epiphytic"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "Parasitic plants like mistletoe grow on other plants and take water and nutrients from them."
	},
	{
		"question": "Which of these is a carnivorous plant that traps insects?",
		"options": ["Bamboo", "Venus flytrap", "Pineapple", "Wheat"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "The Venus flytrap snaps shut when insects touch its trigger hairs, then digests them for nitrogen."
	},
	{
		"question": "What is the male reproductive part of a flower called?",
		"options": ["Stigma", "Stamen", "Pistil", "Ovary"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "The stamen is the male part of a flower. It produces pollen, which is needed for reproduction."
	},
	{
		"question": "Which of these adaptations helps a desert plant survive?",
		"options": ["Wide flat leaves", "Long shallow roots only", "Thick waxy skin and spines", "Hollow stems for air"],
		"correct": 2,
		"difficulty": "hard",
		"explanation": "Desert plants have a thick waxy skin to reduce water loss, and spines instead of leaves to deter animals and minimize evaporation."
	},
	{
		"question": "Which gas do plants take in for photosynthesis AND release during respiration?",
		"options": ["Oxygen / Carbon dioxide", "Carbon dioxide / Oxygen", "Nitrogen / Oxygen", "Hydrogen / Carbon dioxide"],
		"correct": 1,
		"difficulty": "hard",
		"explanation": "Plants take in carbon dioxide for photosynthesis and release oxygen. During respiration (day and night) they take in oxygen and release carbon dioxide."
	},
	{
		"question": "Mistletoe is an example of which type of plant?",
		"options": ["Aquatic", "Epiphytic", "Parasitic", "Carnivorous"],
		"correct": 2,
		"difficulty": "hard",
		"explanation": "Mistletoe is a parasitic plant — it grows on the branches of trees and steals water and nutrients from its host."
	},
]
