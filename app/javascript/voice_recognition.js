// /home/mauriciosg/solidusChatbot/app/javascript/voice_recognition.js

document.addEventListener('turbo:load', function() {
    const voiceButton = document.getElementById('voiceButton');
    const questionInput = document.querySelector('input[name="question[question]"]');
    let recognition;
  
    // Verificar soporte del navegador para reconocimiento de voz
    if ('webkitSpeechRecognition' in window) {
      recognition = new webkitSpeechRecognition();
      recognition.continuous = false;
      recognition.interimResults = true;
      recognition.lang = 'es-ES';
  
      recognition.onstart = function() {
        voiceButton.textContent = 'Grabando...';
        voiceButton.classList.add('recording');
        questionInput.placeholder = 'Escuchando...';
      };
  
      recognition.onresult = function(event) {
        let finalTranscript = '';
        for (let i = event.resultIndex; i < event.results.length; i++) {
          if (event.results[i].isFinal) {
            finalTranscript += event.results[i][0].transcript;
          } else {
            questionInput.value = event.results[i][0].transcript;
          }
        }
        
        if (finalTranscript !== '') {
          questionInput.value = finalTranscript;
        }
      };
  
      recognition.onerror = function(event) {
        console.error('Error en el reconocimiento de voz:', event.error);
        voiceButton.textContent = 'Voz';
        voiceButton.classList.remove('recording');
        questionInput.placeholder = 'Escribe tu pregunta...';
      };
  
      recognition.onend = function() {
        voiceButton.textContent = 'Voz';
        voiceButton.classList.remove('recording');
        questionInput.placeholder = 'Escribe tu pregunta...';
      };
  
      // Manejador del botón de voz
      voiceButton.addEventListener('click', function() {
        if (voiceButton.classList.contains('recording')) {
          recognition.stop();
        } else {
          recognition.start();
        }
      });
    } else {
      voiceButton.style.display = 'none';
      console.log('El reconocimiento de voz no está soportado en este navegador.');
    }
  });