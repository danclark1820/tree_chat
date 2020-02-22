let WaterCooler = {
  init(socket) {
    let channel = socket.channel('water_cooler:lobby', {})
    channel.join()
    this.listenForChats(channel)
  },

  listenForChats(channel) {
    let userName = window.userName
    let chatWindow = document.getElementById('chat-window')
    document.getElementById('chat-form').addEventListener('submit', function(e){
      e.preventDefault()
      let userMsg = document.getElementById('user-msg').value

      channel.push('shout', {name: userName, body: userMsg})

      // document.getElementById('user-name').value = ''
      document.getElementById('user-msg').value = ''
      // Re get chat window element to find out its new scroll height
      chatWindow.scrollTop = document.getElementById('chat-window').scrollHeight
    })

    channel.on('shout', payload => {
      let msgBlock = document.createElement('p')

      msgBlock.insertAdjacentHTML('beforeend', `${payload.name}: ${payload.body}`)
      chatWindow.appendChild(msgBlock)
    })
  }
}

export default WaterCooler
