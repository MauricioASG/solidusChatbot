// /home/mauriciosg/solidusChatbot/app/javascript/voice_recognition.js
document.addEventListener('turbo:load', function () {
  const voiceButton = document.getElementById('voiceButton');
  const questionInput = document.querySelector('input[name="question[question]"]');
  const messagesContainer = document.querySelector('.messages-container');
  let recognition;

  // Función para leer mensajes del asistente en voz alta
  const speakMessage = (message) => {
      const synth = window.speechSynthesis;
      const utterance = new SpeechSynthesisUtterance(message);
      utterance.lang = 'es-ES'; // Idioma español
      synth.speak(utterance);
  };

  // Observar nuevos mensajes del asistente y leerlos automáticamente
  const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
          mutation.addedNodes.forEach((node) => {
              if (node.nodeType === Node.ELEMENT_NODE && node.classList.contains('message-bot')) {
                  const messageText = node.querySelector('p')?.textContent;
                  if (messageText) {
                      speakMessage(messageText); // Leer el mensaje del bot
                  }
              }
          });
      });
  });

  if (messagesContainer) {
      observer.observe(messagesContainer, { childList: true });
  }

  // Reconocimiento de voz para el botón de entrada por voz
  if ('webkitSpeechRecognition' in window) {
      recognition = new webkitSpeechRecognition();
      recognition.continuous = false;
      recognition.interimResults = true;
      recognition.lang = 'es-ES';

      recognition.onstart = function () {
          voiceButton.textContent = 'Grabando...';
          voiceButton.classList.add('recording');
          questionInput.placeholder = 'Escuchando...';
      };

      recognition.onresult = function (event) {
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

      recognition.onerror = function (event) {
          console.error('Error en el reconocimiento de voz:', event.error);
          voiceButton.textContent = 'Voz';
          voiceButton.classList.remove('recording');
          questionInput.placeholder = 'Escribe tu pregunta...';
      };

      recognition.onend = function () {
          voiceButton.textContent = 'Voz';
          voiceButton.classList.remove('recording');
          questionInput.placeholder = 'Escribe tu pregunta...';
      };

      // Manejador del botón de voz
      voiceButton.addEventListener('click', function () {
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
