## 1.1.4

[Commit history](https://github.com/joenoon/motion-hockeyapp/compare/v1.1.3...v1.1.4)

* set the updateManager delegate

## 1.1.3

[Commit history](https://github.com/joenoon/motion-hockeyapp/compare/v1.1.2...v1.1.3)

* no longer implements delegate #customDeviceIdentifierForUpdateManager. if
  you want to implement it, add your own implementation  to BITHockeyManagerLauncher

## 1.1.2

[Commit history](https://github.com/joenoon/motion-hockeyapp/compare/v1.1.1...v1.1.2)

* Added crashManagerStatus enum values inside BITHockeyManagerLauncher, since these
  don't appear to be accessible at runtime:
  - BITCrashManagerStatusDisabled
  - BITCrashManagerStatusAlwaysAsk
  - BITCrashManagerStatusAutoSend
  For example, you could disable sending crash reports via:
    BITHockeyManager.sharedHockeyManager.crashManager.crashManagerStatus = BITHockeyManagerLauncher::BITCrashManagerStatusDisabled

## 1.1.1

[Commit history](https://github.com/joenoon/motion-hockeyapp/compare/6512897ade...v1.1.1)

* The user must now call BITHockeyManagerLauncher.new.start on their own.  This allows for customization.
* Added more examples to README
