require 'open-uri'


class GamesController < ApplicationController
  def new
    @letters = []
    i = 0
    until i == 10
      @letters << ('a'..'z').to_a.sample
      i += 1
    end
  end

  def score
    if params[:word].empty?
      # If empty then returns not in the grid
      current_score(true)
    else
      # Else check the presence and compute the score
      current_score(presence_check)
    end
  end

  private

  def presence_check
    # Create an array from your grid
    grclean = params[:letters].split(' ')
    # Empty array that will be filled
    grid_check_array = []
    # Iterate on the attempt answer transformed in an array
    params[:word].downcase.chars.each do |element|
      # Fill the grid_check with the include? results
      grid_check_array << grclean.include?(element)
      # Delete the value included, in order to allow check of multiple values
      grclean.delete_at(grclean.index { |el| el == element }) if grclean.include?(element)
    end
    # Return true if attempt is not included in the grid
    grid_check_array.include?(false)
  end

  def current_score(grid_check)
    # Create a hash with a default score to 0 and compute and store the result time
    @score = {}
    # Parsing the API's JSON
    answer_hash = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{params[:word]}").read)
    # Check if the attempt is included to set the message
    grid_check ? @score[:message] = 'Not in the grid' : @score[:message] = 'Not an english word'
    # Check if the attempt is found knowing that the grid check is ok
    if answer_hash['found'] && !grid_check
      @score[:message] = 'Well done'
      # Scoring system
      @score[:score] = params[:word].length
      # Compute total score if positif
      total_score
    end
  end

  def total_score
    # If the score is empty (nil) then define the first value
    if session[:score].nil?
      session[:score] = @score[:score]
    # Else increment it
    else
      session[:score] += @score[:score]
    end
  end
end
