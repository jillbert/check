// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.foundation
//= require foundation
//= require turbolinks
//= require_tree .

$(function(){ 
	$(document).foundation({
		abide: { 
			patterns: { 
				user_phone: /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/,
				user_email: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
			} 
		} 
	}) 
});

var guests = [];
$(document).ready(function() {
	if ($('#processcheckin fieldset')) {
		var focused;

		$('#processcheckin fieldset').each(function() {
			var firstn = $(this).find('.first');
			var lastn = $(this).find('.last');
			var email = $(this).find('.email');
			var phone = $(this).find('.phone');
			guests.push({"firstn": firstn, "lastn": lastn, "email": email, "phone": phone})
		})
		
		$('#processcheckin fieldset').on('change', function() {
			var validated = true;

			if($('div.error').length > 0) {
				validated = false;
			}
			
			for(i=0;i<guests.length;i++) {
				if(guests[i].firstn.val() != "" || guests[i].lastn.val() != "" || guests[i].email.val() != "" || guests[i].phone.val()) {
					if(guests[i].firstn.val() != "" && guests[i].lastn.val() != "" && guests[i].email.val() != "" && validated) {
					} else {
						validated = false;
						console.log('all fields not validated')
					}
				}
			}
			if(!validated) {
				$('input[type="submit"]').attr('disabled','disabled');
			} else {
				$('input[type="submit"]').removeAttr('disabled');
			}
		})
	}

	// $('a:not(.toggle-topbar.menu-icon a, .top-bar-section a), input[type="submit"]').on('click', function() { $('#thinking').show();$('body').css({'overflow': 'hidden'})})

	if($('#list')) {
		$('#list tfoot th').each( function () {
		    var title = $('#list thead th').eq( $(this).index() ).text();
		    $(this).html( '<input type="text" placeholder="Search '+title+'" />' );
		} );

		// DataTable
		var table = $('#list').DataTable({
			"oLanguage": {
			        "sZeroRecords": "None found. <a href='/new_rsvp'>Add a new RSVP?</a>"
			    }
		});

		// Apply the search
		table.columns().eq( 0 ).each( function ( colIdx ) {
		    $( 'input', table.column( colIdx ).footer() ).on( 'keyup change', function () {
		        table
		            .column( colIdx )
		            .search( this.value )
		            .draw();
		    } );
		} );
	}
})