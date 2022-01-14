import { EmojiButton } from '@joeattardi/emoji-button';
import TimeAgo from 'javascript-time-ago';
import en from 'javascript-time-ago/locale/en';


// Create formatter (English).


let WaterCooler = {
  init(socket) {
    // This is extremely fragile that your entire socket/channel connection is based on a parsed variable in the path
    let channel_name = window.location.pathname.replace(/\/c\//g, '')
    let channel = socket.channel(`water_cooler:${channel_name}`, {})
    let picker = new EmojiButton();
    TimeAgo.addDefaultLocale(en);
    let timeAgoFormatter = new TimeAgo('en-US');
    channel.join()
    this.listenForChats(channel, picker, timeAgoFormatter)
    this.listenForReactions(channel, picker)
    this.listenForReplies(channel)
  },

  listenForReplies(channel) {
    var pathName = window.location.pathname;
    let replyButtons = document.getElementsByClassName("add-new-reply-button")
    let chatWindow = document.getElementById('chat-window')
    let replyWindow = document.getElementById("reply-window")
    let messageInput = document.getElementById("user-msg")
    for (var i = 0; i < replyButtons.length; i++) {
      replyButtons[i].onclick = function(e) {
        chatWindow.style.opacity = 0.05
        var messageId = e.target.dataset.messageId
        var replyMessageBlock = document.getElementById(`message-id-${messageId}`).cloneNode(true)
        replyMessageBlock.id = `message-id-clone-${messageId}`

        var replies = document.getElementsByClassName(`reply-message-${messageId}`)
        replyWindow.style.visibility = "visible"
        replyWindow.appendChild(replyMessageBlock)
        replyWindow.dataset.messageId = messageId
        messageInput.focus()

        for (var i = 0; i < replies.length; i++) {
          var replyData = replies[i].dataset
          let msgBlock = document.createElement('div')
          msgBlock.insertAdjacentHTML('beforeend', `<div class='message' id='message-id-${replyData.replyId}'>
                                                      <span class='message-name'>${replyData.replyName}</span>
                                                      <br>
                                                      ${replyData.replyBody}
                                                    </div>
                                                    `
          )
          replyWindow.appendChild(msgBlock)

        }

        document.addEventListener("click", (e) => {
          if (!e.target.classList.contains('add-new-reply-button') && !e.target.classList.contains('message-input')) {
            replyWindow.style.visibility = "hidden"
            chatWindow.style.opacity = 1
            replyWindow.textContent = ''
            replyWindow.dataset.messageId = null;
            messageInput.blur()
          }
        })
        // showReplies that are loaded with messages
        // Do we want an api endpoint for this, NO, just load them like reactions...
        // Get replies working without replies or reactions for replies
        ga('send', 'event', 'Reply Button', 'view replies or reply', 'replies opened', pathName);
      }
    }
    //This will handle on channel communication of message replies
  },

  listenForReactions(channel, picker) {
    let userId = window.userId

    let newReactionButtons = document.getElementsByClassName('add-new-reaction-button');
    let incrementReactionButtons = document.getElementsByClassName('increment-reaction-button')
    let decrementReactionButtons = document.getElementsByClassName('decrement-reaction-button')

    function addReactionEventListener(e) {
      let elData = e.toElement.dataset
      channel.push('reaction', {value: elData.reaction, user_id: userId, message_id: elData.messageId})
    }

    function removeReactionEventListener(e) {
      let elData = e.toElement.dataset
      channel.push('remove_reaction', {value: elData.reaction, user_id: userId, message_id: elData.messageId})
    }

    channel.on('increment_reaction', payload => {
      let messageReactionEl = document.getElementById(`message-id-${payload.message_id}-${payload.value}`)
      if (messageReactionEl) {
        let newCount = parseInt(messageReactionEl.dataset.count) + 1
        messageReactionEl.dataset.count = newCount
        messageReactionEl.innerText = `${newCount}${payload.value}`
        messageReactionEl.classList.remove("increment-reaction-button")
        messageReactionEl.classList.add("decrement-reaction-button")
        messageReactionEl.addEventListener('click', (e) => removeReactionEventListener(e))
      } else {
        let reactionBlock = document.getElementById(`reaction-message-id-${payload.message_id}`)

        if (reactionBlock) {
          reactionBlock.insertAdjacentHTML('afterend', `<span class='reaction-button decrement-reaction-button' id='message-id-${payload.message_id}-${payload.value}' data-count=1 data-reaction=${payload.value} data-message-id=${payload.message_id}>1${payload.value}</span>`)
        }

        document.getElementById(`message-id-${payload.message_id}-${payload.value}`).addEventListener('click', e => removeReactionEventListener(e))
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
        messageReactionEl.addEventListener('click', e => addReactionEventListener(e))
      } else {
        messageReactionEl.remove()
      }
    })

    picker.on('emoji', selection => {
      let messageId = picker["message_id"].replace(/\D*/, '')
      channel.push('reaction', {value: selection.emoji, user_id: userId, message_id: messageId})
    });

    for (var i = 1; i < incrementReactionButtons.length; i++) {
      incrementReactionButtons[i].addEventListener('click', (e) => addReactionEventListener(e))
    }

    for (var i = 1; i < decrementReactionButtons.length; i++) {
      decrementReactionButtons[i].addEventListener('click', (e) => removeReactionEventListener(e))
    }


    for (var i = 0; i < newReactionButtons.length; i++) {
      newReactionButtons[i].addEventListener('click', (e) => {
        picker["message_id"] = e.currentTarget.id
        picker.togglePicker(e.currentTarget)
      });
    }
  },

  listenForChats(channel, picker, timeAgo) {
    let userName = window.userName
    let userFirst = window.userFirst || ""
    let userLast = window.userLast || ""
    let userId = window.userId
    let chatWindow = document.getElementById('chat-window')
    let chatDescription = document.getElementsByClassName('chat-description')[0]
    var pageTrigger = document.getElementById("pagination-trigger")
    var initialShareLinks = document.getElementsByClassName('message-inserted-at')
    var scrolled = false;
    var messageScrollerExecuted = false;
    var host = null

    if (location.hostname == "localhost") {
      host = `http://localhost:4000`
    } else {
      host = `https://cooler.chat`
    }

    function setScrolledTrue() {
      // The purpose of this method is to prevent users
      //from getting scrolled when they get linked to a
      // specific message
      scrolled=true
    }

    function updateScroll(){
      if (!scrolled) {
        chatWindow.scrollTop = chatWindow.scrollHeight;
      }
    }

    var us = updateScroll()
    us

 
    for (var i = 0; i < initialShareLinks.length; i++) {
      attachNativeShare(initialShareLinks[i])
    }

    function isScrolledIntoView(el) {
        var rect = el.getBoundingClientRect();
        var elemBottom = rect.bottom;
        var isVisible = (elemBottom >= 0)
        return isVisible;
    }

    function addReactionEventListener(e) {
      let elData = e.toElement.dataset
      channel.push('reaction', {value: elData.reaction, user_id: userId, message_id: elData.messageId})
    }

    function removeReactionEventListener(e) {
      let elData = e.toElement.dataset
      channel.push('remove_reaction', {value: elData.reaction, user_id: userId, message_id: elData.messageId})
    }

    function firePagination(picker, messageScroller = null) {
      var paginationTrigger = document.getElementById("pagination-trigger")
      var originalScrollHeight = chatWindow.scrollHeight;
      var originalScrollTop = chatWindow.scrollTop;

      if (paginationTrigger && isScrolledIntoView(paginationTrigger)) {
        var cursorAfter = paginationTrigger.dataset.cursorAfter
        var chatId = paginationTrigger.dataset.chatId
        paginationTrigger.remove();
        paginationTrigger = null
        let firstChild = chatWindow.firstChild
        // let firstChildScrollHeight = firstChild.scrollHeigh
        var newPageTrigger = document.createElement("span")
        var xhr = new XMLHttpRequest();

        xhr.onload = function () {
          if (xhr.status >= 200 && xhr.status < 300) {
            console.log('success!', xhr);
            var response = JSON.parse(xhr.response)
            var chat = response["chat"]
            var messages = response["messages"]
            var replies = response["replies"]
            var metadata = response["metadata"]
            var reactions = response["reactions"]

            for (var i = 0; i < messages.length; i++) {
              if (i == 0) {
                newPageTrigger.id = 'pagination-trigger'
                newPageTrigger.dataset.cursorAfter = metadata.after
                newPageTrigger.dataset.chatId = chat.id
                chatWindow.insertBefore(newPageTrigger, firstChild)
              }

              var replyCount = 0
              var replyButtonInnerText = `+Reply`
              var replyDataSpans = `<span id='message-replies-container-${messages[i].id}'>`
              for (var k = 0; k < replies.length; k++) {
                // feels really dumb to iterate through replies twice hear
                if (replies[k].reply_id == messages[i].id) {
                  replyDataSpans += `<span class='message-reply reply-message-${messages[i].id} data-reply-messge-id=${messages[i].id}' data-reply-name='${replies[k].name}' data-reply-id='${replies[k].id}' data-reply-body='${replies[k].body}'></span>`
                  replyCount += 1
                }
                if (replyCount > 0) {
                  replyButtonInnerText = `${replyCount} Replies`
                }
              }
              replyDataSpans += `</span>`

              let msgBlock = document.createElement('div')
              msgBlock.insertAdjacentHTML('beforeend', `<div class='message' id='message-id-${messages[i].id}'>
                                                          <span class='message-name'>${messages[i].name}</span>
                                                          <span class='message-inserted-at' id='message-share-id-${messages[i].id}' data-message-id='${messages[i].id}' data-chat-id='${messages[i].chat_id}' data-message-name='${messages[i].name}' data-message-body='${messages[i].undecorated_body}' >
                                                            ${timeAgo.format(Date.parse(messages[i].inserted_at))}
                                                            <i class="far fa-share-square"></i>
                                                          </span>
                                                          
                                                          <br>
                                                          ${messages[i].body}
                                                        </div>
                                                        <span class='add-new-reply-button' id='reply-message-id-${messages[i].id}' data-message-id='${messages[i].id}'>${replyButtonInnerText}</span>
                                                        <span class='add-new-reaction-button reaction-button' id='reaction-message-id-${messages[i].id}'>+🙂</span>
                                                        ${replyDataSpans}
                                                        `
              )
              chatWindow.insertBefore(msgBlock, firstChild)
              let shareElem = document.getElementById(`message-share-id-${messages[i].id}`)
              attachNativeShare(shareElem)

              let messageInput = document.getElementById("user-msg")
              let replyBlock = document.getElementById(`reply-message-id-${messages[i].id}`)
              replyBlock.addEventListener('click', (e) => {
                let replyWindow = document.getElementById("reply-window")
                chatWindow.style.opacity = 0.05
                var messageId = e.target.dataset.messageId
                var replyMessageBlock = document.getElementById(`message-id-${messageId}`).cloneNode(true)
                replyMessageBlock.id = `message-id-clone-${messageId}`
                var replies = document.getElementsByClassName(`reply-message-${messageId}`)
                replyWindow.style.visibility = "visible"
                replyWindow.appendChild(replyMessageBlock)
                replyWindow.dataset.messageId = messageId
                messageInput.focus()

                for (var i = 0; i < replies.length; i++) {
                  var replyData = replies[i].dataset
                  let msgBlock = document.createElement('div')
                  msgBlock.insertAdjacentHTML('beforeend', `<div class='message' id='message-id-${replyData.replyId}'>
                                                              <span class='message-name'>${replyData.replyName}</span>
                                                              <br>
                                                              ${replyData.replyBody}
                                                            </div>
                                                            `
                  )
                  replyWindow.appendChild(msgBlock)

                }

                document.addEventListener("click", (e) => {
                  if (!e.target.classList.contains('add-new-reply-button') && !e.target.classList.contains('message-input')) {
                    replyWindow.style.visibility = "hidden"
                    chatWindow.style.opacity = 1
                    replyWindow.textContent = ''
                    replyWindow.dataset.messageId = null;
                    messageInput.blur()
                  }
                })
                // showReplies that are loaded with messages
                // Do we want an api endpoint for this, NO, just load them like reactions...
                // Get replies working without replies or reactions for replies
                var pathName = window.location.pathname;
                ga('send', 'event', 'Reply Button', 'view replies or reply', 'replies opened', pathName);
              });

              let reactionBlock = document.getElementById(`reaction-message-id-${messages[i].id}`)
              reactionBlock.addEventListener('click', (e) => {
                picker["message_id"] = e.currentTarget.id
                picker.togglePicker(e.currentTarget)
              });

              for (var j = 0; j < reactions.length; j ++ ) {
                if (reactions[j].message_id == messages[i].id) {
                  if (reactions[j].user_ids.includes(userId)) {
                    reactionBlock.insertAdjacentHTML('afterend', `<span class='reaction-button decrement-reaction-button' id='message-id-${reactions[j].message_id}-${reactions[j].value}' data-count=1 data-reaction=${reactions[j].value} data-message-id=${reactions[j].message_id}>${reactions[j].count}${reactions[j].value}</span>`)
                    document.getElementById(`message-id-${reactions[j].message_id}-${reactions[j].value}`).addEventListener('click', (e) => removeReactionEventListener(e))
                  } else {
                    reactionBlock.insertAdjacentHTML('afterend', `<span class='reaction-button increment-reaction-button' id='message-id-${reactions[j].message_id}-${reactions[j].value}' data-count=1 data-reaction=${reactions[j].value} data-message-id=${reactions[j].message_id}>${reactions[j].count}${reactions[j].value}</span>`)
                    document.getElementById(`message-id-${reactions[j].message_id}-${reactions[j].value}`).addEventListener('click', (e) => addReactionEventListener(e))
                  }
                }
              }
            }
            // Manually set scroll height to reset for the new elements (Chrome auto adjusts scrollTop to maintain new position,
            // while safari keeps the same value despite a new scroll height which causes isScrolledIntoView to remain true
            // There is definitely still a bug in fireBeforePagintion or isScrolledIntoView for BeforePagination not being reversed
            // To look at elements coming up the view rather then down it.
            //MOBILE PAGINATION IS much better but not fixed, now going to the top of the new page (atleast not firing multiple times)
            var newScrollHeight = chatWindow.scrollHeight;
            chatWindow.scrollTop = originalScrollTop + (newScrollHeight - originalScrollHeight)

          } else {
            console.log('The request failed!');
          }

          if (messageScroller) {
            var ms = messageScroller
            ms()
          }

        };

        if (cursorAfter) {
          xhr.open('GET', `${host}/api/messages?chat_id=${chatId}&&cursor_after=${cursorAfter}`);
          xhr.send();
        }
      }
    }

    function fireBeforePagination(picker, messageScroller = null) {
      var beforePaginationTrigger = document.getElementById("before-pagination-trigger")
      if (beforePaginationTrigger && isScrolledIntoView(beforePaginationTrigger)) {
        var cursorBefore = beforePaginationTrigger.dataset.cursorBefore
        var chatId = beforePaginationTrigger.dataset.chatId
        beforePaginationTrigger.remove();
        beforePaginationTrigger = null
        let lastChild = chatWindow.lastChild
        var newPageTrigger = document.createElement("span")
        var xhr = new XMLHttpRequest();

        xhr.onload = function () {
          if (xhr.status >= 200 && xhr.status < 300) {
            console.log('success!', xhr);
            var response = JSON.parse(xhr.response)
            var chat = response["chat"]
            var messages = response["messages"]
            var metadata = response["metadata"]
            var reactions = response["reactions"]

            for (var i = 0; i < messages.length; i++) {
              let msgBlock = document.createElement('div')
              msgBlock.insertAdjacentHTML('beforeend', `<div class='message' id='message-id-${messages[i].id}'>
                                                          <span class='message-name'>${messages[i].name}</span>
                                                          <span class='message-inserted-at' id='message-share-id-${messages[i].id}' data-message-id='${messages[i].id}' data-chat-id='${messages[i].chat_id}' data-message-name='${messages[i].name} data-message-body='${messages[i].undecorated_body}'>
                                                            ${timeAgo.format(Date.parse(messages[i].inserted_at))}
                                                            <i class="far fa-share-square"></i>
                                                          </span>
                                                          <br>
                                                          ${messages[i].body}
                                                        </div>
                                                        <span class='add-new-reaction-button reaction-button' id='reaction-message-id-${messages[i].id}'>+🙂</span>
                                                        `
              )
              lastChild.parentNode.insertBefore(msgBlock, lastChild.nextSibling)
              lastChild = chatWindow.lastChild //Could we avoid this by not reversing the messages we get back? // Also may have to not revers anyway for this scenario
              let shareElem = document.getElementById(`message-share-id-${messages[i].id}`)
              attachNativeShare(shareElem)

              let reactionBlock = document.getElementById(`reaction-message-id-${messages[i].id}`)
              reactionBlock.addEventListener('click', (e) => {
                picker["message_id"] = e.currentTarget.id
                picker.togglePicker(e.currentTarget)
              });

              for (var j = 0; j < reactions.length; j ++ ) {
                if (reactions[j].message_id == messages[i].id) {
                  if (reactions[j].user_ids.includes(userId)) {
                    reactionBlock.insertAdjacentHTML('afterend', `<span class='reaction-button decrement-reaction-button' id='message-id-${reactions[j].message_id}-${reactions[j].value}' data-count=1 data-reaction=${reactions[j].value} data-message-id=${reactions[j].message_id}>${reactions[j].count}${reactions[j].value}</span>`)
                    document.getElementById(`message-id-${reactions[j].message_id}-${reactions[j].value}`).addEventListener('click', (e) => removeReactionEventListener(e))
                  } else {
                    reactionBlock.insertAdjacentHTML('afterend', `<span class='reaction-button increment-reaction-button' id='message-id-${reactions[j].message_id}-${reactions[j].value}' data-count=1 data-reaction=${reactions[j].value} data-message-id=${reactions[j].message_id}>${reactions[j].count}${reactions[j].value}</span>`)
                    document.getElementById(`message-id-${reactions[j].message_id}-${reactions[j].value}`).addEventListener('click', (e) => addReactionEventListener(e))
                  }
                }
              }

              if (i == messages.length - 1) {
                newPageTrigger.id = 'before-pagination-trigger'
                newPageTrigger.dataset.cursorBefore = metadata.before
                newPageTrigger.dataset.chatId = chat.id
                // Insert the new page trigger after the last child
                lastChild.parentNode.insertBefore(newPageTrigger, lastChild.nextSibling)
              }
            }
          } else {
            console.log('The request failed!');
          }
          console.log('This always runs...');

          if (messageScroller) {
            var ms = messageScroller
            ms()
          }

        };

        if (cursorBefore) {
          xhr.open('GET', `${host}/api/messages?chat_id=${chatId}&&cursor_before=${cursorBefore}`);
          xhr.send();
        }
      }
    }

    chatWindow.addEventListener("scroll", function(){
        setScrolledTrue()

        firePagination(picker, scrollMessageIntoViewWhenQueried)
        fireBeforePagination(picker, scrollMessageIntoViewWhenQueried)
      }
    )

    function scrollMessageIntoViewWhenQueried() {
      var searchParams = new URLSearchParams(window.location.search)

      if (!messageScrollerExecuted && searchParams.has("message_id")) {
        messageScrollerExecuted = true
        var messageId = searchParams.get("message_id")
        var messageElem = document.getElementById(`message-id-${messageId}`)

        if (messageElem) {
          setScrolledTrue();
          messageElem.scrollIntoView();
        }
      }
    }

    function attachNativeShare(shareButton) {
      shareButton.addEventListener('click', event => {
        if (navigator.share) {
          navigator.share({
            title: 'Cooler.Chat',
            url: `${host}/chat/${shareButton.dataset.chatId}?message_id=${shareButton.dataset.messageId}`,
            text: `${shareButton.dataset.messageName}: ${shareButton.dataset.messageBody}`
          }).then(() => {
            console.log('Thanks for sharing!');
          })
          .catch(console.error);
        } else {
          navigator.clipboard.writeText(`${host}/chat/${shareButton.dataset.chatId}?message_id=${shareButton.dataset.messageId}`)
        }
      });
    }

    /// You may need to add something like this for before page trigger for when
    // someone has a larger window and the bfp() doesn't fire cuz its above trigger point
    if (pageTrigger != null && pageTrigger.scrollHeight == 0) {
      firePagination(picker, scrollMessageIntoViewWhenQueried)
    }

    document.getElementById("chat-form").addEventListener('keydown', function(e) {
      let replyWindow = document.getElementById("reply-window")
      if (e.keyCode == 13 && !e.shiftKey) {
        e.preventDefault();
        let userMsg = document.getElementById('user-msg').value
        // let message_name = (userFirst !== "" && userLast !== "" ? `${userFirst} ${userLast}` : userName)

        if (replyWindow.dataset.messageId) {
          channel.push('shout', {name: userName, body: userMsg, user_id: userId, chat_id: chatDescription.id, reply_id: replyWindow.dataset.messageId})
        } else {
          channel.push('shout', {name: userName, body: userMsg, user_id: userId, chat_id: chatDescription.id})
        }

        document.getElementById('user-msg').value = ''
      }
    });

    channel.on('shout', payload => {
      let replyWindow = document.getElementById("reply-window")
      let msgBlock = document.createElement('div')
      // Need to fix this message inserted at
      //<a href="${host}/chat/${payload.chat_id}?message_id=${payload.message_id}"
      let msgHTML = `<div class='message' id='message-id-${payload.message_id}'>
                                                  <span class='message-name'>${payload.name}</span>
                                                  <span class='message-inserted-at' id='message-share-id-${payload.message_id}' data-message-id='${payload.message_id}' data-chat-id='${payload.chat_id}' data-message-name='${payload.name}' data-message-body='${payload.body}'>
                                                    ${(payload.inserted_at)}
                                                    <i class="far fa-share-square"></i>
                                                  </span>
                                                  <br>
                                                  ${payload.body}
                                                </div>
                                                `

      if (replyWindow.style.visibility == "visible" && replyWindow.dataset.messageId == payload.reply_id) {
        let replyBlock = document.createElement('div')
        replyBlock.insertAdjacentHTML('beforeend', msgHTML)
        replyWindow.appendChild(replyBlock)
        // Create span that adds message to list of hidden spans with data
      }

      var originalMessageReplyContainer = document.getElementById(`message-replies-container-${payload.message_id}`)
      if (originalMessageReplyContainer != null) {
        let replyDataSpan = document.createElement('span')
        replyDataSpan.classList.add('message-reply')
        replyDataSpan.classList.add(`reply-message-${payload.reply_id}`)
        replyDataSpan.dataset.replyMessageId = payload.reply_id
        replyDataSpan.dataset.replyName = payload.name
        replyDataSpan.dataset.replyId = payload.message_id
        replyDataSpan.dataset.replyBody = payload.body
        originalMessageReplyContainer.insertAdjacentElement('beforeend', replyDataSpan)
      }

      msgBlock.insertAdjacentHTML('beforeend', msgHTML + `<span class='add-new-reply-button' id='reply-message-id-${payload.message_id}' data-message-id='${payload.message_id}'>+Reply</span>` + `<span class='add-new-reaction-button reaction-button' id='reaction-message-id-${payload.message_id}'>+🙂</span>`)
      // Need to add event trigger to new reply button

      chatWindow.appendChild(msgBlock)
      let shareElem = document.getElementById(`message-share-id-${payload.message_id}`)
      attachNativeShare(shareElem)
      chatWindow.scrollTop = chatWindow.scrollHeight;

      let reactionBlock = document.getElementById(`reaction-message-id-${payload.message_id}`)
      reactionBlock.addEventListener('click', (e) => {
        picker["message_id"] = e.currentTarget.id
        picker.togglePicker(e.currentTarget)
      });
      updateScroll();
    })
  }
}

export default WaterCooler
