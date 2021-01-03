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
                                                <span class='add-new-reaction-button reaction-button' id='reaction-message-id-${payload.message_id}'>+🙂</span>
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
    const newReactionButtons = document.getElementsByClassName('add-new-reaction-button');
    const incrementReactionButtons = document.getElementsByClassName('increment-reaction-button')
    const decrementReactionButtons = document.getElementsByClassName('decrement-reaction-button')

    channel.on('increment_reaction', payload => {
      let messageReactionEl = document.getElementById(`message-id-${payload.message_id}-${payload.value}`)
      if (messageReactionEl) {
        let newCount = parseInt(messageReactionEl.dataset.count) + 1
        messageReactionEl.dataset.count = newCount
        messageReactionEl.innerText = `${newCount}${payload.value}`
        messageReactionEl.classList.remove("increment-reaction-button")
        messageReactionEl.classList.add("decrement-reaction-button")
        listenForReactions(channel)
      } else {
        let reactionBlock = document.getElementById(`reaction-message-id-${payload.message_id}`)

        if (reactionBlock) {
          reactionBlock.insertAdjacentHTML('afterend', `<span class='reaction-button decrement-reaction-button' id='message-id-${payload.message_id}-${payload.value}' data-count=1 data-reaction=${payload.value} data-message-id=${payload.message_id}>1${payload.value}</span>`)
        }
        listenForReactions(channel)
      }
    })

    channel.on('decrement_reaction', payload => {
      let messageReactionEl = document.getElementById(`message-id-${payload.message_id}-${payload.value}`)
      if (messageReactionEl && parseInt(messageReactionEl.dataset.count) > 1) {
        let newCount = parseInt(messageReactionEl.dataset.count) - 1
        messageReactionEl.dataset.count = newCount
        messageReactionEl.innerText = `${newCount}${payload.value}`
        messageReactionEl.classList.add("increment-reaction-button")
        messageReactionEl.classList.remove("decrement-reaction-button")
        listenForReactions(channel)
      } else {
        messageReactionEl.remove()
      }
    })

    picker.on('emoji', selection => {
      let messageId = picker["message_id"].replace(/\D*/, '')
      channel.push('reaction', {value: selection.emoji, user_id: userId, message_id: messageId})
    });

    for (var i = 1; i < incrementReactionButtons.length; i++) {
      incrementReactionButtons[i].addEventListener('click', (e) => {
        let elData = e.toElement.dataset
        channel.push('reaction', {value: elData.reaction, user_id: userId, message_id: elData.messageId})
      });
    }

    for (var i = 1; i < decrementReactionButtons.length; i++) {
      decrementReactionButtons[i].addEventListener('click', (e) => {
        let elData = e.toElement.dataset
        channel.push('remove_reaction', {value: elData.reaction, user_id: userId, message_id: elData.messageId})
      });
    }


    for (var i = 0; i < newReactionButtons.length; i++) {
      newReactionButtons[i].addEventListener('click', (e) => {
        picker["message_id"] = e.currentTarget.id
        picker.togglePicker(e.currentTarget)
      });
    }
  }
}

export default WaterCooler
