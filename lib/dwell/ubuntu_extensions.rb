require 'capistrano'
require 'fileutils'

module Ubuntu1
  
  def lsb_info
    get "/etc/lsb-release", "/tmp/lsb-release"
    all = File.open("/tmp/lsb-release").read
    all.split("\n").inject({}) do |sum,n| 
      l,v=n.split("=")
      sum[l.downcase]=v.gsub(/^"?(.*)/,"\\1").gsub(/"$/,"")
      sum
    end
  end
  
end

Capistrano.plugin :ubuntu1, Ubuntu1
