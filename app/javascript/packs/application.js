// app/javascript/packs/application.js

//= require rails-ujs
//= require turbolinks
//= require_tree .

document.addEventListener('DOMContentLoaded', function() {
  const searchInput = document.querySelector('input[name="q"]');
  const brandSelect = document.querySelector('select[name="brand_id"]');

  if (searchInput && brandSelect) {
    searchInput.addEventListener('input', function() {
      const query = searchInput.value.toLowerCase();

      // Get all brands and filter based on the query
      const allBrands = Array.from(brandSelect.options).slice(1); // Exclude the first "Select a brand" option
      const filteredBrands = allBrands.filter(option => option.text.toLowerCase().includes(query));

      // Clear current options and add filtered options
      while (brandSelect.options.length > 1) { // Keep the first "Select a brand" option
        brandSelect.remove(1);
      }

     filteredBrands.forEach(option => brandSelect.add(option));
    });
  }
});
