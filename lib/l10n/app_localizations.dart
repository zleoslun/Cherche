import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to your account'**
  String get signUpTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter Full name'**
  String get enterFullName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email Address'**
  String get enterEmail;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a Password'**
  String get createPassword;

  /// No description provided for @passwordRule.
  ///
  /// In en, this message translates to:
  /// **'Must be 8 characters'**
  String get passwordRule;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Email to send Reset Link'**
  String get resetPasswordTitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @featuredDevotions.
  ///
  /// In en, this message translates to:
  /// **'Featured Devotions'**
  String get featuredDevotions;

  /// No description provided for @devotion.
  ///
  /// In en, this message translates to:
  /// **'Devotion'**
  String get devotion;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comment;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get addComment;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @prayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get prayers;

  /// No description provided for @sharePrayers.
  ///
  /// In en, this message translates to:
  /// **'Share Prayers'**
  String get sharePrayers;

  /// No description provided for @writePrayers.
  ///
  /// In en, this message translates to:
  /// **'Write about Your Prayers'**
  String get writePrayers;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @testimonies.
  ///
  /// In en, this message translates to:
  /// **'Testimonies'**
  String get testimonies;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No Comments yet'**
  String get noComments;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @supportAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Support and Info'**
  String get supportAndInfo;

  /// No description provided for @noVideo.
  ///
  /// In en, this message translates to:
  /// **'No Available Video Yet'**
  String get noVideo;

  /// No description provided for @checkBack.
  ///
  /// In en, this message translates to:
  /// **'Check Back Later'**
  String get checkBack;

  /// No description provided for @readyDevotions.
  ///
  /// In en, this message translates to:
  /// **'Ready for Today\'s devotions?'**
  String get readyDevotions;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// No description provided for @videosShared.
  ///
  /// In en, this message translates to:
  /// **'Videos Shared'**
  String get videosShared;

  /// No description provided for @totalVideos.
  ///
  /// In en, this message translates to:
  /// **'Total Videos'**
  String get totalVideos;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @recentDevotions.
  ///
  /// In en, this message translates to:
  /// **'Recent Devotions'**
  String get recentDevotions;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @shareDevotions.
  ///
  /// In en, this message translates to:
  /// **'Share Your Devotions'**
  String get shareDevotions;

  /// No description provided for @todaysUploads.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Uploads'**
  String get todaysUploads;

  /// No description provided for @uploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Upload Complete'**
  String get uploadComplete;

  /// No description provided for @uploadVideo1.
  ///
  /// In en, this message translates to:
  /// **'Upload Video #1'**
  String get uploadVideo1;

  /// No description provided for @morningDevotion.
  ///
  /// In en, this message translates to:
  /// **'Share your morning devotion or prayer'**
  String get morningDevotion;

  /// No description provided for @uploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully uploaded'**
  String get uploadedSuccess;

  /// No description provided for @uploadVideo2.
  ///
  /// In en, this message translates to:
  /// **'Upload Video #2'**
  String get uploadVideo2;

  /// No description provided for @eveningReflection.
  ///
  /// In en, this message translates to:
  /// **'Share an evening reflection or testimony'**
  String get eveningReflection;

  /// No description provided for @chooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Choose video file'**
  String get chooseVideo;

  /// No description provided for @changeVideo.
  ///
  /// In en, this message translates to:
  /// **'Change video'**
  String get changeVideo;

  /// No description provided for @videoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Title'**
  String get videoTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @shareCommunity.
  ///
  /// In en, this message translates to:
  /// **'Share with community'**
  String get shareCommunity;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Current Password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get enterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @deleteVideo.
  ///
  /// In en, this message translates to:
  /// **'Delete Video'**
  String get deleteVideo;

  /// No description provided for @deleteVideoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this video?'**
  String get deleteVideoConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action can\'t be undone'**
  String get actionCannotBeUndone;

  /// No description provided for @videoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Video deleted successfully'**
  String get videoDeleted;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @startSharing.
  ///
  /// In en, this message translates to:
  /// **'Start sharing your devotions with the community!'**
  String get startSharing;

  /// No description provided for @enterVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a video title'**
  String get enterVideoTitle;

  /// No description provided for @professionalStatus.
  ///
  /// In en, this message translates to:
  /// **'Professional Status'**
  String get professionalStatus;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @incorrectCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get incorrectCurrentPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8 characters'**
  String get passwordTooShort;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get imageUploadFailed;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @beFirstToSharePrayer.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share a prayer'**
  String get beFirstToSharePrayer;

  /// No description provided for @prayerEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Can\'t be empty... write something about your prayer'**
  String get prayerEmptyError;

  /// No description provided for @shareThoughtsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your thoughts!'**
  String get shareThoughtsPrompt;

  /// No description provided for @shareTestimonies.
  ///
  /// In en, this message translates to:
  /// **'Share Testimonies'**
  String get shareTestimonies;

  /// No description provided for @writeTestimony.
  ///
  /// In en, this message translates to:
  /// **'Write about your testimony...'**
  String get writeTestimony;

  /// No description provided for @emptyTestimonyError.
  ///
  /// In en, this message translates to:
  /// **'Can\'t be empty... write something about your testimony'**
  String get emptyTestimonyError;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email.'**
  String get resetLinkSent;

  /// No description provided for @resetLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link'**
  String get resetLinkFailed;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Successful Welcome!'**
  String get signUpSuccess;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in Successfully, Welcome!'**
  String get loginSuccess;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 20 characters'**
  String get nameTooLong;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password exceed the limit'**
  String get passwordTooLong;

  /// No description provided for @confirmPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get confirmPasswordsDoNotMatch;

  /// No description provided for @uploadNewVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload New Video'**
  String get uploadNewVideo;

  /// No description provided for @shareDevotionComunity.
  ///
  /// In en, this message translates to:
  /// **'Share your devotion with the community'**
  String get shareDevotionComunity;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @unlimitedDevotions.
  ///
  /// In en, this message translates to:
  /// **'You can upload unlimited devotions'**
  String get unlimitedDevotions;

  /// No description provided for @readyForNextUpload.
  ///
  /// In en, this message translates to:
  /// **'Ready for next upload'**
  String get readyForNextUpload;

  /// No description provided for @uploadAnotherDevotion.
  ///
  /// In en, this message translates to:
  /// **'Upload another devotion to share with the community'**
  String get uploadAnotherDevotion;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// No description provided for @dailyDevotionsLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Devotions Limit'**
  String get dailyDevotionsLimit;

  /// No description provided for @devotionsManagement.
  ///
  /// In en, this message translates to:
  /// **'Devotions Management'**
  String get devotionsManagement;

  /// No description provided for @errorSavingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get errorSavingSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully!'**
  String get settingsSaved;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @scheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get scheduleForLater;

  /// No description provided for @videoAutoPublish.
  ///
  /// In en, this message translates to:
  /// **'Your video will be automatically published at the selected time'**
  String get videoAutoPublish;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateTime;

  /// No description provided for @scheduleTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Schedule time must be at least 2 minutes from now'**
  String get scheduleTimeLimit;

  /// No description provided for @scheduledVideos.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Videos'**
  String get scheduledVideos;

  /// No description provided for @publishesIn.
  ///
  /// In en, this message translates to:
  /// **'Publishes in'**
  String get publishesIn;

  /// No description provided for @videosScheduled.
  ///
  /// In en, this message translates to:
  /// **'Videos scheduled'**
  String get videosScheduled;

  /// No description provided for @dateTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year} at {time}'**
  String dateTimeFormat(Object day, Object month, Object time, Object year);

  /// No description provided for @atTime.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atTime;

  /// No description provided for @daysAndHours.
  ///
  /// In en, this message translates to:
  /// **'{days} days, {hours} hours'**
  String daysAndHours(Object days, Object hours);

  /// No description provided for @daysOnly.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysOnly(Object days);

  /// No description provided for @hoursAndMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours, {minutes} minutes'**
  String hoursAndMinutes(Object hours, Object minutes);

  /// No description provided for @hoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String hoursOnly(Object hours);

  /// No description provided for @minutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesOnly(Object minutes);

  /// No description provided for @anyMoment.
  ///
  /// In en, this message translates to:
  /// **'any moment'**
  String get anyMoment;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @publishNow.
  ///
  /// In en, this message translates to:
  /// **'Publish Now'**
  String get publishNow;

  /// No description provided for @videoRescheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Video rescheduled for'**
  String get videoRescheduledFor;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minuteAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minuteAgo(Object count);

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hourAgo(Object count);

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String dayAgo(Object count);

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenterTitle;

  /// No description provided for @helpCenterContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Cherche Help Center, your Christian app dedicated to spiritual and community connection. Here, you will find detailed answers to common questions about using the app, such as managing your 1 CHF/€ per day subscription (approximately 31 CHF/€ per month), cancelling at any time without commitment, or tips for navigating our features inspired by biblical values. Remember, mutual respect is at the heart of our community, and all interactions should promote kindness and confidentiality – sharing content outside the app is strictly prohibited. If you cannot find what you are looking for, contact us for personalized assistance.'**
  String get helpCenterContent;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTitle;

  /// No description provided for @contactSupportContent.
  ///
  /// In en, this message translates to:
  /// **'For any questions or technical issues with Cherche, our support team is available through this contact form. As a Christian app, we are committed to responding with empathy and efficiency, respecting our guiding principles.'**
  String get contactSupportContent;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @termsOfServiceContent.
  ///
  /// In en, this message translates to:
  /// **'The Cherche Terms of Service define the rules for a harmonious experience within our Christian app. By subscribing for 1 CHF/€ per day (equivalent to 31 CHF/€ per month), you agree that there are no refunds, but you have full flexibility to cancel at any time. Respect is paramount: all interactions must reflect Christian values of compassion and integrity, with a strict prohibition on sharing content or personal information outside the app. Privacy is ensured, and any violation may result in suspension to maintain the safety and peace of our community.'**
  String get termsOfServiceContent;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'The Cherche Privacy Policy, for a Christian app focused on faith and authentic connections, protects your data with the utmost care. We only collect information necessary for your experience, do not share it with third parties, and strictly forbid any sharing of content outside the app. Your subscription of 1 CHF/€ per day (31 CHF/€ monthly) is securely managed, non-refundable, but cancellable at any time. Respecting privacy is a core value, aligned with our biblical principles, so you can explore and interact with confidence and peace of mind.'**
  String get privacyPolicyContent;

  /// No description provided for @premiumContentOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium Content Only'**
  String get premiumContentOnly;

  /// No description provided for @subscribeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to unlock all videos and get exclusive content!'**
  String get subscribeToUnlock;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountConfirmation;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent. We\'ll get back to you soon!'**
  String get messageSent;

  /// No description provided for @messageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send your message. Please try again later.'**
  String get messageFailed;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @typeMessageHere.
  ///
  /// In en, this message translates to:
  /// **'Type your message here...'**
  String get typeMessageHere;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message'**
  String get enterMessage;

  /// No description provided for @messageTooShort.
  ///
  /// In en, this message translates to:
  /// **'Message should be at least 10 characters'**
  String get messageTooShort;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @mails.
  ///
  /// In en, this message translates to:
  /// **'Mails'**
  String get mails;

  /// No description provided for @searchMails.
  ///
  /// In en, this message translates to:
  /// **'Search mails'**
  String get searchMails;

  /// No description provided for @deleteMail.
  ///
  /// In en, this message translates to:
  /// **'Delete Mail'**
  String get deleteMail;

  /// No description provided for @confirmDeleteMail.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this mail?'**
  String get confirmDeleteMail;

  /// No description provided for @subscribeToUnlock1.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to unlock and get exclusive content!'**
  String get subscribeToUnlock1;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
