MAMUN SOCIAL — Flutter Starter

এই ZIP-এ যা আছে:
- lib/main.dart: লগইন/রেজিস্ট্রেশন ও টেক্সট পোস্ট ফিডের প্রাথমিক কোড
- pubspec.yaml: Flutter ও Firebase dependency

গুরুত্বপূর্ণ:
এটি সোর্স কোডের স্টার্টার ZIP, APK নয়। এই ZIP-টি এখানে Flutter SDK দিয়ে build/test করা হয়নি।
Firebase সংযোগ ছাড়া অ্যাপ চালু হবে না।

সেটআপ:
1. কম্পিউটারে Flutter SDK ও Android Studio ইনস্টল থাকতে হবে।
2. ZIP extract করে mamun_social_starter ফোল্ডারে terminal খুলুন।
3. `flutter create . --platforms=android` চালান।
4. Firebase Console-এ Android app-এর package name `com.mamun.social` নিশ্চিত করুন।
5. Firebase থেকে ওই Android app-এর `google-services.json` ডাউনলোড করে `android/app/google-services.json`-এ রাখুন।
6. Firebase Console > Authentication > Sign-in method থেকে Email/Password চালু করুন।
7. Firebase Console > Firestore Database তৈরি করুন।
8. `flutter pub get` চালান।
9. `flutter run` দিয়ে পরীক্ষা করুন।
10. পরীক্ষা সফল হলে `flutter build apk --release` চালিয়ে APK তৈরি করুন।

নোট:
- Firebase Firestore Rules নিরাপদভাবে সেট করতে হবে; পরীক্ষার জন্যও স্থায়ীভাবে public read/write rules ব্যবহার করবেন না।
- এই প্রাথমিক সংস্করণে ছবি/ভিডিও আপলোড, লাইক, কমেন্ট, ফলো এবং চ্যাট এখনো যোগ করা হয়নি।
- APK তৈরি ও বাস্তব ডিভাইসে পরীক্ষা করা হয়নি।
