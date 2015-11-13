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
//= require_tree .

var table; 

$(function(){ 
	$(document).foundation({
		abide: { 
			patterns: { 	
				user_phone: /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/,
				user_email: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
			},
		} 
	}) 
});

$(document).ready(function() {

	$('.add').on('click', function(e) {
		e.preventDefault();
		var url = '/people/new';
		$.ajax({
			type: "GET",
			url: url,
			dataType: 'script',
			data: {
				'host_id': $(this).data('host-id')
			},
			success: function(result) {
				eval(result);
				$(this).hide();
			}
		})
	})

	$('.checkin').on('click', function(e) {
		e.preventDefault();
		e.stopPropagation();
		console.log($(this).data('id'))
		var url = '/rsvps/check_in';
		$.ajax({
			type: "POST",
		  url: url,
		  dataType: 'script',
		  data: {
		  	'id': $(this).data('id'),
		  	'attended': true
		  },
		  success: function(result) {
		    eval(result);
		  },
		});
	});


	$('.edit').on('click', function(e) {
		e.preventDefault();
		e.stopPropagation();

		person_id = $(this).data('person-id');
		rsvp_id = $(this).data('rsvp-id');
		var url = '/people/' + person_id + '/edit';
		$.ajax({
			type: "GET",
		  url: url,
		  dataType: 'script',
		  data: {
		  	'rsvp_id': rsvp_id
		  },
		  success: function(result) {
		    eval(result);
		  },
		});
	});

	$('.to-cache').on('click', function() { $('#thinking').show();$('body').css({'overflow': 'hidden'})});

	$('.reveal-modal').on('open.fndtn.reveal', '[data-reveal]', function () {
	    $('body').addClass('modal-open');
	});
	$('.reveal-modal').on('close.fndtn.reveal', '[data-reveal]', function () {
	    $('body').removeClass('modal-open');
	});
	
	initializeRsvpList();
})

function initializeRsvpList() {
	if($('#list').size() > 0) {
		$('#list tfoot th').each( function () {
		    var title = $('#list thead th').eq( $(this).index() ).text();
		    $(this).html( '<input type="text" placeholder="Search '+title+'" />' );
		} );

		// DataTable
		table = $('#list').DataTable({
			"order": [[ 0, 'asc' ]],
			"paging": false,
			"oLanguage": {
			        "sZeroRecords": "No one found. <a href='/new_rsvp'>Add a new RSVP?</a>"
			    }
		});

		// Apply the search
		table.columns().eq( 0 ).each( function ( colIdx ) {
		    $('#datatable-search').on( 'keyup change', function () {
		        table
		            .column( colIdx )
		            .search( this.value )
		            .draw();
		    } );
		} );
	}
}