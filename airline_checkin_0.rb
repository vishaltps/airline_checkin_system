#!/usr/bin/env ruby
require 'pg'
require 'pry'
require 'faker'


# Output a table of current connections to the DB
@conn = PG.connect( dbname: 'airline_checkin', host: 'localhost', port: 5432 )


def get_user(id)
	user = @conn.exec("SELECT * from users where id = #{id}")
	user.entries[0]
end

def get_seat_by_name(name)
	seat = @conn.exec("SELECT * from seats where name = '#{name}'")
	seat.entries[0]
end

def get_all_seats
	@conn.exec("SELECT * from seats order by id asc")
end
def book(user_id, seat_id)
	begin
		@conn.exec("BEGIN")
		@conn.exec("UPDATE seats set user_id = #{user_id} where id = '#{seat_id}'")
		@conn.exec("COMMIT")
	rescue StandardError => e
		@conn.exec("ROLLBACK")
		puts "Error occured while booking seat - #{e.message}"
	end
end

def main
	puts "Let's begin the show"
	user_id = ARGV[0]
	puts "user id is #{user_id}"
	user = get_user(user_id)
	puts "Hello #{user['name']}, which seat you want to book?"
	s = STDIN.gets.chomp

	seat = get_seat_by_name(s)

	puts "Trying to book #{seat['name']}"
	result = book(user['id'], seat['id'])

	if(result.error_message.blank?)
		puts "Wooah, #{seat['name']} booked for #{user['name']}"
	else
		puts "Sorry, Seat didn't booked"
	end
end

def display_result
	seats = get_all_seats
	seats.each_with_index do |seat, index|
		if seat && seat['user_id']
			p 'x'
		else
			p '.'
		end
		puts "  " if ((index + 1) %  3 == 0)
		puts "\n" if ((index + 1) %  6 == 0)
	end
end

main
# display_result


	# users = @conn.exec("SELECT * from users order by id asc limit 120")
	# users.each do |user|
	# 	p user['id']
	# 	# book(user)
	# end

# 1.upto(70) do |i|
# 	@conn.exec("INSERT INTO users (name) values ('#{Faker::Name.name}')")
# end

# 
	# 1.upto(20) do |i|
	# 	'A'.upto('F') do |a|
	# 		p "#{i}-#{a}"
	# 		@conn.exec("INSERT INTO seats (name, trip_id) values ('#{i}-#{a}', 1)")
	# 	end
	# end
	





# begin;
# CREATE TABLE airlines(
#     id SERIAL,
#     name varchar(80)
# );
# commit;

# begin;
# CREATE TABLE flights(
#    id SERIAL,
#    airline_id INT,
#    name VARCHAR(255) NOT NULL,
#    PRIMARY KEY(id),
#    CONSTRAINT fk_airline
#       FOREIGN KEY(airline_id) 
# 	  REFERENCES airlines(airline_id)
# );
# commit;
