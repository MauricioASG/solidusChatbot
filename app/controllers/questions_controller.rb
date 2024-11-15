# app/controllers/questions_controller.rb

class QuestionsController < ApplicationController
  def index
    session[:conversation] ||= []
  end

  def create
    question_text = params[:question][:question]
    session[:conversation] ||= []
    session[:conversation] << { type: 'message-user', text: question_text }

    # Comprobamos si la pregunta es sobre un producto específico
    product = find_product_in_question(question_text)
    if product
      # Si se encuentra el producto, generamos una respuesta específica
      variant = product.master
      price = variant.price
      @answer = "El producto '#{product.name}' está disponible por $#{price}. Puedes verlo y comprarlo en nuestra tienda en línea."
    else
      # Si no se identifica un producto específico, enviamos la pregunta a Gemini
      contents = {
        contents: [
          {
            role: 'user',
            parts: [
              { text: question_text }
            ]
          }
        ]
      }

      @answer = ""
      attempts = 0
      max_attempts = 3

      begin
        stream_proc = Proc.new do |part_text, _event, _parsed, _raw|
          @answer += part_text
        end

        attempts += 1
        GEMINI_CLIENT.stream_generate_content(contents, model: 'gemini-1.5-flash', stream: true, &stream_proc)
      rescue GeminiAi::Errors::HTTPError => e
        if e.response.code == 503 && attempts < max_attempts
          sleep(2)
          retry
        else
          @answer = "El modelo está sobrecargado en este momento. Por favor, intenta de nuevo más tarde."
          Rails.logger.error("Gemini AI Error: #{e.message}")
        end
      rescue => e
        @answer = "Error: #{e.message}"
        Rails.logger.error("Gemini AI Error: #{e.message}")
      end
    end

    # Guardar la respuesta en la sesión
    session[:conversation] << { type: 'message-bot', text: @answer }

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chatbot_path }
    end
  end

  private

  def find_product_in_question(question_text)
    products = Spree::Product.all
    product_name = products.map(&:name).find { |name| question_text.downcase.include?(name.downcase) }
    product_name ? Spree::Product.find_by('lower(name) = ?', product_name.downcase) : nil
  end
end