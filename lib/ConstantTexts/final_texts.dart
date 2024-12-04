const String appname = 'EnerVision';

// For The Energy Efficiency Page

const String energyEfficiency = "Energy Efficiency";

// For The Offline Calculator
const String pageTitle = "Offline Energy Calculator";
const String pageTitleDescription =
    'An offline tool for efficient energy management. Calculate your average energy costs by entering essential details like kWh rate, wattage, daily usage pattern, and days used per week — no internet connection required!';

const String energyCostEstimate = "Energy Cost Estimate";
const String energyCostEstimateExplainer =
    "Estimate costs by wattage, usage, and frequency—offline and easy!";

const String energyCalculationParameters = "Energy Calculation Parameters";
const String energyCalculationParametersExplainer =
    "Enter wattage, usage, and rate to estimate energy costs offline.";

const String estimatedEnergyCost = "Estimated Monthly Energy Cost";
const String wattage = "Wattage";
const String wattageLabelText = "Enter your appliance wattage";
const String wattagePlaceholder = "E.g. 1000";
const String usagePattern = "Usage Pattern";
const String usagePatternText = "Usage Pattern (hours per day)";
const String usagePatternPlaceholder = "E.g. 24";
const String kwhRate = "KWH Rate";
const String kwhRateText = "Enter KWH Rate in your Service Provider";
const String kwhRatePlaceholder = "E.g. 18";
const String calculateMonthlyCostButton = "Calculate";
const String selectDays = 'Select Days';
const String renewableEnergyP1 =
    'Renewable energy  comes from natural sources that are constantly replenished. These sources are crucial for a sustainable future.';
const String renewableEnergyP2 =
    'Renewable energy  can be used for electricity generation, space and water heating and cooling, and transportation. Non-renewable energy, in contrast, comes from finite sources, such as coal, natural gas, and oil.';
const String energyTrackerExplainer =
    'Personalized tool for efficient energy management. Seamlessly calculate your average energy costs by inputting watts, appliance usage, and prevailing kWh rates.';

const List<String> days = <String>[
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
  'Six',
  'Seven'
];
const List<String> weeks = <String>['One', 'Two', 'Three', 'Four'];
const appliancePageExplainer =
    'Click the add button to compare recommended energy efficient device with your current device.';
final List<String> barangays = [
  'Adlaon',
  'Agsungot',
  'Apas',
  'Babag',
  'Bacayan',
  'Banilad',
  'Basak Pardo',
  'Basak San Nicolas',
  'Binaliw',
  'Buhisan',
  'Bulacao',
  'Busay',
  'Calamba',
  'Cambinocot',
  'Capitol Site',
  'Carreta',
  'Cogon Pardo',
  'Cogon Ramos',
  'Day‑as',
  'Duljo Fatima',
  'Ermita',
  'Guadalupe',
  'Guba',
  'Hipodromo',
  'Inayawan',
  'Kalubihan',
  'Kalunasan',
  'Kamagayan',
  'Kamputhaw (Camputhaw)',
  'Kasambagan',
  'Kinasang‑an Pardo',
  'Labangon',
  'Lahug',
  'Lorega San Miguel',
  'Lusaran',
  'Luz',
  'Mabini',
  'Mabolo',
  'Malubog',
  'Mambaling',
  'Pahina Central',
  'Pahina San Nicolas',
  'Pamutan',
  'Pari-an',
  'Paril',
  'Pasil',
  'Pit-os',
  'Poblacion Pardo',
  'Pulangbato',
  'Pung-ol Sibugay',
  'Punta Princesa',
  'Quiot Pardo',
  'Sambag I',
  'Sambag II',
  'San Antonio',
  'San Jose',
  'San Nicolas Proper',
  'San Roque',
  'Santa Cruz',
  'Santo Niño (Poblacion)',
  'Sapangdaku',
  'Sawang Calero',
  'Sinsin',
  'Sirao',
  'Suba',
  'Sudlon I',
  'Sudlon II',
  'T. Padilla',
  'Tabunan',
  'Tagba-o',
  'Talamban',
  'Taptap',
  'Tejero (Villa Gonzalo)',
  'Tinago',
  'Tisa',
  'To-ong',
  'Zapatera'
];
final List<Map<String, dynamic>> descriptions = [
  {
    "title": "1. Be Respectful",
    "description": [
      "Treat everyone with kindness and respect.",
      "Avoid personal attacks, insults, or inflammatory remarks.",
      "Discrimination, hate speech, or harassment will not be tolerated."
    ]
  },
  {
    "title": "2. Keep It Safe",
    "description": [
      "Be cautious when sharing personal information.",
      "Do not share highly sensitive data like passwords or financial account numbers.",
      "Avoid posting harmful or illegal content."
    ]
  },
  {
    "title": "3. Your Name and Profile Information",
    "description": [
      "Your name and profile will be visible to others.",
      "Ensure your profile information is accurate and respectful."
    ]
  },
  {
    "title": "4. Constructive Communication",
    "description": [
      "Engage in meaningful, constructive discussions.",
      "Disagree respectfully and offer helpful insights."
    ]
  },
  {
    "title": "5. No Spam or Self-Promotion",
    "description": [
      "Avoid spamming the community with irrelevant links or promotional content."
    ]
  },
  {
    "title": "6. Stay On Topic",
    "description": ["Keep posts relevant to the community themes."]
  },
  {
    "title": "7. Protect Privacy",
    "description": [
      "Do not share private messages or content without permission."
    ]
  },
  {
    "title": "8. Report Violations",
    "description": [
      "Help maintain the community’s quality by reporting inappropriate content."
    ]
  },
  {
    "title": "9. Follow the Law",
    "description": ["Ensure posts and interactions comply with laws."]
  },
  {
    "title": "10. Moderation",
    "description": [
      "Moderators have the right to remove content that violates guidelines."
    ]
  },
  {
    "title": "11. Be Kind and Helpful",
    "description": [
      "Offer support, advice, and encouragement to fellow members."
    ]
  }
];
String _monthName(int month) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  return months[month - 1];
}
