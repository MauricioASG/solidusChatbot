# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
    def index
      render :index  # Asegúrate de que intente renderizar index.html.erb
    end
  
    def create
      # Crea y envía la pregunta a Gemini AI
      contents = {
        contents: {
          role: 'user',
          parts: {
            text: question
          }
        }
      }
  
      @answer = ""
      stream_proc = Proc.new do |part_text, _event, _parsed, _raw|
        @answer += part_text
      end
  
      # Llama a Gemini AI con el contenido y el modelo adecuado
      GEMINI_CLIENT.stream_generate_content(contents, model: 'gemini-1.5-flash', stream: true, &stream_proc)
  
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to questions_path, notice: 'Answer was successfully generated.' }
      end
    rescue => e
      @answer = "Error: #{e.message}"
      Rails.logger.error("Gemini AI Error: #{e.message}")
    end
  
    private
  
    def question
      params[:question][:question]
    end
  end
  