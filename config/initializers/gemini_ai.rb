# config/initializers/gemini_ai.rb
require 'gemini-ai'

GEMINI_CLIENT = GeminiAi::Client.new(api_key: ENV['GEMINI_API_KEY'])
