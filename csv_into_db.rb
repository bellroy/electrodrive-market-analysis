require 'rubygems'
require "csv"
require 'yaml'
require 'mysql'
require 'pp'


mysql = Mysql.init()
mysql.connect('localhost', "root", "", "electrodrive_analysis")

sla_id = nil

mysql.query("TRUNCATE TABLE sla_industry_employees");

Dir.foreach("./state_data") do |file|
  next if (file[0] == ".")
  CSV.foreach("./state_data/#{file}") do |row|
    next unless (row.size == 5)
    #fills down the id of the sla
  
    if (row[1].nil?)
      row[1] = sla_id
    else
      sla_id = row[1]
    end
  
    next if (sla_id == "Total" || row[2] == "Total")
  
    print "#{file} "
    pp(row)
  
    mysql.query("INSERT INTO sla_industry_employees (sla_id, industry_class_id, employees) values('#{sla_id}','#{row[2]}','#{row[3]}');")
  end
end

# CSV.foreach("/Volumes/Macintosh HD/Users/scott/Downloads/SLA%20Classification.csv") do |row|
#   next if row[0] == "S/T"
#   puts "Inserting #{row.to_s}"
#   mysql.query("INSERT INTO statistical_local_areas (state_id, id, name,lattitude,longitude,encoded_polyline,encoded_levels) values('#{row[0]}','#{row[1]}','#{row[2]}',''#{row[3]}','#{row[4]}',''#{row[6]}',''#{row[7]}');")
#end

puts "Complete"