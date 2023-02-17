require 'open-uri'
require 'json'
require 'set'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @start_time = Time.parse(params[:start_time])
    @user_entry = params[:user_entry]
    @letters = params[:letters].split(' ')
    @results = run_game(@user_entry, @letters, @start_time, @end_time)
  end

  private

  def generate_grid(grid_size)
    count = 0
    final_grid = []
    while count < grid_size
      final_grid << ('A'..'Z').to_a.sample
      count += 1
    end
    final_grid
  end

  def attempt_in_dictionary(input)
    dictionary_url = 'https://wagon-dictionary.herokuapp.com/'
    url_test = dictionary_url + input
    input_serialized = URI.open(url_test).read
    input_result = JSON.parse(input_serialized)
    input_result['found']
  end

  def attempt_in_block(attempt, grid)
    attempt_array = attempt.upcase.chars
    correctness = 0
    compared_arrays = grid & attempt_array
    if compared_arrays.sort == attempt_array.sort
      correctness = 2
    elsif attempt.upcase.chars.to_set.subset?(grid.to_set) == true
      correctness = 1
    end
    correctness
  end

  def multiplier(time_taken)
    if time_taken < 3
      given_multiplier = 10
    elsif time_taken < 5
      given_multiplier = 8
    elsif time_taken < 8
      given_multiplier = 5
    else
      given_multiplier = 3
    end
    given_multiplier
  end

  def run_game(attempt, grid, start_time, end_time)
    score_multiplier = multiplier((end_time - start_time))
    if attempt_in_dictionary(attempt) && attempt_in_block(attempt, grid) == 2
      { time: (end_time - start_time), message: 'Well done! Your answer is both valid and a real word!', score: (attempt.length * score_multiplier) }
    elsif attempt_in_dictionary(attempt) && attempt_in_block(attempt, grid) == 1
      { time: (end_time - start_time), message: "Sorry, one of those letters is not in the grid", score: (attempt.length * score_multiplier) - 50 }
    elsif attempt_in_dictionary(attempt) == false
      { time: (end_time - start_time), message: "Sorry, that word is not in the dictionary", score: 0 }
    elsif attempt_in_block(attempt, grid).zero?
      { time: (end_time - start_time), message: "Sorry, more than one of those letters are not in the grid", score: 0 }
    end
  end
end

# def run_game(attempt, grid, start_time, end_time)
#   # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
#   # time_taken = (end_time - start_time)
#   score_multiplier = multiplier((end_time - start_time))

#   if attempt_in_dictionary(attempt) && attempt_in_block(attempt, grid) == 2
#     { time: (end_time - start_time), message: "Well done! Your answer is both valid and a real word!", score: (attempt.length * score_multiplier) }
#   elsif attempt_in_dictionary(attempt) && attempt_in_block(attempt, grid) == 1
#     { time: (end_time - start_time), message: "Sorry, one of those letters is not in the grid", score: (attempt.length * score_multiplier) - 50 }
#   elsif attempt_in_dictionary(attempt) == false
#     { time: (end_time - start_time), message: "Sorry, that word is not in the dictionary", score: 0 }
#   elsif attempt_in_block(attempt, grid).zero?
#     { time: (end_time - start_time), message: "Sorry, more than one of those letters are not in the grid", score: 0 }
#   end
# end
