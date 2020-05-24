let WaterCooler = {
  init(socket) {
    let channel_name = window.location.pathname.replace(/\//g, '')
    let channel = socket.channel(`water_cooler:${channel_name}`, {})
    channel.join()
    this.listenForChats(channel)
  },

  listenForChats(channel) {
    let userName = window.userName
    let userId = window.userId
    let chatWindow = document.getElementById('chat-window')
    let chatDescription = document.getElementsByClassName('chat-description')[0]
    var scrolled = false;

    chatWindow.addEventListener("scroll", function(){ scrolled=true })
    chatWindow.scrollTop = chatWindow.scrollHeight;

    function updateScroll(){
      if (!scrolled) {
        chatWindow.scrollTop = chatWindow.scrollHeight;
      }
    }

    document.getElementById("chat-form").addEventListener('keydown', function(e) {
      if (e.keyCode == 13 && !e.shiftKey) {
        e.preventDefault();
        let userMsg = document.getElementById('user-msg').value

        if (chatDescription) {
          channel.push('shout', {name: userName, body: userMsg, user_id: userId, chat_id: chatDescription.id})
        } else {
          channel.push('shout', {name: userName, body: userMsg, user_id: userId})
        }

        document.getElementById('user-msg').value = ''
      }
    });

    channel.on('shout', payload => {
      let msgBlock = document.createElement('div')
      if (payload.name == window.userName) {
        msgBlock.insertAdjacentHTML('beforeend', `<div class='current-user-message message'>
                                                    <span class='current-user-message-name message-name'>${payload.name}:</span>
                                                    ${payload.body}
                                                  </div>`
        )
      } else {
        msgBlock.insertAdjacentHTML('beforeend', `<div class='message'>
                                                    <span class='message-name'>${payload.name}:</span>
                                                    ${payload.body}
                                                  </div>`
        )
      }
      chatWindow.appendChild(msgBlock)
      updateScroll();
      chatWindow.scrollTop = chatWindow.scrollHeight;
    })
  }
}

export default WaterCooler
