document.addEventListener('DOMContentLoaded', () => {
  const flashMessages = document.querySelectorAll('.flash');
  flashMessages.forEach(message => {
    setTimeout(() => {
      message.style.display = 'none';
    }, 3000); // Hide after 3 seconds
  });
});