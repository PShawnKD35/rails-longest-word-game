require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def home
  end

  def new
    puts "============"
    p session[:total_score]
    puts "============"
    session[:total_score] = 0 if session[:total_score].nil?
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @grid = params[:grid].split
    @attempt = params[:attempt]
    @start_time = Time.parse(params[:start_time])
    @result = run_game(@attempt, @grid, @start_time, Time.now)
    @total_score = session[:total_score] + @result[:score]
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    alphabet = ('a'..'z').to_a
    grid = []
    grid_size.times { grid << alphabet.sample }
    return grid
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    time = end_time - start_time
    grid.map! { |l| l.downcase }
    # check if attempt is complied with grid
    return { time: time, score: 0, message: "not in the grid" } unless attempt.downcase.split('').all? do |letter|
      grid.include?(letter) ? grid.delete_at(grid.index(letter)) : false
    end
  
    # check if attempt is a correct word
    check_reponse = open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    return { time: time, score: 0, message: "not an english word" } unless JSON.parse(check_reponse)["found"]
  
    # return the score
    return { time: time, score: attempt.size * 20 / time, message: "well done" }
  end

end
