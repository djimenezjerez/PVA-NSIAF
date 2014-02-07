# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = { username: 'admin', email: 'admin@adsib.gob.bo', password: 'demo123', role: 'super_admin' }
u = User.find_by_username('admin')
unless u.present?
  u = User.new(user)
  u.save!(validate: false)
  puts "User '#{u.username}' created."
end
