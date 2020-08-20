// Get the modal
var signInModal = document.getElementById("signin-modal");
var signUpModal = document.getElementById("signup-modal");
var editAccountModal = document.getElementById("edit-account-modal")
var editAccountLink = document.getElementById("edit-account-link")
var forgotPasswordModal = document.getElementById("forgot-password-modal")
var forgotPasswordLink = document.getElementById("forgot-password-link")
var signUpLinks = document.getElementsByClassName("signup-link");
var signInLinks = document.getElementsByClassName("signin-link");
var newChatLink = document.getElementById("new-chat-link");
var createChatLinks = document.getElementsByClassName("create-chat-link");
var newChatModal = document.getElementById("new-chat-modal")
var chatForm = document.getElementById("chat-form");
var chatWindow = document.getElementById("chat-window")
var closeSpans = document.getElementsByClassName("close");
var searchParams = new URLSearchParams(window.location.search)

if (searchParams.has("message_id")) {
  messageID = searchParams.get("message_id")
  messageElem = document.getElementById(`message-id-${messageID}`)
  messageElem.scrollIntoView();
} else {
  chatWindow.scrollTop = chatWindow.scrollHeight;
}

if (window.userToken == null) {
  chatForm.onclick = function() {
    signInModal.style.display = "block";
  }
}

if (newChatLink) {
  newChatLink.onclick = function() {
    newChatModal.style.display = "block"
  }
}

if (forgotPasswordLink) {
  forgotPasswordLink.onclick = function() {
    forgotPasswordModal.style.display = "block"
  }
}

if (editAccountLink) {
  editAccountLink.onclick = function() {
    editAccountModal.style.display = "block"
  }
}

for (var i = 0; i < createChatLinks.length; i++) {
  createChatLinks[i].onclick = function() {
    newChatModal.style.display = "block"
  }
}

for (var i = 0; i < signInLinks.length; i++) {
  signInLinks[i].onclick = function() {
    signUpModal.style.display = "none";
    signInModal.style.display = "block";
  }
}

for (var i = 0; i < signUpLinks.length; i++) {
  signUpLinks[i].onclick = function() {
    signInModal.style.display = "none";
    signUpModal.style.display = "block";
  }
}

// When the user clicks on <closeSpan> (x), close the modal
for (var i = 0; i < closeSpans.length; i++) {
  closeSpans[i].onclick = function() {
    signUpModal.style.display = "none";
    signInModal.style.display = "none";
    newChatModal.style.display = "none";
    editAccountModal.style.display = "none";
    forgotPasswordModal.style.display = "none";
  }
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == signUpModal) {
    signUpModal.style.display = "none";
  }

  if (event.target == signInModal) {
    signInModal.style.display = "none";
  }

  if (event.target == newChatModal) {
    newChatModal.style.display = "none";
  }

  if (event.target == editAccountModal) {
    editAccountModal.style.display = "none";
  }

  if (event.target == forgotPasswordModal) {
    forgotPasswordModal.style.display = "none";
  }
}
