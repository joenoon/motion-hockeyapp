## 1.1.1

[Commit history](https://github.com/joenoon/motion-hockeyapp/compare/v1.1.0...v1.1.1)

* Added crashManagerStatus enum values inside BITHockeyManagerLauncher, since these
  don't appear to be accessible at runtime:
  - BITCrashManagerStatusDisabled
  - BITCrashManagerStatusAlwaysAsk
  - BITCrashManagerStatusAutoSend
  For example, you could disable sending crash reports via:
    BITHockeyManager.sharedHockeyManager.crashManager.crashManagerStatus = BITHockeyManagerLauncher::BITCrashManagerStatusDisabled

## 1.1.0

[Commit history](https://github.com/joenoon/motion-hockeyapp/compare/6512897ade...v1.1.0)

* The user must now call BITHockeyManagerLauncher.new.start on their own.  This allows for customization.
* Added more examples to README
