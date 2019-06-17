require 'net/ftp'

module ActiveStorage
  class Service::FTPService < Service
    def initialize(**config)
      @config = config
    end

    def upload(key, io, checksum: nil, content_type: nil, disposition: nil, filename: nil)
      instrument :upload, key: key, checksum: checksum do
        connection do |ftp|
          ftp.put(io, key)
        end
      end
    end

    def download(key, &block)
      if block_given?
        instrument :streaming_download, key: key do
          stream(key, &block)
        end
      else
        instrument :download, key: key do
          stream(data) do |data|
            result += data
          end
          result
        rescue StandardError => _
          raise ActiveStorage::FileNotFoundError
        end
      end
    end

    def update_metadata(key, content_type:, disposition: nil, filename: nil)
      instrument :update_metadata, key: key, content_type: content_type, disposition: disposition do
        # Nothing need to do
      end
    end

    def download_chunk(key, range)
      instrument :download_chunk, key: key, range: range do
        connection do |ftp|
          offset = range.begin
          ftp.retrbinary("RETR #{key}", range.begin) do |data|
            yield data
            offset += data
          end
        end
      rescue StandardError => _
        raise ActiveStorage::FileNotFoundError
      end
    end

    def delete(key)
      instrument :delete, key: key do
        connection do |ftp|
          ftp.delete(key)
        end
      end
    end

    def delete_prefixed(prefix)
      instrument :delete_prefixed, prefix: prefix do
        connection do |ftp|
          files = ftp.list("#{prefix}*")
          files.each { |f| f.delete(f) }
        end
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        connection do |ftp|
          data = ftp.retrbinary("RETR #{key}")
          answer = !data.nil?
          payload[:exist] = answer
          answer
        end
      end
    end

    def url(key, expires_in:, filename:, content_type:, disposition:)
      instrument :url, key: key do |payload|
        generated_url = url_for(key)
        payload[:url]
        generated_url
      end
    end

    def url_for_direct_upload(key, expires_in:, checksum:, **)
      instrument :url, key: key do |payload|
        raise 'not support direct upload'
        # generated_url = bucket.signed_url key, method: "PUT", expires: expires_in, content_md5: checksum

        # payload[:url] = generated_url

        # generated_url
      end
    end

    def headers_for_direct_upload(key, checksum:, **)
      { 'Content-MD5' => checksum }
    end

    private

    attr_reader :config

    def connection
      ::ActiveStorageFtp::EnhanceFtp.open(
        ftp_host,
        username: ftp_username,
        password: ftp_password,
        port: ftp_port,
        passive: ftp_passive,
        # ssl: ftp_ssl,
        # debug_mode: ftp_debug_mode
      ) do |ftp|
        begin
          ftp.chdir(ftp_folder)
        rescue StandardError => _
          ftp.mkdir_p(ftp_folder)
          ftp.chdir(ftp_folder)
        end
        yield ftp
      end
    end

    def path_for(key) #:nodoc:
      File.join(ftp_folder, key)
    end

    def url_for(key)
      file_url = [ftp_url, ftp_folder, key].join('/')
      file_url
    end

    # Reads the file for the given key in chunks, yielding each to the block.
    def stream(key)
      connection do |ftp|
        ftp.retrbinary("RETR #{key}", 5.megabytes) do |data|
          yield data
        end
      end
    end

    def ftp_host
      config.fetch(:host)
    end

    def ftp_username
      config.fetch(:username)
    end

    def ftp_password
      config.fetch(:password)
    end

    def ftp_port
      config.fetch(:port)
    end

    def ftp_folder
      config.fetch(:folder)
    end

    def ftp_ssl
      config.fetch(:ssl, false)
    end

    def ftp_passive
      config.fetch(:passive, true)
    end

    def ftp_url
      config.fetch(:url)
    end

    def ftp_debug_mode
      config.fetch(:debug_mode, false)
    end
  end
end
