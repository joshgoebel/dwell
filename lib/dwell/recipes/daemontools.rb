Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :daemontools do

      task :add_intrepid_sources do
        dwell1.append_to_file_if_missing "/etc/apt/sources.list", 
          "deb-src http://archive.ubuntu.com/ubuntu intrepid main restricted universe multiverse"
        sudo "apt-get update"  
      end

      task :build_from_source do
        add_intrepid_sources
        run "#{sudo} rm -rf tmp"
        run "mkdir tmp"
        run "cd tmp && #{sudo} apt-get -b source -t intrepid daemontools-run"
        run "cd tmp && #{sudo} dpkg -i *.deb"
        run "#{sudo} rm -rf tmp"
      end

      task :create_event_d do
        cfg=<<-EOF
        # svscan - daemontools
        # https://bugs.launchpad.net/ubuntu/+source/daemontools-installer/+bug/66615
        #
        start on runlevel 2
        start on runlevel 3
        start on runlevel 4
        start on runlevel 5

        stop on runlevel 0
        stop on runlevel 1
        stop on runlevel 6

        respawn
        exec /usr/bin/svscanboot
        EOF
        put cfg, "/tmp/svscan"
        sudo "mv /tmp/svscan /etc/event.d/svscan"
        sudo "initctl start svscan"
      end
      
      desc "Install daemontools"  
      task :install do
        sudo "touch /etc/inittab" # install blows up if this file is not present
        if ubuntu1.lsb_info[:distrib_codename]=="intrepid"
          sudo "apt-get install daemontools daemontools-run -y"
        else
          puts "You are running #{ubuntu1.lsb_info[:DISTRIB_CODENAME]}. Building .debs from source."
          build_from_source
        end
        create_event_d
        dwell1.record_install "daemontools"
      end
  
    end
  end
end