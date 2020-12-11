import { EmojiButton } from '@joeattardi/emoji-button';

let WaterCooler = {
  init(socket) {
    let channel_name = window.location.pathname.replace(/\/c\//g, '')
    let channel = socket.channel(`water_cooler:${channel_name}`, {})
    channel.join()
    this.listenForChats(channel)
    this.listenForReactions(channel)
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
                                                  <span class='message-name'>${payload.name}</span>
                                                  <br>
                                                  ${payload.body}
                                                </div>
                                                <span class='add-reaction-button' id='reaction-message-id-${payload.message_id}'>+🙂</span>
                                                `
      )
      chatWindow.appendChild(msgBlock)
      chatWindow.scrollTop = chatWindow.scrollHeight;
      updateScroll();
    })
  },

  listenForReactions(channel) {
    let userId = window.userId
    const picker = new EmojiButton();
    const reactionButtons = document.getElementsByClassName('add-reaction-button');

    picker.on('emoji', selection => {
      // reaction_button.innerHTML = selection.emoji;
      // Do exacctly what is on line 47 to broadcast the reaction
      let messageId = picker["message_id"].replace(/\D*/, '')
      channel.push('reaction', {value: selection.emoji, user_id: userId, message_id: messageId})
      // Add a version of whats on line 57 for reaction instead of shout
    });

    for (var i = 0; i < reactionButtons.length; i++) {
      reactionButtons[i].addEventListener('click', (e) => {
        picker["message_id"] = e.currentTarget.id
        picker.togglePicker(e.currentTarget)
        //Need to set data on picker saying which message id it is
      });
    }
  }
}

export default WaterCooler
