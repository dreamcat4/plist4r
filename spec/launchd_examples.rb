

# for irb
require './launchd_plist.rb'

@launchd_plists = []
def plist name=nil, *program_args, &blk
  puts self
  puts self.class.inspect
  puts self.class.to_s.inspect
  name = "com.github.homebrew.#{self.class.to_s.snake_case}" unless name
  @launchd_plists << ::LaunchdPlist.new(prefix, name, *program_args, &blk)
end
@name = "my_formula"
def name
  @name
end
@prefix = `pwd`.delete("\n")
def prefix
  @prefix
end

plist do
  label               "com.github.homebrew.myprogram"
  program_arguments   ["/usr/bin/myprogram"]
  run_at_load         true
  working_directory   "/var/db/myprogram"
  standard_out_path   "/var/log/myprogram.log"
  
  sockets do
    sock_service_name "netbios-ssn"
  end
  sockets do
    sock_service_name "netbios"
    bonjour ['smb']
  end
end
@launchd_plists.first.finalize

def program_arguments array=nil
  array
    @program_arguments = array
  else
    @program_arguments
  end
end

def watch_paths array=nil
  array.class == Array ? @watch_paths = array : @watch_paths
end

def label string
end


@xml_keys = {
  'Label' => 'com.howbrew.haml', 
  'EnvironmentVariables' => {
    'PATH' => '/sbin:/usr/sbin:/bin:/usr/bin',
    'RUBY_LIB' => '/usr/lib/ruby/site_ruby/1.8'
  },

  'ProgramArguments' => [
		"bash", "-l", "-c", "/usr/bin/env", "ruby", "-e", "puts RUBY_VERSION"
		],

  'Sockets' => { 
		'netbios' => {
			'SockServiceName' => 'netbios-ssn',
			'SockFamily' => 'IPv4'
		},

		'direct' => {
		'SockServiceName' => 'netbios-ssn',
		'SockFamily' => 'IPv4',
		'Bonjour' => [
			'smb'
			],		
		}
	},

	'StartCalendarInterval' => {
		'Hour' => 3,
		'Minute' => 15,
		'Weekday' => 6,
	},

  'WatchPaths' => [
		"/Volumes/CD\ ROM",
		"/var/run"
		],

  'RunAtLoad' => true,
  'Debug' => true
}


launchd_plist "myprogram" do
  env   "PATH" => '/sbin:/usr/sbin:/bin:/usr/bin',
    "RUBY_LIB" =>  '/usr/lib/ruby/site_ruby/1.8'    
  end
end


launchd_plist "myprogram" do
  sockets do
    netbios do
      name "netbios-ssn"
    end
    direct do
      name "netbios"
      bonjour ['smb']
    end
  end
end

launchd_plist "myprogram" do
  sockets do
    add "netbios" do
      name "netbios-ssn"
    end
    direct do
      name "netbios"
      bonjour ['smb']
    end
  end
end


launchd_plist "myprogram" do
  socket "netbios", :name => "netbios-ssn"

  socket "direct", :name => "netbios" do
    bonjour ['smb']
  end
end






@launchd << plist "myprogram" do
  start_calendar_interval do
    hour 3
    minute 15
    weekday 6
  end
end

@launchd << plist "com.github.homebrew.myprogram" do
  label               "com.github.homebrew.myprogram"
  program_arguments   [prefix+"bin/myprogram"]
  run_at_load         true
  working_directory   "/var/db/myprogram"
  standard_out_path   "/var/log/myprogram.log"
  # ...
end

@launchd << plist do
  label               "com.github.homebrew.myprogram"
  program_arguments   [prefix+"bin/myprogram"]
  run_at_load         true
  working_directory   "/var/db/myprogram"
  standard_out_path   "/var/log/myprogram.log"
  # ...
end

@launchd << plist "com.apache.couchdb"
@launchd << plist "com.sun.mysql.client", "com.sun.mysql.server"


# o = Haml::Engine.new("%p Haml code!").render
# engine = Haml::Engine.new("%p Haml code!")

# require 'rubygems'
# require 'haml'
# pwd = `pwd`.delete("\n")
# require "#{pwd}/test_plist.feature.rb"
# engine = Haml::Engine.new File.read("#{pwd}/launchd_plist.haml")
# print engine.render(self)



# <key>Sockets</key>
# <dict>
#   <key>Listeners</key>
#   <dict>
#     <key>SockFamily</key>
#     <string>Unix</string>
#     <key>SockPathMode</key>
#     <integer>384</integer>
#     <key>SockPathName</key>
#     <string>/var/run/vpncontrol.sock</string>
#   </dict>
# </dict>


# <key>Sockets</key>
# <dict>
#   <key>Listeners</key>
#   <array>
#     <dict>
#       <key>SockNodeName</key>
#       <string>::1</string>
#       <key>SockServiceName</key>
#       <string>ipp</string>
#     </dict>
#     <dict>
#       <key>SockNodeName</key>
#       <string>127.0.0.1</string>
#       <key>SockServiceName</key>
#       <string>ipp</string>
#     </dict>
#     <dict>
#       <key>SockPathMode</key>
#       <integer>49663</integer>
#       <key>SockPathName</key>
#       <string>/private/var/run/cupsd</string>
#     </dict>
#   </array>
# </dict>

# <key>Sockets</key>
# <dict>
#   <key>listener1</key>
#   <dict>
#     <key>SockNodeName</key>
#     <string>::1</string>
#     <key>SockServiceName</key>
#     <string>ipp</string>
#   </dict>
#   <key>listener2</key>
#   <dict>
#     <key>SockNodeName</key>
#     <string>127.0.0.1</string>
#     <key>SockServiceName</key>
#     <string>ipp</string>
#   </dict>
#   <key>listener3</key>
#   <dict>
#     <key>SockPathMode</key>
#     <integer>49663</integer>
#     <key>SockPathName</key>
#     <string>/private/var/run/cupsd</string>
#   </dict>
# </dict>





# <key>Sockets</key>
# <dict>
#   <key>listener1</key>
#   <array>
#     <dict>
#       <key>SockNodeName</key>
#       <string>::1</string>
#       <key>SockServiceName</key>
#       <string>ipp</string>
#     </dict>
#   </array>
#   <key>listener2</key>
#   <array>
#     <dict>
#       <key>SockNodeName</key>
#       <string>127.0.0.1</string>
#       <key>SockServiceName</key>
#       <string>ipp</string>
#     </dict>
#   </array>
#   <key>listener3</key>
#   <array>
#     <dict>
#       <key>SockPathMode</key>
#       <integer>49663</integer>
#       <key>SockPathName</key>
#       <string>/private/var/run/cupsd</string>
#     </dict>
#   </array>
# </dict>










# <key>Sockets</key>
# <dict>
#   <key>netbios</key>
#   <dict>
#     <key>SockServiceName</key>
#     <string>netbios-ssn</string>
#     <key>SockFamily</key>
#     <string>IPv4</string>
#   </dict>
#   <key>direct</key>
#   <dict>
#     <key>SockServiceName</key>
#     <string>microsoft-ds</string>
#     <key>SockFamily</key>
#     <string>IPv4</string>
#     <key>Bonjour</key>
#     <array>
#       <string>smb</string>
#     </array>
#   </dict>
# </dict>

# <key>StartCalendarInterval</key>
# <dict>
#   <key>Hour</key>
#   <integer>3</integer>
#   <key>Minute</key>
#   <integer>15</integer>
#   <key>Weekday</key>
#   <integer>6</integer>
# </dict>
# 
# <key>WatchPaths</key>
# <array>
#     <string>/Library/Preferences/SystemConfiguration/com.apple.smb.server.plist</string>
# </array>
# 
# <key>Sockets</key>
# <dict>
#   <key>Listeners</key>
#   <dict>
#     <key>SockServiceName</key>
#     <string>bootps</string>
#     <key>SockType</key>
#     <string>dgram</string>
#     <key>SockFamily</key>
#     <string>IPv4</string>
#   </dict>
# </dict>
# 
# <key>inetdCompatibility</key>
# <dict>
#   <key>Wait</key>
#   <true/>
# </dict>
# 
# <key>WatchPaths</key>
# <array>
#   <string><path to some dir></string>
# </array>
# 
# <key>Sockets</key>
# <dict>
#   <key>Listeners</key>
#   <dict>
#     <key>Bonjour</key>
#     <array>
#       <string>ssh</string>
#       <string>sftp-ssh</string>
#     </array>
#     <key>SockServiceName</key>
#     <string>ssh</string>
#   </dict>
# </dict>
# 
# <key>Sockets</key>
# <dict>
#   <key>Listeners</key>
#   <dict>
#     <key>SockPassive</key>
#     <true/>
#     <key>SockServiceName</key>
#     <string>ftp</string>
#     <key>SockType</key>
#     <string>SOCK_STREAM</string>
#   </dict>
# </dict>
# 
# <key>StartCalendarInterval</key>
# <dict>
#   <key>Hour</key>
#   <integer>3</integer>
#   <key>Minute</key>
#   <integer>15</integer>
#   <key>Weekday</key>
#   <integer>6</integer>
# </dict>


