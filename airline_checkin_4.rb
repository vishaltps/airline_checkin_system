#!/usr/bin/env ruby
require 'pg'
require 'pry'
require 'faker'
require 'parallel'


# Output a table of current connections to the DB
@conn = PG.connect( dbname: 'airline_checkin', host: 'localhost', port: 5432 )


def reset_seats
	@conn.exec("UPDATE seats SET user_id = null")
end

def get_user(id)
	user = @conn.exec("SELECT * from users where id = #{id}")
	user.entries[0]
end

def get_users
	@conn.exec("SELECT * from users limit 120")
end

def get_seat_by_name(name)
	seat = @conn.exec("SELECT * from seats where name = '#{name}'")
	seat.entries[0]
end

def get_all_seats
	@conn.exec("SELECT * from seats order by id asc")
end

def book(user)
	begin
		user_id = user['id']
		@conn.exec("BEGIN")
		seat = @conn.exec("SELECT * from seats WHERE trip_id = 1 AND user_id IS NULL ORDER BY id LIMIT 1 FOR UPDATE SKIP LOCKED").to_a;
		return puts "seat not available" if seat.empty?
		puts "seat = #{seat.first['name']}"
		puts "#{user['name']} booking seat #{seat.first['name']}"
		seat_id = seat.first['id']
		@conn.exec("UPDATE seats set user_id = #{user_id} where id = '#{seat_id}'")
		@conn.exec("COMMIT")
	rescue StandardError => e
		@conn.exec("ROLLBACK")
		puts "Error occured while booking seat - #{e.message}"
	end
end

def main
	reset_seats
	users = get_users
	# Parallel.map(users, in_threads: 2) { |user| 
	# 	book(user)
	# }
	# Parallel.map(users, in_processes: 2) { |user| 
	# 	book(user)
	# }
	users.each do |user|
		book(user)
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
display_result


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
