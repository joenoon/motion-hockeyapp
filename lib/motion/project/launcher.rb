class BITHockeyManagerLauncher

  BITCrashManagerStatusDisabled = 0
  BITCrashManagerStatusAlwaysAsk = 1
  BITCrashManagerStatusAutoSend = 2
  
  def start(&block)
    return if !Object.const_defined?('BITHockeyManager') || (Kernel.const_defined?(:UIApplication) && UIDevice.currentDevice.model.include?('Simulator'))
    (@plist = NSBundle.mainBundle.objectForInfoDictionaryKey('HockeySDK')) && (@plist = @plist.first)
    return unless @plist
    #Retain self since BITHockeyManager keeps a weak reference and app code typically don't retain the BITHockeyManagerLauncher instance. No worry about memory leak since this instance should last for the duration of the app's lifetime.
    self.retain
    if BITHockeyManager.sharedHockeyManager.respond_to? 'configureWithBetaIdentifier:liveIdentifier:delegate:'
      BITHockeyManager.sharedHockeyManager.configureWithBetaIdentifier(@plist['beta_id'], liveIdentifier:@plist['live_id'], delegate:self)
      BITHockeyManager.sharedHockeyManager.crashManager.crashManagerStatus = BITCrashManagerStatusAutoSend
    else
      BITHockeyManager.sharedHockeyManager.configureWithIdentifier(@plist['beta_id'], delegate:self)
      BITHockeyManager.sharedHockeyManager.crashManager.autoSubmitCrashReport = true
    end
    block.call if !block.nil?
    BITHockeyManager.sharedHockeyManager.startManager
    true
  end

end
