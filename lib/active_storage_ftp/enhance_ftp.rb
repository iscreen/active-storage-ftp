
module ActiveStorageFtp
  class EnhanceFtp < Net::FTP
    def mkdir_p(remove_path)
      paths = remove_path.split('/')
      full_path = paths.first == '~' ? '' : '/'
      paths.each do |path|
        full_path = File.join(full_path, path)
        begin
          mkdir(full_path)
        rescue
        end
      end
    end
  end
end
