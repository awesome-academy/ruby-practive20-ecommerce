// Menu manipulation
// Add toggle listeners to listen for clicks.
document.addEventListener('turbo:load', function() {
  const account = document.querySelector('#account');
  if (account) {
	account.addEventListener('click', function(event) {
	  event.preventDefault();
	  const menu = document.querySelector('#dropdown-menu');
	  if (menu) {
		menu.classList.toggle('active');
	  }
	});
  }
});
