require 'rubygems'
require "csv"
require 'yaml'
require 'mysql'
require 'pp'
require 'dbi'

region_counter = 0;
polygon_id = 0;
polygon_rows = []
sequence = 0;
num_points = 0;

dbh = DBI.connect('DBI:Mysql:electrodrive_analysis:localhost', 'root') 
dbh.execute("TRUNCATE TABLE polygons")
dbh.execute("TRUNCATE TABLE slas")

regions = CSV.read("./geographic_data/sla06aaust/SLA06aAUST.mid")

in_header = true;
File.foreach("./geographic_data/sla06aaust/SLA06aAUST.mif") do |row|
  if (row =~ /^DATA\s*$/)
    in_header = false;
  elsif (in_header)
    #header information is hard-coded. if you want dynamic fancy stuff, you'll need to code it
    next  
  elsif (row =~ /^REGION (\d+)/)
    region_counter += 1
    puts "region #{region_counter} of #{regions.size}";
    puts "This region has #{Regexp.last_match[1]} polygons"
  elsif (row =~ /^\d+\s+$/)
    num_points = Regexp.last_match[0]
    puts "\tThis region has #{num_points} points"  
    polygon_id += 1 
    sequence = 0;
  elsif (row =~ /^(-?\d+\.\d+) (-?\d+\.\d+)\s+$/)
    sequence += 1;
    longitude, lattitude = Regexp.last_match[1],Regexp.last_match[2]
    region_id = regions[region_counter][1]
	begin
		dbh.execute(
		  "insert into polygons (polygon_id, region_id, point_from, point_to,point_sequence) VALUES (?,?,?,?,?)",
		  polygon_id,region_id,longitude,lattitude,sequence
		)
	rescue Exception => e
		puts pp.e
	end
    puts "\t#{sequence} of #{num_points}"
  end
end

dbh.execute(big_insert)

puts "Inserting SLAs"

CSV.foreach("./geographic_data/sla06aaust/SLA06aAUST.mid") do |row|
  dbh.execute("INSERT INTO slas (id, name) values(?,?)", row[1],row[2]);
end

puts "Complete"


