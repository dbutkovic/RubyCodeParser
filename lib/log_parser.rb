# frozen_string_literal: true
require "ipaddress"

class LogParser

  def self.processing
    if ARGV.empty?
      puts "No arguments provided! Using default 'webserver.log'"
      ARGV[0] = "webserver.log"
    end

    file = File.open(ARGV[0])
    file_data = file.readlines
    file.close

    file_data_valid = extract_data_from_file(file_data)

    urls = extract_unique_urls(file_data_valid)
    ips = extract_unique_ips(file_data_valid)

    views_per_url = []
    urls.each do |url|
      views = file_data_valid.flatten.count(url)
      views_per_url << [ url , views ]
    end

    views_per_url_for_unique_ip = []
    urls.each do |url|
      count = 0
      ips.each do |ip|
        if file_data_valid.include? [url, ip]
          count += 1
        end
      end
      views_per_url_for_unique_ip << [ url , count ]
    end

    self.print_result(views_per_url, "Views per url")
    self.print_result(views_per_url_for_unique_ip, "Unique views per url")

    return [ views_per_url , views_per_url_for_unique_ip ]
  end

  private

  def self.extract_data_from_file(file_data)
    file_data_mapped = file_data.map { |data| data.split(" ") }
    return file_data_mapped.delete_if { |element| element[0] == nil || element[1] == nil || !IPAddress.valid?(element[1]) }
  end

  def self.print_result(views, message)
    views = views.sort_by { |x,y| -y }
    puts message

    for view in views do
      puts "#{view[0]} #{view[1]}" +  "#{views.size > 1 ? " visit." : " visits."}"
    end
    puts ""
  end

  def self.extract_unique_ips(file_data_valid)
    file_data_valid.map { |data| data[1] }.uniq
  end

  def self.extract_unique_urls(file_data_valid)
    file_data_valid.map { |data| data[0] }.uniq
  end

end

LogParser.processing
