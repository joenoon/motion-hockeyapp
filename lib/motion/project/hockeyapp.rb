# Copyright (c) 2012, Joe Noon <joenoon@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

class HockeyAppConfig

  attr_accessor :api_token, :beta_id, :live_id, :status, :notify, :notes_type, :is_cocoapod

  def set(var, val)
    @config.info_plist['HockeySDK'] ||= [{}]
    @config.info_plist['HockeySDK'].first[var.to_s] = val
    send("#{var}=", val)
  end

  def initialize(config)
    @config = config
  end

  def inspect
    {:api_token => api_token, :beta_id => beta_id, :live_id => live_id, :status => status, :notify => notify, :notes_type => notes_type}.inspect
  end

  def configure!
    @configured ||= begin
      unless is_cocoapod
        @config.vendor_project('vendor/HockeySDK/HockeySDK.framework', :static, products: ['HockeySDK'], headers_dir: 'Headers')
        @config.resources_dirs += [ './vendor/HockeySDK/Resources' ]
        @config.frameworks += [ 'HockeySDK' ]
      end
      true
    end
  end

end

module Motion; module Project; class Config

  attr_accessor :hockeyapp_mode

  variable :hockeyapp

  def hockeyapp(&block)
    @hockeyapp ||= HockeyAppConfig.new(self)
    @hockeyapp.instance_eval(&block) unless block.nil?
    @hockeyapp.configure!
    @hockeyapp
  end

  def hockeyapp?
    @hockeyapp_mode == true
  end

end; end; end

Motion::Project::App.setup do |app|
  app.files.push(File.join(File.dirname(__FILE__), "launcher.rb"))
end

namespace 'hockeyapp' do
  desc "Submit an archive to HockeyApp"
  task :submit do

    App.config_without_setup.hockeyapp_mode = true

    # Retrieve configuration settings.
    prefs = App.config.hockeyapp

    App.fail "A value for app.hockeyapp.api_token is mandatory" unless prefs.api_token

    Rake::Task["archive#{App.config_mode == :release ? ':distribution' : ''}"].invoke

    # An archived version of the .dSYM bundle is needed.
    app_dsym = if App.config.respond_to?(:app_bundle_dsym)
      App.config.app_bundle_dsym('iPhoneOS')
    else
      App.config.app_bundle('iPhoneOS').sub(/\.app$/, '.dSYM')
    end
    app_dsym_zip = app_dsym + '.zip'
    if !File.exist?(app_dsym_zip) or File.mtime(app_dsym) > File.mtime(app_dsym_zip)
      Dir.chdir(File.dirname(app_dsym)) do
        args = "/usr/bin/zip", "-q", "-r", "#{File.basename(app_dsym)}.zip", File.basename(app_dsym)
        App.info 'Run', args.join(" ")
        system(*args)
      end
    end

    prefs.status ||= "2"
    prefs.notify ||= "0"
    prefs.notes_type ||= "1"

    cmd = %Q{/usr/bin/curl "https://rink.hockeyapp.net/api/2/apps" -F status="$status" -F notify="$notify" -F notes="$notes" -F notes_type="$notes_type" -F ipa="$ipa" -F dsym="$dsym" -H "$header"}

    env = {
      "notes" => ENV['notes'].to_s,
      "status" => prefs.status.to_s,
      "notify" => prefs.notify.to_s,
      "notes_type" => prefs.notes_type.to_s,
      "ipa" => "@#{App.config.archive}",
      "dsym" => "@#{app_dsym_zip}",
      "header" => "X-HockeyAppToken: #{prefs.api_token}"
    }
    App.info 'Run', "#{env.inspect} #{cmd}"
    system(env, cmd)
  end

  desc "Records if the device build is created in hockeyapp mode, so some things can be cleaned up between mode switches"
  task :record_mode do
    hockeyapp_mode = App.config_without_setup.hockeyapp_mode ? "True" : "False"

    platform = 'iPhoneOS'
    bundle_path = App.config.app_bundle(platform)
    build_dir = File.join(App.config.versionized_build_dir(platform))
    FileUtils.mkdir_p(build_dir)
    previous_hockeyapp_mode_file = File.join(build_dir, '.hockeyapp_mode')

    previous_hockeyapp_mode = "False"
    if File.exist?(previous_hockeyapp_mode_file)
      previous_hockeyapp_mode = File.read(previous_hockeyapp_mode_file).strip
    end
    if previous_hockeyapp_mode != hockeyapp_mode
      App.info "HockeyApp", "Cleaning executable, Info.plist, and PkgInfo for mode change (was: #{previous_hockeyapp_mode}, now: #{hockeyapp_mode})"
      [
        App.config.app_bundle_executable(platform), # main_exec
        File.join(bundle_path, 'Info.plist'), # bundle_info_plist
        File.join(bundle_path, 'PkgInfo') # bundle_pkginfo
      ].each do |path|
        rm_rf(path) if File.exist?(path)
      end
    end
    File.open(previous_hockeyapp_mode_file, 'w') do |f|
      f.write hockeyapp_mode
    end
  end
end

desc 'Same as hockeyapp:submit'
task 'hockeyapp' => 'hockeyapp:submit'

# record hockeyapp mode before every device build
task 'build:device' => 'hockeyapp:record_mode'
