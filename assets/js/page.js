// Get the modal
var signInModal = document.getElementById("signin-modal");
var signUpModal = document.getElementById("signup-modal");
var signUpLinks = document.getElementsByClassName("signup-link");
var signInLinks = document.getElementsByClassName("signin-link");
var newChatLink = document.getElementsByClassName("new-chat-link")[0];
var chatForm = document.getElementById("chat-form");
var chatWindow = document.getElementById("chat-window")
var closeSpans = document.getElementsByClassName("close");
var searchParams = new URLSearchParams(window.location.search)

if (searchParams.has("message_id")) {
  messageID = searchParams.get("message_id")
  messageElem = document.getElementById(`message-id-${messageID}`)
  messageElem.scrollIntoView();
}

if (window.userToken == null) {
  // newChatLink.onclick = function() {
  //   signInModal.style.display = "block"
  // }

  chatForm.onclick = function() {
    signInModal.style.display = "block";
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
}
