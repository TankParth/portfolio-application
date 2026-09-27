/// Everything the app knows about the portfolio lives here.
/// Content itself is always loaded live from [siteUrl], so updating the
/// website updates the app with no new release.
library;

/// Override for testing unreleased website changes on a phone, e.g.
/// `flutter build apk --debug --dart-define=SITE_URL=http://localhost:5501`
/// with `adb reverse tcp:5501 tcp:5501` and a local server. Release builds
/// don't pass it, so they always load the live site.
const String siteUrl = String.fromEnvironment(
  'SITE_URL',
  defaultValue: 'https://parthtankdev.vercel.app',
);
final String siteHost = Uri.parse(siteUrl).host;

/// Appended to the WebView's user agent. The website's assets/js/platform.js
/// looks for it to add `html.in-app`, which hides web-only bits such as the
/// "Get the Android App" button. Keep in sync with the website.
const String appUserAgentMarker = 'PTPortfolioApp/1.0';

/// If the app sits in the background longer than this, it refetches the site
/// on resume so a long-lived session still picks up new deploys.
const Duration staleAfter = Duration(minutes: 15);

/// Upper bound on the intro, in case the network is slow.
const Duration introMaxWait = Duration(seconds: 7);

class Links {
  static const resume =
      'https://drive.google.com/drive/folders/1wQziwC4fDL3OFcqSDezqg_9xplgtQGkz?usp=drive_link';
  static const email = 'mailto:parth.tank.010@gmail.com';
  static const linkedin = 'https://www.linkedin.com/in/tank-parth';
  static const github = 'https://github.com/TankParth';

  static const shareText =
      "Check out Parth Tank's portfolio — Full Stack Developer "
      '(Java · Spring Boot · React · Angular · Flutter)\n$siteUrl';
}

/// Tech stack shown orbiting in the intro.
const List<String> introStack = [
  'Java',
  'Spring Boot',
  'React',
  'Angular',
  'Flutter',
  'Kafka',
];
