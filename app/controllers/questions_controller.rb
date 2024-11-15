# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
    def create
      question_text = question.downcase  # Convierte la pregunta a minúsculas para una comparación sencilla
      @answer = ""
  
      if question_text.include?("precio") || question_text.include?("costo")
        @answer = "Los precios de nuestros productos varían. Puedes revisar la lista completa en nuestra tienda en línea en la página principal."
      elsif question_text.include?("camiseta") || question_text.include?("t-shirt")
        @answer = "Actualmente, tenemos disponibles camisetas de Solidus en varios colores y estilos. Puedes verlos en nuestra tienda en línea."
      elsif question_text.include?("disponible") || question_text.include?("stock")
        @answer = "Para verificar la disponibilidad de un producto específico, consulta nuestra sección de productos en la tienda."
      else
        # Respuesta predeterminada en caso de que la pregunta no tenga coincidencias específicas
        @answer = "¡Hola! Soy tu asistente de compras de Solidus. Pregúntame sobre nuestros productos, precios o cualquier otra cosa en la tienda."
      end
  
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chatbot_path, notice: 'Answer was successfully generated.' }
      end
    rescue => e
      @answer = "Error: #{e.message}"
      Rails.logger.error("Error en QuestionsController: #{e.message}")
    end
  
    private
  
    def question
      params[:question][:question]
    end
  end
  