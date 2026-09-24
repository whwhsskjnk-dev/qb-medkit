# qb-medkit

مورد QBCore يجعل استخدام `medkit` يعالج المستخدم نفسه. يزيد الصحة بمقدار
100 نقطة (حتى الحد الأعلى)، ولا ينعش اللاعبين ولا يعتمد على نظام الإسعاف.
يتحقق السيرفر من حالة اللاعب ووجود الآيتم، ثم يستهلك حبة واحدة عند نجاح العلاج.

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
       ['description'] = 'A medical kit that restores the user\'s health'
   },
   ```

3. ضع صورة باسم `medkit.png` في مجلد صور الإنفنتوري، غالبًا:
   `qb-inventory/html/images/medkit.png`.
4. تأكد من تشغيل `qb-core` و`progressbar` قبل هذا المورد. لا يحتاج
   `qb-ambulancejob`. أضف إلى `server.cfg` بعد موارد QBCore:

   ```cfg
   ensure qb-core
   ensure progressbar
   ensure qb-medkit
   ```

5. أعد تشغيل السيرفر، أو نفّذ `refresh` ثم `ensure qb-medkit` من الكونسول.

## الاستخدام

أضف `medkit` إلى الإنفنتوري واستخدمه على شخصيتك وأنت مصاب وغير ساقط. يستغرق
العلاج 5 ثوانٍ ويمكن إلغاؤه. لا يعمل على اللاعب الميت أو في حالة `last stand`.

للاختبار، أعطِ نفسك آيتمًا من أمر الإدارة المتوفر في سيرفرك، ثم استخدمه على
شخصيتك بعد تلقي ضرر.

## التوافق والتعديل

- المورد مخصص لـ QBCore ولا يتصل بأحداث الإسعاف أو الإنعاش.
- غيّر `Config.HealAmount` لتعديل مقدار العلاج، و`Config.ProgressDuration`
  لتعديل مدة الاستخدام في `config.lua`.