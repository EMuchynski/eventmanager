require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  phone_number = phone_number.scan(/\d+/).join

  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 and phone_number[0] == '1'
    phone_number = phone_number[1..-1]
  else
    phone_number = 'invalid phone number'
  end
end

def sort_date(hash, name)
  hash.each { |k, v| puts "#{name}: #{k}, Value: #{v}" if v == hash.values.max }
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir('output') unless Dir.exists?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read('form_letter.erb')
erb_template = ERB.new(template_letter)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = clean_phone_number(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letters(id, form_letter)
end

#display phone numbers
def display_phone_numbers
  contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
  contents.each do |row|
    name = row[:first_name]
    homephone = clean_phone_number(row[:homephone])

    if "#{name}".length > 7
      puts "#{name}\t#{homephone}"
    else
        puts "#{name}\t\t#{homephone}"
    end
  end
end

#display highest users registered hour and weekday
def display_time_targeting
  contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
  hours = Hash.new(0)
  weekdays = Hash.new(0)
  contents.each do |row|
    date = DateTime.strptime(row[:regdate], "%m/%d/%y %H:%M")
    hours[date.hour] += 1
    weekdays[date.strftime('%A')] += 1
  end
  sort_date(hours, 'Hour')
  puts "\n"
  sort_date(weekdays, 'Day of the week')
end

display_phone_numbers
puts "\t"
display_time_targeting
