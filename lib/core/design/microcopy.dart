/// Warm, encouraging, lightly playful copy — never guilt-tripping.
abstract class Microcopy {
  // Wheel
  static const wheelReady = 'Ready to reconnect with someone special?';
  static const wheelSelected = 'Who\'s getting your call today? 💛';
  static const wheelSpinning = 'Spinning the Giro…';
  static const wheelSpinCta = 'Spin the Giro';
  static const wheelEmptyTitle = 'Add a few people first';
  static String wheelEmptyMessage(int min) =>
      'You need at least $min contacts to spin the Giro. Every connection starts with one name.';

  // Contacts
  static const contactsEmptyTitle = 'Your circle starts here';
  static const contactsEmptyMessage =
      'Add someone you care about — we\'ll gently remind you when it\'s time to call.';
  static const contactsAddCta = 'Add someone';

  // Call log
  static const callFeelPrompt = 'How did the call feel?';
  static const callSaved =
      'Great call! You\'re building something beautiful. ✨';
  static const callTapToCall = 'Tap to call';

  // Stats
  static const statsGreeting = 'Look how you\'re showing up for people.';
  static const statsActivity = 'Recent activity';
  static const statsEncouragement =
      'Every call is a little act of love. Keep going.';

  // Status
  static const statusMyTitle = 'Share how you\'re feeling';
  static const statusMySubtitle =
      'Let your GiroCall friends know when you\'re free for a chat.';
  static const statusFeedTitle = 'Friend updates';
  static const statusDueTitle = 'Gentle nudges';
  static const statusDueSubtitle =
      'People who might love hearing from you soon.';
  static const statusEmptyTitle = 'Quiet for now';
  static const statusEmptyMessage =
      'When your contacts share a status, you\'ll see it here.';

  // Profile
  static const profileContactInfo = 'Contact info';
  static const profileSocialLinks = 'Social links';
  static const profilePrivacy = 'Privacy';

  // General
  static const madeWithLove = 'Made with love, for the people who matter.';
}
