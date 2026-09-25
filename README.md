# qb-medkit

مورد QBCore مستقل للآيتم `medkit`: ينعش أقرب لاعب ميت أو في حالة `last stand`.
يتحقق السيرفر من حالة اللاعبين والمسافة والآيتم، ثم يستهلك حبة واحدة عند نجاح
الإنعاش. يستخدم المورد حدث الإنعاش الموجود في `qb-ambulancejob` ولا يضيف نظام
مستشفى أو وظائف إسعاف جديدة.

## التثبيت

1. انسخ مجلد `qb-medkit` إلى مجلد الموارد في سيرفرك، مثل:
   `resources/[qb]/qb-medkit`.
2. أضف تعريف الآيتم التالي إلى جدول الآيتمات في
   `qb-core/shared/items.lua`:

   ```lua
   ['medkit'] = {
       ['name'] = 'medkit',
       ['label'] = 'Medical Kit',
       ['weight'] = 2500,
       ['type'] = 'item',
       ['image'] = 'medkit.png',
       ['unique'] = false,
       ['useable'] = true,
       ['shouldClose'] = true,
       ['combinable'] = nil,
       ['description'] = 'A professional medical kit used to revive unconscious players'
   },
   ```

3. ضع صورة باسم `medkit.png` في مجلد صور الإنفنتوري، غالبًا:
   `qb-inventory/html/images/medkit.png`.
4. تأكد من تشغيل `qb-core` و`progressbar` و`qb-ambulancejob` قبل هذا المورد.
   أضف إلى `server.cfg` بعد موارد QBCore:

   ```cfg
   ensure progressbar
   ensure qb-ambulancejob
   ensure qb-medkit
   ```

5. أعد تشغيل السيرفر، أو نفّذ `refresh` ثم `ensure qb-medkit` من الكونسول.

## الاستخدام

أضف `medkit` إلى الإنفنتوري، واقترب من لاعب ميت أو في حالة `last stand`.
استخدم الآيتم؛ سينفذ اللاعب حركة CPR لمدة 5 ثوانٍ، ويمكن إلغاؤها. عند اكتمالها
يُستهلك `medkit` ويُرسل حدث الإنعاش للاعب المستهدف.

للاختبار، أعطِ نفسك آيتمًا من أمر الإدارة المتوفر في سيرفرك، ثم استخدمه على
لاعب آخر في حالة سقوط.

## التوافق والتعديل

- المورد مخصص لـ QBCore ويحتاج حدث الإنعاش `hospital:client:Revive` الافتراضي
  في `qb-ambulancejob`.
- غيّر `Config.TargetDistance` و`Config.ProgressDuration` وبيانات
  `Config.Animation` في `config.lua` عند الحاجة. الحركة الافتراضية مطابقة لحركة
  CPR المستخدمة في مورد `qb-ambulancejob`.