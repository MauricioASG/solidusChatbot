# app/controllers/questions_controller.rb
# app/controllers/questions_controller.rb
class QuestionsController < ApplicationController
  def create
    begin
      question_text = params[:question][:question]
      product = find_product_in_question(question_text)

      if product
        variant = product.master
        price = variant.price
        @answer = "El producto '#{product.name}' está disponible por $#{price}. Puedes verlo y comprarlo en nuestra tienda en línea."
      else
        # Respuesta general si no se menciona un producto específico
        if question_text.downcase.include?("hola") || question_text.downcase.include?("quién está ahí")
          @answer = "¡Hola! Soy tu asistente de compras de Solidus. ¿En qué puedo ayudarte hoy?"
        else
          @answer = "Lo siento, no tengo información específica sobre ese producto. Puedes revisar nuestra tienda en línea para ver todos los productos disponibles."
        end
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chatbot_path }
      end
    rescue => e
      @answer = "Error: #{e.message}"
      Rails.logger.error("Gemini AI Error: #{e.message}")
      
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chatbot_path }
      end
    end
  end

  private

  def find_product_in_question(question_text)
    products = Spree::Product.all
    product_name = products.map(&:name).find { |name| question_text.downcase.include?(name.downcase) }

    if product_name
      Spree::Product.find_by('lower(name) = ?', product_name.downcase)
    else
      nil
    end
  end
end
