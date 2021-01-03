// Get the modal
var signInModal = document.getElementById("signin-modal");
var signUpModal = document.getElementById("signup-modal");
var editAccountModal = document.getElementById("edit-account-modal")
var editAccountLink = document.getElementById("edit-account-link")
var forgotPasswordModal = document.getElementById("forgot-password-modal")
var forgotPasswordLink = document.getElementById("forgot-password-link")
var editPasswordModal = document.getElementById("edit-password-modal")
var editPasswordLink = document.getElementById("edit-password-link")
var signUpLinks = document.getElementsByClassName("signup-link");
var signInLinks = document.getElementsByClassName("signin-link");
var newChatLink = document.getElementById("new-chat-link");
var createChatLinks = document.getElementsByClassName("create-chat-link");
var newChatModal = document.getElementById("new-chat-modal")
var reactionButtons = document.getElementsByClassName("reaction-button")
var chatForm = document.getElementById("chat-form");
var chatWindow = document.getElementById("chat-window")
var closeSpans = document.getElementsByClassName("close");
var searchParams = new URLSearchParams(window.location.search)
var pathName = window.location.pathname;


if (searchParams.has("message_id")) {
  messageId = searchParams.get("message_id")
  messageElem = document.getElementById(`message-id-${messageId}`)
  messageElem.scrollIntoView();
} else {
  chatWindow.scrollTop = chatWindow.scrollHeight;
}

if (window.userToken == null) {
  chatForm.onclick = function() {
    signUpModal.style.display = "block";
    mixpanel.track("Unlogged in chat attempt", {"path": pathName})
    ga('send', 'event', 'SignUps', 'click chat form: unlogged in', 'signup loaded', pathName);
  }

  for (var i = 0; i < reactionButtons.length; i++) {
    reactionButtons[i].onclick = function() {
      signUpModal.style.display = "block";
      mixpanel.track("Unlogged in reaction attempt", {"path": pathName})
      ga('send', 'event', 'SignUps', 'click reaction button: unlogged in', 'signup loaded', pathName);
    }
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

if (editPasswordLink) {
  editPasswordLink.onclick = function() {
    editAccountModal.style.display = "none"
    editPasswordModal.style.display = "block"
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
    ga('send', 'event', 'SignUps', 'sign up link clicked', 'signup loaded', pathName);
    signInModal.style.display = "none";
    signUpModal.style.display = "block";
  }
}

// When the user clicks on <closeSpan> (x), close the modal
for (var i = 0; i < closeSpans.length; i++) {
  closeSpans[i].onclick = function() {
    mixpanel.track("closed out of modal", {"path": pathName})
    ga('send', 'event', 'Form Closed', 'close button clicked', 'form closed', pathName);
    signUpModal.style.display = "none";
    signInModal.style.display = "none";
    newChatModal.style.display = "none";
    editAccountModal.style.display = "none";
    editPasswordModal.style.display = "none";
    forgotPasswordModal.style.display = "none";
  }
}

// When the user clicks anywhere outside of the modal, close it
window.onclick = function(event) {
  if (event.target == signUpModal) {
    mixpanel.track("clicked out of sign up", {"path": pathName})
    ga('send', 'event', 'Form Closed', 'clicked out of sign up', 'form closed', pathName);
    signUpModal.style.display = "none";
  }

  if (event.target == signInModal) {
    ga('send', 'event', 'Form Closed', 'clicked out of sign in', 'form closed', pathName);
    signInModal.style.display = "none";
  }

  if (event.target == newChatModal) {
    ga('send', 'event', 'Form Closed', 'clicked out of new chat', 'form closed', pathName);
    newChatModal.style.display = "none";
  }

  if (event.target == editAccountModal) {
    ga('send', 'event', 'Form Closed', 'clicked out of edit account', 'form closed', pathName);
    editAccountModal.style.display = "none";
  }

  if (event.target == forgotPasswordModal) {
    ga('send', 'event', 'Form Closed', 'clicked out of forgot password', 'form closed', pathName);
    forgotPasswordModal.style.display = "none";
  }

  if (event.target == editPasswordModal) {
    ga('send', 'event', 'Form Closed', 'clicked out of edit password', 'form closed', pathName);
    editPasswordModal.style.display = "none";
  }
}
