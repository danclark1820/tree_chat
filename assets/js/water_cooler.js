let WaterCooler = {
  init(socket) {
    let channel_name = window.location.pathname.replace(/\/c\//g, '')
    let channel = socket.channel(`water_cooler:${channel_name}`, {})
    channel.join()
    this.listenForChats(channel)
  },

  listenForChats(channel) {
    let userName = window.userName
    let userFirst = window.userFirst || ""
    let userLast = window.userLast || ""
    let userId = window.userId
    let chatWindow = document.getElementById('chat-window')
    let chatDescription = document.getElementsByClassName('chat-description')[0]
    let searchParams = new URLSearchParams(window.location.search)
    var scrolled = false;

    function setScrolledTrue() {
      scrolled=true
    }

    chatWindow.addEventListener("scroll", setScrolledTrue())

    function updateScroll(){
      if (!scrolled) {
        chatWindow.scrollTop = chatWindow.scrollHeight;
      }
    }

    // document.getElementById("search-form").addEventListener('keydown', function(e) {
    //   if (e.keyCode == 13) {
    //     e.preventDefault();
    //     let query = document.getElementById('search-form').value
    //     debugger
    //   }
    // });

    document.getElementById("chat-form").addEventListener('keydown', function(e) {
      if (e.keyCode == 13 && !e.shiftKey) {
        e.preventDefault();
        let userMsg = document.getElementById('user-msg').value
        let message_name = (userFirst !== "" && userLast !== "" ? `${userFirst} ${userLast}` : userName)

        if (chatDescription) {
          channel.push('shout', {name: message_name, body: userMsg, user_id: userId, chat_id: chatDescription.id})
        } else {
          channel.push('shout', {name: message_name, body: userMsg, user_id: userId})
        }

        document.getElementById('user-msg').value = ''
      }
    });

    channel.on('shout', payload => {
      let msgBlock = document.createElement('div')
      msgBlock.insertAdjacentHTML('beforeend', `<div class='message' id='message-${payload.message_id}'>
                                                  <span class='message-name'>${payload.name}:</span>
                                                  ${payload.body}
                                                </div>`
      )
      chatWindow.appendChild(msgBlock)
      chatWindow.scrollTop = chatWindow.scrollHeight;
      updateScroll();
    })
  }
}

export default WaterCooler
