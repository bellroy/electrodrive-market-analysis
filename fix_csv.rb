require 'rubygems'
require "csv"
require 'yaml'
require 'mysql'
require 'pp'


mysql = Mysql.init()
mysql.connect('localhost', "root", "", "electrodrive_analysis")

current_id = nil

#fills down the id of the sla
Dir.foreach("./state_data") do |file|
  next if (file == "." or file == "..")
  puts file
  CSV.foreach("./state_data/#{file}") do |row|
    puts pp(row)
  #   puts "current_id = #{current_id}"
  #   if row[0].nil?
  #     break if (current_id == "Total")
  #     next if (current_id == "sla_id")
  #     puts "Filling"
  #     row[0] = current_id
  #   else
  #     puts "Setting new ID"
  #     current_id = row[0]
  #   end
  # 
  #   if (row[1].length == 3)
  #     row[1] = "0"+row[1]
  #   end
  # 
  #   mysql.query("INSERT INTO sla_industry_employees (sla_id, industry_class_id, employees) values('#{row[0]}','#{row[1]}','#{row[2]}');")
  end
end

# CSV.foreach("/Volumes/Macintosh HD/Users/scott/Downloads/SLA%20Classification.csv") do |row|
#   next if row[0] == "S/T"
#   puts "Inserting #{row.to_s}"
#   mysql.query("INSERT INTO statistical_local_areas (state_id, id, name,lattitude,longitude,encoded_polyline,encoded_levels) values('#{row[0]}','#{row[1]}','#{row[2]}',''#{row[3]}','#{row[4]}',''#{row[6]}',''#{row[7]}');")
#end

puts "Complete"