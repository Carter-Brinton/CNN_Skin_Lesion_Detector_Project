enum SkinClass {
  MelanocyticNevi,
  Melanoma,
  BenignKeratosisLikeLesions,
  BasalCellCarcinoma,
  ActinicKeratoses,
  VascularLesions,
  Dermatofibroma,
}

class SkinClassInfo {
  final SkinClass skinClass;
  final String displayName;

  SkinClassInfo(this.skinClass, this.displayName);
}

final List<SkinClassInfo> skinClasses = [
  SkinClassInfo(SkinClass.MelanocyticNevi, "Melanocytic nevi (nv)"),
  SkinClassInfo(SkinClass.Melanoma, "Melanoma (mel)"),
  SkinClassInfo(SkinClass.BenignKeratosisLikeLesions, "Benign keratosis-like lesions (bkl)"),
  SkinClassInfo(SkinClass.BasalCellCarcinoma, "Basal cell carcinoma (bcc)"),
  SkinClassInfo(SkinClass.ActinicKeratoses, "Actinic keratoses (akiec)"),
  SkinClassInfo(SkinClass.VascularLesions, "Vascular lesions (vasc)"),
  SkinClassInfo(SkinClass.Dermatofibroma, "Dermatofibroma (df)"),
];

class SkinCondition {
  final String name;
  final String description;
  final String cancerous;

  SkinCondition(this.name, this.description, this.cancerous);
}

final List<SkinCondition> skinConditions = [
  SkinCondition(
    'Actinic Keratoses',
    'Actinic keratoses are precancerous, rough, scaly patches on the skin, typically caused by sun exposure and having the potential to become squamous cell carcinoma.',
    'Not cancerous (Can develop into cancer if left untreated).',
  ),
  SkinCondition(
    'Basal Cell Carcinoma',
    'Basal cell carcinoma is a common, slow-growing skin cancer that originates from basal cells in the skin\'s outer layer.',
    'Cancerous',
  ),
  SkinCondition(
    'Benign Keratosis-Like Lesions',
    'Benign keratosis-like lesions include various non-cancerous skin growths that resemble keratosis, such as seborrheic keratosis.',
    'Not cancerous',
  ),
  SkinCondition(
    'Dermatofibroma',
    'Dermatofibroma is a benign skin lesion characterized by small, raised bumps often with a brownish color and typically forming after minor skin trauma.',
    'Not cancerous',
  ),
  SkinCondition(
    'Melanocytic Nevi',
    'Melanocytic nevi, or moles, are benign skin growths formed from clusters of pigment-producing cells.',
    'Not cancerous',
  ),
  SkinCondition(
    'Melanoma',
    'Melanoma is a potentially life-threatening skin cancer that arises from uncontrolled growth of melanocytes, often appearing as irregularly shaped, discolored moles.',
    'Cancerous',
  ),
  SkinCondition(
    'Vascular Lesions',
    'Vascular lesions are skin abnormalities related to blood vessels, encompassing conditions like hemangiomas, port-wine stains, and telangiectasias.',
    'Not cancerous',
  ),
];
