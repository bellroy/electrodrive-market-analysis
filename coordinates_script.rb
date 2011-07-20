require 'rubygems'
require "google_spreadsheet"
require 'yaml'
require 'httpclient'
require 'json'
require 'pp'

def lookup_data(type,id)
  endpoint_url = "http://www.ausstats.abs.gov.au/servlet/GMSearchServlet?openagent&ret=b&rtype=#{type}&key=#{id}"
  begin
    client = HTTPClient.new
    result = client.get_content(endpoint_url);
    o = JSON.parse(result);
  rescue JSON::ParserError => e
    puts e
    nil
  end
end

def fill_ids(sheet)
  [2,3].each do |column|
    puts "Running on column #{column}"
    #if the column is empty, fill it with the parent's id
    for row in 2..sheet.num_rows do
      puts "Running on [#{row},#{column}]"
      if (sheet[row,column].empty? and ["SD","SSD"].include?(sheet[row,6]))
        sheet[row,column] = sheet[row-1,column]
      end
    end
  end
end


def fill_coordinates(sheet)
  for row in 2..sheet.num_rows do 
    if (sheet[row,6] == "SLA")
      puts "Setting line #{row} of #{sheet.num_rows}"
      data = lookup_data("sla", sheet[row,4].to_i)
      if (data)
        sheet[row,7] = data[0]["marks"][0]["cenLat"]
        sheet[row,8] = data[0]["marks"][0]["cenLng"]
        sheet[row,9]= data[0]["marks"][0]["polylines"][0]["points"]
        sheet[row,10]= data[0]["marks"][0]["polylines"][0]["levels"]
      end
    end
  end
end

def save(sheet)
  puts "Saving…"
  sheet.save();
  puts "Done!"
end

current_id = nil
config = YAML.load_file("config.yml");

session = GoogleSpreadsheet.login(config["google"]["username"], config["google"]["password"]);
spreadsheet = session.spreadsheet_by_key(config["spreadsheets"]["regions"])

sheet = spreadsheet.worksheets[1]

fill_coordinates(sheet)
save sheet
fill_ids(sheet)
save sheet

