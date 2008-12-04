Capistrano::Configuration.instance(:must_exist).load do 
  namespace :dwell do
    namespace :imagemagick do
  
      desc "Install the ImageMagick binaries"
      task :install_binary do
        sudo "apt-get install imagemagick -y"
        dwell1.record_install "imagemagick"
      end
      
      desc "Install gems for ImageMagick"
      task :install_gems do
        sudo "apt-get install libmagick++9-dev -y" # needed to build the rmagick gem
        sudo "gem install rmagick mini_magick --no-rdoc --no-ri"
        dwell1.record_install "gem: rmagick, mini_magick"
      end
  
      desc "Install ImageMagick and gems"
      task :install do
        install_binary
        install_gems
      end    

    end
  end
end