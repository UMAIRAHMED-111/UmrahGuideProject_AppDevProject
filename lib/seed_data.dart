import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedData() async {
  final firestore = FirebaseFirestore.instance;

  // 1. Clear existing data
  final ritualDocs = await firestore.collection('rituals').get();
  for (final doc in ritualDocs.docs) {
    await doc.reference.delete();
  }

  final duaDocs = await firestore.collection('duas').get();
  for (final doc in duaDocs.docs) {
    await doc.reference.delete();
  }

  // 2. Seed Rituals
  final rituals = [
    // Travel
    {
      'id': 'travel',
      'title': 'Travel Preparations',
      'description': 'Prepare for your journey to Umrah by making necessary arrangements and reciting specific duas for a safe and blessed trip.',
      'imageUrl': 'https://www.visitsaudi.com/content/dam/wvs/plan-your-trip/umrah-ziyarah/Ihram-on-plane.jpg',
      'audioUrl': '',
      'order': 1,
      'isComplete': false,
    },
    // Ihram
    {
      'id': 'ihram',
      'title': 'Ihram',
      'description': 'Enter the sacred state of Ihram, which involves wearing the prescribed garments and making the intention for Umrah. This ritual signifies purity and devotion.',
      'imageUrl': 'https://www.visitsaudi.com/content/dam/wvs/plan-your-trip/umrah-ziyarah/Ihram-on-plane.jpg',
      'audioUrl': '',
      'order': 2,
      'isComplete': false,
    },
    // Tawaf
    {
      'id': 'tawaf',
      'title': 'Tawaf',
      'description': 'Perform Tawaf by circling the Kaaba seven times in a counterclockwise direction. This act of worship is a profound expression of devotion and submission to Allah.',
      'imageUrl': 'https://www.visitsaudi.com/content/dam/wvs/plan-your-trip/umrah-ziyarah/kabaa.jpg',
      'audioUrl': '',
      'order': 3,
      'isComplete': false,
    },
    // Sa'i
    {
      'id': 'sai',
      'title': "Sa'i",
      'description': 'Walk between the hills of Safa and Marwah seven times, commemorating Hajar\'s search for water for her son Ismail. This ritual symbolizes perseverance and faith.',
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWzCsPujXQQ5NOddmddLTx2u4Bz7EhiDexlg&s',
      'audioUrl': '',
      'order': 4,
      'isComplete': false,
    },
    // Halq/Taqsir
    {
      'id': 'halq',
      'title': 'Halq/Taqsir',
      'description': 'Shave or trim your hair to symbolize the completion of Umrah and exit the state of Ihram. This act represents humility and rebirth.',
      'imageUrl': 'https://hajjumrahplanner.com/wp-content/uploads/2017/02/child-haircut.jpg',
      'audioUrl': '',
      'order': 5,
      'isComplete': false,
    },
    // General
    {
      'id': 'general',
      'title': 'General Duas',
      'description': 'Recite various duas for different occasions during Umrah to seek blessings, guidance, and forgiveness from Allah.',
      'imageUrl': 'https://www.visitsaudi.com/content/dam/wvs/plan-your-trip/umrah-ziyarah/Ihram-on-plane.jpg',
      'audioUrl': '',
      'order': 6,
      'isComplete': false,
    },
    // Safety
    {
      'id': 'safety',
      'title': 'Safety Duas',
      'description': 'Recite duas for protection and well-being during your Umrah journey to ensure a safe and secure pilgrimage.',
      'imageUrl': 'https://www.visitsaudi.com/content/dam/wvs/plan-your-trip/umrah-ziyarah/Ihram-on-plane.jpg',
      'audioUrl': '',
      'order': 7,
      'isComplete': false,
    },
    // Other
    {
      'id': 'other',
      'title': 'Other Duas',
      'description': 'Recite additional duas, including those for drinking Zamzam water, to seek blessings and fulfillment of your spiritual needs.',
      'imageUrl': 'https://www.visitsaudi.com/content/dam/wvs/plan-your-trip/umrah-ziyarah/Ihram-on-plane.jpg',
      'audioUrl': '',
      'order': 8,
      'isComplete': false,
    },
  ];

  for (final ritual in rituals) {
    await firestore.collection('rituals').doc(ritual['id'] as String).set(ritual);
  }

  // 3. Seed Duas
  final duas = [
    // Travel (3)
    {
      'id': 'dua_travel_start',
      'title': 'Dua Before Journey',
      'arabic': 'بِسْمِ اللهِ تَوَكَّلْتُ عَلَى اللهِ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللهِ',
      'transliteration': 'Bismillahi tawakkaltu ala Allah, wa la hawla wa la quwwata illa bi-Allah.',
      'translation': 'In the Name of Allah, I place my trust in Allah, and there is no power nor might except through Allah.',
      'category': 'Travel Preparations',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_travel_boarding',
      'title': 'Dua for Boarding',
      'arabic': 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
      'transliteration': 'Allahu akbar, Allahu akbar, Allahu akbar. Subhana alladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila Rabbina lamunqalibun.',
      'translation': 'Allah is the Greatest, Allah is the Greatest, Allah is the Greatest. Glory be to Him Who has subjected this to us, for we could never have accomplished this by ourselves, and indeed, to our Lord we will return.',
      'category': 'Travel Preparations',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_travel_arrival',
      'title': 'Dua Upon Arrival',
      'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      'transliteration': 'A\'udhu bi-kalimatillah it-tammat min sharri ma khalaq.',
      'translation': 'I seek refuge in Allah\'s perfect words from the evil He created.',
      'category': 'Travel Preparations',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    // Tawaf (10)
    {
      'id': 'dua_tawaf_start',
      'title': 'Dua at Start of Tawaf',
      'arabic': 'بِسْمِ اللَّهِ اللَّهُ أَكْبَرُ وَلِلَّهِ الْحَمْدُ اللَّهُمَّ إِيمَانًا بِكَ وَتَصْدِيقًا بِكِتَابِكَ وَوَفَاءً بِعَهْدِكَ وَاتِّبَاعًا لِسُنَّةِ نَبِيِّكَ مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
      'transliteration': 'Bismillahi Allahu akbaru wa lillahi l-hamdu. Allahumma imanan bika wa tasdiqan bi-kitabika wa wafa\'an bi-ahdika wa ittiba\'an li-sunnati nabiyyika Muhammadin sallallahu alayhi wa sallam.',
      'translation': 'In the name of Allah, Allah is the Greatest, and all praise is for Allah. O Allah, I perform this Tawaf believing in You, confirming the truth of Your Book, fulfilling my covenant with You, and following the Sunnah of Your Prophet Muhammad, peace be upon him.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_round1',
      'title': 'Dua for First Round of Tawaf',
      'arabic': 'اللَّهُمَّ إِنَّ هَذَا الْبَيْتَ بَيْتُكَ وَالْحَرَمَ حَرَمُكَ وَالْأَمْنَ أَمْنُكَ وَهَذَا مَقَامُ الْعَائِذِ بِكَ مِنَ النَّارِ',
      'transliteration': 'Allahumma inna hadha al-bayta baytuka wa l-harama haramuka wa l-amna amnuka wa hadha maqamu l-a\'idhi bika mina n-nar.',
      'translation': 'O Allah, this House is Your House, this sanctuary is Your sanctuary, this security is Your security, and this is the station of one who seeks refuge in You from the Fire.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_round2',
      'title': 'Dua for Second Round of Tawaf',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
      'transliteration': 'Allahumma inni as\'aluka l-afwa wa l-afiyata fi d-dunya wa l-akhirati. Allahumma inni as\'aluka l-afwa wa l-afiyata fi deeni wa dunyaya wa ahli wa mali.',
      'translation': 'O Allah, I ask You for pardon and well-being in this world and the Hereafter. O Allah, I ask You for pardon and well-being in my religion, my worldly affairs, my family, and my wealth.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_round3',
      'title': 'Dua for Third Round of Tawaf',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ خَيْرِ مَا سَأَلَكَ مِنْهُ عِبَادُكَ الصَّالِحُونَ وَأَعُوذُ بِكَ مِنْ شَرِّ مَا اسْتَعَاذَ مِنْهُ عِبَادُكَ الصَّالِحُونَ',
      'transliteration': 'Allahumma inni as\'aluka min khayri ma sa\'alaka minhu ibaduka s-salihoon, wa a\'udhu bika min sharri ma sta\'adha minhu ibaduka s-salihoon.',
      'translation': 'O Allah, I ask You for the good that Your righteous servants have asked You for, and I seek refuge in You from the evil that Your righteous servants have sought refuge from.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_round4',
      'title': 'Dua for Fourth Round of Tawaf',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ وَأَعُوذُ بِكَ مِنَ النَّارِ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ',
      'transliteration': 'Allahumma inni as\'aluka l-jannata wa ma qarraba ilayha min qawlin aw amalin, wa a\'udhu bika mina n-nari wa ma qarraba ilayha min qawlin aw amalin.',
      'translation': 'O Allah, I ask You for Paradise and for that which brings one closer to it, in word and deed, and I seek refuge in You from the Fire and from that which brings one closer to it, in word and deed.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_round5',
      'title': 'Dua for Fifth Round of Tawaf',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      'transliteration': 'Allahumma inni as\'aluka l-huda wa t-tuqa wa l-afafa wa l-ghina.',
      'translation': 'O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_round6',
      'title': 'Dua for Sixth Round of Tawaf',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعِفَّةَ وَالْعَافِيَةَ وَالْمُعَافَاةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      'transliteration': 'Allahumma inni as\'aluka l-iffata wa l-afiyata wa l-mu\'afata fi d-dunya wa l-akhirati.',
      'translation': 'O Allah, I ask You for chastity, well-being, and safety in this world and the Hereafter.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_round7',
      'title': 'Dua for Seventh Round of Tawaf',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ وَالْمُعَافَاةَ فِي الدُّنْيَا وَالْآخِرَةِ اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
      'transliteration': 'Allahumma inni as\'aluka l-afwa wa l-afiyata fi d-dunya wa l-akhirati. Allahumma inni as\'aluka l-afwa wa l-afiyata fi deeni wa dunyaya wa ahli wa mali.',
      'translation': 'O Allah, I ask You for pardon, well-being, and safety in this world and the Hereafter. O Allah, I ask You for pardon and well-being in my religion, my worldly affairs, my family, and my wealth.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_black_stone',
      'title': 'Dua at Black Stone',
      'arabic': 'اللَّهُ أَكْبَرُ اللَّهُمَّ إِيمَانًا بِكَ وَتَصْدِيقًا بِكِتَابِكَ وَوَفَاءً بِعَهْدِكَ وَاتِّبَاعًا لِسُنَّةِ نَبِيِّكَ مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
      'transliteration': 'Allahu akbar. Allahumma imanan bika wa tasdiqan bi-kitabika wa wafa\'an bi-ahdika wa ittiba\'an li-sunnati nabiyyika Muhammadin sallallahu alayhi wa sallam.',
      'translation': 'Allah is the Greatest. O Allah, I perform this Tawaf believing in You, confirming the truth of Your Book, fulfilling my covenant with You, and following the Sunnah of Your Prophet Muhammad, peace be upon him.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_yemeni_corner',
      'title': 'Dua at Yemeni Corner',
      'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      'transliteration': 'Rabbana atina fi d-dunya hasanatan wa fi l-akhirati hasanatan wa qina adhaba n-nar.',
      'translation': 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_tawaf_hatim',
      'title': 'Dua at Hatim',
      'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْفَقْرِ وَالْقِلَّةِ وَالذِّلَّةِ وَأَعُوذُ بِكَ مِنْ أَنْ أَظْلِمَ أَوْ أُظْلَمَ',
      'transliteration': 'Allahumma inni a\'udhu bika mina l-faqri wa l-qillati wa dh-dhillati, wa a\'udhu bika min an azlima aw uzlam.',
      'translation': 'O Allah, I seek refuge in You from poverty, scarcity, and humiliation, and I seek refuge in You from oppressing or being oppressed.',
      'category': 'Tawaf',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    // Sa'i (10)
    {
      'id': 'dua_sai_start',
      'title': 'Dua at Start of Sa\'i',
      'arabic': 'بِدَايَةً مِنَ اللَّهِ وَفَضْلًا مِنْهُ وَرَحْمَةً مِنْهُ وَخَيْرًا مِنْهُ',
      'transliteration': 'Bidayatan mina Allahi wa fadlan minhu wa rahmatan minhu wa khayran minhu.',
      'translation': 'Beginning from Allah, and by His favor, His mercy, and His goodness.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_safa',
      'title': 'Dua on Safa',
      'arabic': 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ وَلِلَّهِ الْحَمْدُ اللَّهُ أَكْبَرُ عَلَى مَا هَدَانَا وَالْحَمْدُ لِلَّهِ عَلَى مَا أَوْلَانَا',
      'transliteration': 'Allahu akbar, Allahu akbar, Allahu akbar, wa lillahi l-hamdu. Allahu akbar ala ma hadana, wa l-hamdu lillahi ala ma awlana.',
      'translation': 'Allah is the Greatest, Allah is the Greatest, Allah is the Greatest, and to Allah belongs all praise. Allah is the Greatest for what He has guided us to, and all praise is due to Allah for what He has bestowed upon us.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_round1',
      'title': 'Dua for First Round of Sa\'i',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      'transliteration': 'Allahumma inni as\'aluka l-afwa wa l-afiyata fi d-dunya wa l-akhirati.',
      'translation': 'O Allah, I ask You for pardon and well-being in this world and the Hereafter.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_round2',
      'title': 'Dua for Second Round of Sa\'i',
      'arabic': 'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
      'transliteration': 'Allahumma ighfir li warhamni wahdini wa \'afini warzuqni.',
      'translation': 'O Allah, forgive me, have mercy on me, guide me, grant me health, and provide for me.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_round3',
      'title': 'Dua for Third Round of Sa\'i',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      'transliteration': 'Allahumma inni as\'aluka l-huda wa t-tuqa wa l-afafa wa l-ghina.',
      'translation': 'O Allah, I ask You for guidance, piety, chastity, and self-sufficiency.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_round4',
      'title': 'Dua for Fourth Round of Sa\'i',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعِفَّةَ وَالْعَافِيَةَ وَالْمُعَافَاةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      'transliteration': 'Allahumma inni as\'aluka l-iffata wa l-afiyata wa l-mu\'afata fi d-dunya wa l-akhirati.',
      'translation': 'O Allah, I ask You for chastity, well-being, and safety in this world and the Hereafter.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_round5',
      'title': 'Dua for Fifth Round of Sa\'i',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَمَا قَرَّبَ إِلَيْهَا مِنْ قَوْلٍ أَوْ عَمَلٍ',
      'transliteration': 'Allahumma inni as\'aluka l-jannata wa ma qarraba ilayha min qawlin aw amalin.',
      'translation': 'O Allah, I ask You for Paradise and for that which brings one closer to it, in word and deed.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_round6',
      'title': 'Dua for Sixth Round of Sa\'i',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ خَيْرِ مَا سَأَلَكَ مِنْهُ عِبَادُكَ الصَّالِحُونَ',
      'transliteration': 'Allahumma inni as\'aluka min khayri ma sa\'alaka minhu ibaduka s-salihoon.',
      'translation': 'O Allah, I ask You for the good that Your righteous servants have asked You for.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_round7',
      'title': 'Dua for Seventh Round of Sa\'i',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
      'transliteration': 'Allahumma inni as\'aluka l-afwa wa l-afiyata fi d-dunya wa l-akhirati. Allahumma inni as\'aluka l-afwa wa l-afiyata fi deeni wa dunyaya wa ahli wa mali.',
      'translation': 'O Allah, I ask You for pardon and well-being in this world and the Hereafter. O Allah, I ask You for pardon and well-being in my religion, my worldly affairs, my family, and my wealth.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_marwah',
      'title': 'Dua on Marwah',
      'arabic': 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ وَلِلَّهِ الْحَمْدُ اللَّهُ أَكْبَرُ عَلَى مَا هَدَانَا وَالْحَمْدُ لِلَّهِ عَلَى مَا أَوْلَانَا',
      'transliteration': 'Allahu akbar, Allahu akbar, Allahu akbar, wa lillahi l-hamdu. Allahu akbar ala ma hadana, wa l-hamdu lillahi ala ma awlana.',
      'translation': 'Allah is the Greatest, Allah is the Greatest, Allah is the Greatest, and to Allah belongs all praise. Allah is the Greatest for what He has guided us to, and all praise is due to Allah for what He has bestowed upon us.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_sai_green_pillars',
      'title': 'Dua Between Green Pillars',
      'arabic': 'رَبِّ اغْفِرْ وَارْحَمْ وَأَنْتَ خَيْرُ الرَّاحِمِينَ',
      'transliteration': 'Rabbi ighfir warham wa anta khayru r-rahimin.',
      'translation': 'My Lord, forgive and have mercy, and You are the best of the merciful.',
      'category': "Sa'i",
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    // Ihram (2)
    {
      'id': 'dua_ihram_intention',
      'title': 'Dua for Ihram Intention',
      'arabic': 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً',
      'transliteration': 'Labbayka Allahumma Umrah.',
      'translation': 'Here I am, O Allah, for Umrah.',
      'category': 'Ihram',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_ihram_talbiyah',
      'title': 'Talbiyah',
      'arabic': 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ',
      'transliteration': 'Labbayka Allahumma labbayk, labbayka la sharika laka labbayk, inna l-hamda wa n-ni\'mata laka wa l-mulk, la sharika lak.',
      'translation': 'Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Verily all praise and blessings are Yours, and all sovereignty, You have no partner.',
      'category': 'Ihram',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    // Halq/Taqsir (1)
    {
      'id': 'dua_halq_completion',
      'title': 'Dua After Halq/Taqsir',
      'arabic': 'اللَّهُمَّ هَذَا مِنْكَ وَلَكَ، فَتَقَبَّلْ مِنِّي',
      'transliteration': 'Allahumma hadha minka wa laka, fa-taqabbal minni.',
      'translation': 'O Allah, this is from You and for You, so accept it from me.',
      'category': 'Halq/Taqsir',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    // General (4)
    {
      'id': 'dua_general_forgiveness',
      'title': 'Dua for Forgiveness',
      'arabic': 'رَبِّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي وَاجْبُرْنِي وَارْفَعْنِي',
      'transliteration': 'Rabbi ighfir li warhamni wahdini wa \'afini warzuqni wajburni warfa\'ni.',
      'translation': 'My Lord, forgive me, have mercy on me, guide me, grant me health, provide for me, compensate me, and raise my status.',
      'category': 'General Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_general_knowledge',
      'title': 'Dua for Beneficial Knowledge',
      'arabic': 'اللَّهُمَّ آتِنَا عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
      'transliteration': 'Allahumma atina \'ilman nafi\'an wa rizqan tayyiban wa \'amalan mutaqabbalan.',
      'translation': 'O Allah, grant us beneficial knowledge, wholesome provision, and accepted deeds.',
      'category': 'General Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_general_entry_masjid',
      'title': 'Dua for Entering Masjid',
      'arabic': 'بِسْمِ اللَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      'transliteration': 'Bismillahi wa s-salaatu wa s-salaamu ala Rasoolillah. Allahumma aftah li abwaba rahmatik.',
      'translation': 'In the Name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, open the gates of Your mercy for me.',
      'category': 'General Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_general_leaving_masjid',
      'title': 'Dua for Leaving Masjid',
      'arabic': 'بِسْمِ اللَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      'transliteration': 'Bismillahi wa s-salaatu wa s-salaamu ala Rasoolillah. Allahumma inni as\'aluka min fadlik.',
      'translation': 'In the Name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, I ask You from Your bounty.',
      'category': 'General Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    // Safety (3)
    {
      'id': 'dua_safety_protection',
      'title': 'Dua for Protection',
      'arabic': 'اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِي وَعَنْ يَمِينِي وَعَنْ شِمَالِي وَمِنْ فَوْقِي وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
      'transliteration': 'Allahumma ihfadhni min bayni yadayya wa min khalfi wa an yameeni wa an shimali wa min fawqi, wa a\'udhu bi-azamatika an ughtala min tahti.',
      'translation': 'O Allah, preserve me from in front of me, from behind me, from my right, from my left, and from above me, and I seek refuge in Your greatness from being taken from below me.',
      'category': 'Safety Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_safety_crowd',
      'title': 'Dua in Crowds',
      'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْبُخْلِ وَالْجُبْنِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
      'transliteration': 'Allahumma inni a\'udhu bika mina l-hammi wa l-hazani wa l-ajzi wa l-kasali wa l-bukhli wa l-jubni wa dala\'i d-dayni wa ghalabati r-rijal.',
      'translation': 'O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debts and from being overpowered by men.',
      'category': 'Safety Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_safety_health',
      'title': 'Dua for Health',
      'arabic': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي اللَّهُمَّ عَافِنِي فِي بَصَرِي لَا إِلَهَ إِلَّا أَنْتَ',
      'transliteration': 'Allahumma \'afini fi badani, Allahumma \'afini fi sam\'i, Allahumma \'afini fi basari, la ilaha illa anta.',
      'translation': 'O Allah, grant me health in my body. O Allah, grant me health in my hearing. O Allah, grant me health in my sight. There is no deity except You.',
      'category': 'Safety Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    // Other (3)
    {
      'id': 'dua_other_zamzam1',
      'title': 'Dua Before Drinking Zamzam',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا وَاسِعًا وَشِفَاءً مِنْ كُلِّ دَاءٍ',
      'transliteration': 'Allahumma inni as\'aluka \'ilman nafi\'an wa rizqan wasi\'an wa shifa\'an min kulli da\'in.',
      'translation': 'O Allah, I ask You for beneficial knowledge, plentiful provision, and healing from every disease.',
      'category': 'Other Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_other_zamzam2',
      'title': 'Zamzam for Thirst of Judgment Day',
      'arabic': 'اللَّهُمَّ إِنِّي أَشْرَبُهُ لِظَمَأٍ يَوْمَ الْقِيَامَةِ',
      'transliteration': 'Allahumma inni ashrabuhu lizama\'in yawma l-qiyamah.',
      'translation': 'O Allah, I drink it for the thirst of the Day of Resurrection.',
      'category': 'Other Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
    {
      'id': 'dua_other_personal',
      'title': 'Personal Supplication',
      'arabic': '',
      'transliteration': '',
      'translation': 'Any personal dua with sincere intention.',
      'category': 'Other Duas',
      'audioUrl': 'https://download.quranicaudio.com/quran/yasser_ad-dussary/002.mp3',
    },
  ];

  for (final dua in duas) {
    await firestore.collection('duas').doc(dua['id'] as String).set(dua);
  }

  // 4. Seed Reminders
  final reminderDocs = await firestore.collection('reminders').get();
  for (final doc in reminderDocs.docs) {
    await doc.reference.delete();
  }

  final reminders = [
    {
      'id': 'reminder_fajr',
      'title': 'Fajr Prayer',
      'description': 'Time for Fajr prayer',
      'reminderTime': DateTime(2024, 1, 1, 5, 30), // 5:30 AM
      'isSystemGenerated': true,
      'isEnabled': true,
      'createdAt': DateTime.now(),
      'lastTriggeredAt': null,
    },
    {
      'id': 'reminder_dhuhr',
      'title': 'Dhuhr Prayer',
      'description': 'Time for Dhuhr prayer',
      'reminderTime': DateTime(2024, 1, 1, 13, 0), // 1:00 PM
      'isSystemGenerated': true,
      'isEnabled': true,
      'createdAt': DateTime.now(),
      'lastTriggeredAt': null,
    },
    {
      'id': 'reminder_asr',
      'title': 'Asr Prayer',
      'description': 'Time for Asr prayer',
      'reminderTime': DateTime(2024, 1, 1, 16, 30), // 4:30 PM
      'isSystemGenerated': true,
      'isEnabled': true,
      'createdAt': DateTime.now(),
      'lastTriggeredAt': null,
    },
    {
      'id': 'reminder_maghrib',
      'title': 'Maghrib Prayer',
      'description': 'Time for Maghrib prayer',
      'reminderTime': DateTime(2024, 1, 1, 18, 30), // 6:30 PM
      'isSystemGenerated': true,
      'isEnabled': true,
      'createdAt': DateTime.now(),
      'lastTriggeredAt': null,
    },
    {
      'id': 'reminder_isha',
      'title': 'Isha Prayer',
      'description': 'Time for Isha prayer',
      'reminderTime': DateTime(2024, 1, 1, 20, 0), // 8:00 PM
      'isSystemGenerated': true,
      'isEnabled': true,
      'createdAt': DateTime.now(),
      'lastTriggeredAt': null,
    },
  ];

  for (final reminder in reminders) {
    await firestore.collection('reminders').doc(reminder['id'] as String).set(reminder);
  }

  print('Seeding complete!');
}
