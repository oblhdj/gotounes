const Map<String, List<String>> tunisiaRegions = {
  'Ariana': ['Ariana Ville', 'Ettadhamen', 'Kalaat el-Andalous', 'Mnihla', 'Raoued', 'Sidi Thabet', 'Soukra'],
  'Béja': ['Amdoun', 'Béja Nord', 'Béja Sud', 'Goubellat', 'Medjez el-Bab', 'Nefza', 'Teboursouk', 'Testour', 'Thibar'],
  'Ben Arous': ['Ben Arous', 'Bou Mhel el-Bassatine', 'El Mourouj', 'Ezzahra', 'Fouchana', 'Hammam Chott', 'Hammam Lif', 'Mohamedia', 'Medina Jedida', 'Megrine', 'Mornag', 'Radès'],
  'Bizerte': ['Bizerte Nord', 'Bizerte Sud', 'El Alia', 'Ghar El Melh', 'Ghezala', 'Joumine', 'Mateur', 'Menzel Bourguiba', 'Menzel Jemil', 'Ras Jebel', 'Sejnane', 'Tinja', 'Utique', 'Zarzouna'],
  'Gabès': ['Gabès Médina', 'Gabès Ouest', 'Gabès Sud', 'Ghannouch', 'El Hamma', 'Matmata', 'Nouvelle Matmata', 'Mareth', 'Menzel Habib', 'Métouia'],
  'Gafsa': ['Belkhir', 'El Guettar', 'El Ksar', 'Gafsa Nord', 'Gafsa Sud', 'Mdhilla', 'Métlaoui', 'Oum El Araies', 'Redeyef', 'Sened', 'Sidi Aïch'],
  'Jendouba': ['Aïn Draham', 'Balta-Bou Aouane', 'Bou Salem', 'Fernana', 'Ghardimaou', 'Jendouba Sud', 'Jendouba Nord', 'Oued Meliz'],
  'Kairouan': ['Bou Hajla', 'Chebika', 'Echrarda', 'Oueslatia', 'Haffouz', 'Hajeb El Ayoun', 'Kairouan Nord', 'Kairouan Sud', 'Nasrallah', 'Sbikha'],
  'Kasserine': ['El Ayoun', 'Ezzouhour', 'Fériana', 'Foussana', 'Hassi El Ferid', 'Jedelienne', 'Kasserine Nord', 'Kasserine Sud', 'Majel Bel Abbès', 'Sbeitla', 'Sbiba', 'Thala', 'Haidra'],
  'Kebili': ['Douz Nord', 'Douz Sud', 'Faouar', 'Kebili Nord', 'Kebili Sud', 'Souk Lahad'],
  'Kef': ['Dahmani', 'Jérissa', 'El Ksour', 'Sers', 'Tajerouine', 'Kalaat Senan', 'Kalaa Khasba', 'Kef Est', 'Kef Ouest', 'Nebeur', 'Sakiet Sidi Youssef', 'Touiref'],
  'Mahdia': ['Bou Merdes', 'Chebba', 'Chorbane', 'El Jem', 'Essouassi', 'Hebira', 'Ksour Essef', 'Mahdia', 'Melloulech', 'Ouled Chamekh', 'Sidi Alouane'],
  'Manouba': ['Borj El Amri', 'Djedeida', 'Douar Hicher', 'El Batan', 'Manouba', 'Mornaguia', 'Oued Ellil', 'Tebourba'],
  'Medenine': ['Ben Gardane', 'Beni Khedache', 'Djerba Ajim', 'Djerba Houmt Souk', 'Djerba Midoun', 'Medenine Nord', 'Medenine Sud', 'Sidi Makhlouf', 'Zarzis'],
  'Monastir': ['Bekalta', 'Bembla', 'Beni Hassen', 'Jemmal', 'Ksar Hellal', 'Ksibet el-Médiouni', 'Moknine', 'Monastir', 'Ouerdanine', 'Sahline', 'Sayada-Lamta-Bou Hajar', 'Téboulba', 'Zéramdine'],
  'Nabeul': ['Béni Khalled', 'Béni Khiar', 'Bou Argoub', 'Dar Chaâbane El Fehri', 'El Haouaria', 'El Mida', 'Grombalia', 'Hammam Ghezèze', 'Hammamet', 'Kelibia', 'Korba', 'Menzel Bouzelfa', 'Menzel Temime', 'Nabeul', 'Soliman', 'Takelsa'],
  'Sfax': ['Agareb', 'Bir Ali Ben Khalifa', 'El Amra', 'El Hencha', 'Graiba', 'Jebiniana', 'Kerkennah', 'Mahares', 'Menzel Chaker', 'Sakiet Eddaïer', 'Sakiet Ezzit', 'Sfax Ouest', 'Sfax Sud', 'Sfax Ville', 'Thyna'],
  'Sidi Bouzid': ['Bir El Hafey', 'Cebbala Ouled Asker', 'Jilma', 'Makarès', 'Menzel Bouzaiane', 'Mezzouna', 'Ouled Haffouz', 'Regueb', 'Sidi Ali Ben Aoun', 'Sidi Bouzid Est', 'Sidi Bouzid Ouest', 'Souk Jedid'],
  'Siliana': ['Bargou', 'Bou Arada', 'El Aroussa', 'Gaâfour', 'Kesra', 'Makthar', 'Rouhia', 'Sidi Bou Rouis', 'Siliana Nord', 'Siliana Sud'],
  'Sousse': ['Akouda', 'Bouficha', 'Enfidha', 'Hammam Sousse', 'Kondar', 'Msaken', 'Sidi Bou Ali', 'Sidi El Hani', 'Sousse Jawhara', 'Sousse Médina', 'Sousse Riadh', 'Sousse Sidi Abdelhamid'],
  'Tataouine': ['Bir Lahmar', 'Dehiba', 'Ghomrassen', 'Remada', 'Smar', 'Tataouine Nord', 'Tataouine Sud'],
  'Tozeur': ['Degache', 'Hazoua', 'Nefta', 'Tameghza', 'Tozeur'],
  'Tunis': ['Bab El Bhar', 'Bab Souika', 'Bardo', 'Carthage', 'Cité El Khadra', 'Djebel Jelloud', 'El Kabaria', 'El Menzah', 'El Omrane', 'El Omrane Supérieur', 'El Ouardia', 'Ettahrir', 'Ezzouhour', 'Hrairia', 'La Goulette', 'La Marsa', 'Le Kram', 'Médina', 'Séjoumi', 'Sidi El Bachir', 'Sidi Hassine'],
  'Zaghouan': ['Bir Mcherga', 'Fahs', 'Nadhour', 'Saouaf', 'Zaghouan', 'Zriba'],
};

List<String> getAllGovernorates() {
  final list = tunisiaRegions.keys.toList();
  list.sort();
  return list;
}
