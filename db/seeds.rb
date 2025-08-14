# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create sample microposts
Micropost.create!(content: "First micropost! Hello world!")
Micropost.create!(content: "Learning Ruby on Rails is awesome!")
Micropost.create!(content: "This is my third micropost. Building a sample app.")
Micropost.create!(content: "Rails makes web development fun and easy!")
Micropost.create!(content: "Just finished implementing the microposts feature!")
