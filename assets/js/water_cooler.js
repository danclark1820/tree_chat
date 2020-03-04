let WaterCooler = {
  init(socket) {
    let channel = socket.channel('water_cooler:lobby', {})
    channel.join()
    this.listenForChats(channel)
  },

  listenForChats(channel) {
    let userName = window.userName
    let userId = window.userId
    let chatWindow = document.getElementById('chat-window')
    var scrolled = false;

    chatWindow.addEventListener("scroll", function(){ scrolled=true })
    chatWindow.scrollTop = chatWindow.scrollHeight;

    function updateScroll(){
      if (!scrolled) {
        chatWindow.scrollTop = chatWindow.scrollHeight;
      }
    }

    document.getElementById('chat-form').addEventListener('submit', function(e){
      e.preventDefault()
      let userMsg = document.getElementById('user-msg').value
      channel.push('shout', {name: userName, body: userMsg, user_id: userId})
      document.getElementById('user-msg').value = ''
    })

    channel.on('shout', payload => {
      let msgBlock = document.createElement('div')

      msgBlock.insertAdjacentHTML('beforeend', `<b>${payload.name}:</b> ${payload.body}`)
      chatWindow.appendChild(msgBlock)
      updateScroll();
      chatWindow.scrollTop = chatWindow.scrollHeight;
    })
  }
}

export default WaterCooler
