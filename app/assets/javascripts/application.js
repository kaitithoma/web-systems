// app/assets/javascripts/application.js

//= require rails-ujs
//= require turbolinks
//= require jquery
//= require_tree .

$(document).on('turbolinks:load', function() {
    const $searchInput = $('input[name="q"]');
    const $brandSelect = $('select#brand-select');

    if ($searchInput.length && $brandSelect.length) {
      const allBrands = $brandSelect.find('option').slice(1).clone(); // Clone all options except the first one

      $searchInput.on('input', function() {
        const query = $(this).val().toLowerCase();

        // Filter brands based on the input query
        const filteredBrands = allBrands.filter(function() {
          return $(this).text().toLowerCase().includes(query);
        });

        // Clear current options and add filtered options
        $brandSelect.find('option').slice(1).remove(); // Keep the first "Select a brand" option
        $brandSelect.append(filteredBrands);
      });
    }
  });