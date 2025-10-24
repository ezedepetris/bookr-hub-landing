module LocationHelper
  def self.get_location_data(ip)
    uri = URI("https://ipapi.co/#{ip}/json/")
    response = Net::HTTP.get(uri)
    JSON.parse(response) rescue {}
  end
end
