class BITHockeyManagerLauncher

  def customDeviceIdentifierForUpdateManager(updateManager)
    if UIDevice.currentDevice.respond_to?('uniqueIdentifier')
      UIDevice.currentDevice.uniqueIdentifier
    else
      nil
    end
  end
  
end
