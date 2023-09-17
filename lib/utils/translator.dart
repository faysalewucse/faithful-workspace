final banglaMonths = [
  'বৈশাখ',
  'জ্যৈষ্ঠ',
  'আষাঢ়',
  'শ্রাবণ',
  'ভাদ্র',
  'আশ্বিন',
  'কার্তিক',
  'অগ্রহায়ণ',
  'পৌষ',
  'মাঘ',
  'ফাল্গুন',
  'চৈত্র'
];

final Map<int, String> banglaWeekDays = {
  7: "রবিবার",
  1: "সোমবার",
  2: "মঙ্গলবার",
  3: "বুধবার",
  4: "বৃহস্পতিবার",
  5: "শুক্রবার",
  6: "শনিবার"
};

final banglaSeasons = ['গ্রীষ্ম', 'বর্ষা', 'শরৎ', 'হেমন্ত', 'শীত', 'বসন্ত'];

final totalDaysInMonthOld = [31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30, 30];
final totalDaysInMonthNew = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30];

bool isLeapYear(int year) =>
    ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);

String translateNumbersToBangla(String number) {
  number = number.replaceAll("0", "০");
  number = number.replaceAll("1", "১");
  number = number.replaceAll("2", "২");
  number = number.replaceAll("3", "৩");
  number = number.replaceAll("4", "৪");
  number = number.replaceAll("5", "৫");
  number = number.replaceAll("6", "৬");
  number = number.replaceAll("7", "৭");
  number = number.replaceAll("8", "৮");
  number = number.replaceAll("9", "৯");
  return number;
}

String translateMonthsToBangla(String month) {
  if(month == '1') month = 'জানুয়ারি';
  if(month == '2') month = 'ফেব্রুয়ারি';
  if(month == '3') month = 'মার্চ';
  if(month == '4') month = 'এপ্রিল';
  if(month == '5') month = 'মে';
  if(month == '6') month = 'জুন';
  if(month == '7') month = 'জুলাই';
  if(month == '8') month = 'আগস্ট';
  if(month == '9') month = 'সেপ্টেম্বর';
  if(month == '10') month = 'অক্টোবর';
  if(month == '11') month = 'নভেম্বর';
  if(month == '12') month = 'ডিসেম্বর';
  return month;
}

String translateHijriMonthsToBangla(String month) {
  if(month == '1') month = 'মহরম';
  if(month == '2') month = 'সফর';
  if(month == '3') month = 'রবিউল আউয়াল';
  if(month == '4') month = 'রবিউস সানি';
  if(month == '5') month = 'জমাদিউল আউয়াল';
  if(month == '6') month = 'জমাদিউস সানি';
  if(month == '7') month = 'রজব';
  if(month == '8') month = 'শাবান';
  if(month == '9') month = 'রমজান';
  if(month == '10') month = 'শওয়াল';
  if(month == '11') month = 'জিলক্বদ';
  if(month == '12') month = 'জিলহজ্জ';
  return month;
}