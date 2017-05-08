require 'pp'
require 'pry'

class DB 
  attr_accessor :hash
  def initialize() 
    @hash = Hash.new
  end
  def get(email) 
    entry = hash[email]
    if entry.nil? then
      hash[email] = {wants: [], wanted_by: []}
    end
    return hash[email]
  end
  def set_wantlist(email, list) 
    entry = get(email)
    entry[:wants] = list
  end
  def add_wantedby(wanter, wantee)
    entry = get(wantee)
    entry[:wanted_by].push(wanter)
  end
  def process_wantlist(email, list)
    set_wantlist(email, list)
    list.each do |wantee|
      add_wantedby(email, wantee)
    end
  end
end

db = DB.new

# Parse the file to populate the db which we will just represent
# using a hash of email => {wants: {email array}, wanted_by: {email array}}
IO.foreach(ARGV[0]) do |line|
  # Iterate through each comma separated value
  user = nil
  wants = []
  values = line.split(",")
  if values.first == 'Timestamp' then next end
  values.each_with_index do |element, index|
    case index
    when 0 # Timestamp, do this later
    when 1 # Username
      user = element.strip
    else # names
      wants.push(element.strip)
    end
  end
  wants = wants.reject {|x| x == '' || x == nil}

  db.process_wantlist(user, wants)
end

# Iterate through all the db entries
# This is less OO unfortunately but whatever..
h = db.hash
h.each do |key, entry|
  puts "Matches for " + key + ":"
  matches = entry[:wants] & entry[:wanted_by]
  matches.each do |m| puts "  " + m end
  puts ""
end

