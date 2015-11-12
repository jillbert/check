module PeopleHelper 

	def send_person_to_nationbuilder(person)

		# return {status: true, person: {"birthdate"=>nil, "city_district"=>nil, "civicrm_id"=>nil, "county_district"=>nil, "county_file_id"=>nil, "created_at"=>"2015-10-29T07:10:23-07:00", "datatrust_id"=>nil, "do_not_call"=>false, "do_not_contact"=>false, "dw_id"=>nil, "email"=>"jombo@strombolyayaya.ca", "email_opt_in"=>true, "employer"=>nil, "external_id"=>nil, "federal_district"=>nil, "fire_district"=>nil, "first_name"=>"Phillis", "has_facebook"=>false, "id"=>587, "is_twitter_follower"=>false, "is_volunteer"=>false, "judicial_district"=>nil, "labour_region"=>nil, "last_name"=>"Willis", "linkedin_id"=>nil, "mobile"=>nil, "mobile_opt_in"=>true, "nbec_guid"=>nil, "ngp_id"=>nil, "note"=>nil, "occupation"=>nil, "party"=>nil, "pf_strat_id"=>nil, "phone"=>nil, "precinct_id"=>nil, "primary_address"=>nil, "profile_image_url_ssl"=>"https://d3n8a8pro7vhmx.cloudfront.net/assets/icons/buddy.png", "recruiter_id"=>nil, "rnc_id"=>nil, "rnc_regid"=>nil, "salesforce_id"=>nil, "school_district"=>nil, "school_sub_district"=>nil, "sex"=>nil, "signup_type"=>0, "state_file_id"=>nil, "state_lower_district"=>nil, "state_upper_district"=>nil, "support_level"=>nil, "supranational_district"=>nil, "tags"=>[], "twitter_id"=>nil, "twitter_name"=>nil, "updated_at"=>"2015-10-29T07:10:23-07:00", "van_id"=>nil, "village_district"=>nil, "work_phone_number"=>nil, "active_customer_expires_at"=>nil, "active_customer_started_at"=>nil, "author"=>nil, "author_id"=>nil, "auto_import_id"=>nil, "availability"=>nil, "ballots"=>[], "banned_at"=>nil, "billing_address"=>nil, "bio"=>nil, "call_status_id"=>nil, "call_status_name"=>nil, "capital_amount_in_cents"=>500, "children_count"=>0, "church"=>nil, "city_sub_district"=>nil, "closed_invoices_amount_in_cents"=>nil, "closed_invoices_count"=>nil, "contact_status_id"=>nil, "contact_status_name"=>nil, "could_vote_status"=>nil, "demo"=>nil, "donations_amount_in_cents"=>0, "donations_amount_this_cycle_in_cents"=>0, "donations_count"=>0, "donations_count_this_cycle"=>0, "donations_pledged_amount_in_cents"=>0, "donations_raised_amount_in_cents"=>0, "donations_raised_amount_this_cycle_in_cents"=>0, "donations_raised_count"=>0, "donations_raised_count_this_cycle"=>0, "donations_to_raise_amount_in_cents"=>0, "email1"=>"jombo@strombolyayaya.ca", "email1_is_bad"=>false, "email2"=>nil, "email2_is_bad"=>false, "email3"=>nil, "email3_is_bad"=>false, "email4"=>nil, "email4_is_bad"=>false, "ethnicity"=>nil, "facebook_address"=>nil, "facebook_profile_url"=>nil, "facebook_updated_at"=>nil, "facebook_username"=>nil, "fax_number"=>nil, "federal_donotcall"=>false, "first_donated_at"=>nil, "first_fundraised_at"=>nil, "first_invoice_at"=>nil, "first_prospect_at"=>nil, "first_recruited_at"=>nil, "first_supporter_at"=>"2015-10-29T07:10:23-07:00", "first_volunteer_at"=>nil, "full_name"=>"Phillis Willis", "home_address"=>nil, "import_id"=>nil, "inferred_party"=>nil, "inferred_support_level"=>nil, "invoice_payments_amount_in_cents"=>0, "invoice_payments_referred_amount_in_cents"=>0, "invoices_amount_in_cents"=>nil, "invoices_count"=>nil, "is_absentee_voter"=>nil, "is_active_voter"=>nil, "is_deceased"=>false, "is_donor"=>false, "is_dropped_from_file"=>nil, "is_early_voter"=>nil, "is_fundraiser"=>false, "is_ignore_donation_limits"=>false, "is_leaderboardable"=>true, "is_mobile_bad"=>false, "is_permanent_absentee_voter"=>nil, "is_possible_duplicate"=>false, "is_profile_private"=>false, "is_profile_searchable"=>true, "is_prospect"=>false, "is_supporter"=>true, "is_survey_question_private"=>false, "language"=>nil, "last_call_id"=>nil, "last_contacted_at"=>nil, "last_contacted_by"=>nil, "last_donated_at"=>nil, "last_fundraised_at"=>nil, "last_invoice_at"=>nil, "last_rule_violation_at"=>nil, "legal_name"=>nil, "locale"=>nil, "mailing_address"=>nil, "marital_status"=>nil, "media_market_name"=>nil, "meetup_address"=>nil, "membership_expires_at"=>nil, "membership_level_name"=>nil, "membership_started_at"=>nil, "middle_name"=>nil, "mobile_normalized"=>nil, "nbec_precinct_code"=>nil, "nbec_precinct"=>nil, "note_updated_at"=>nil, "outstanding_invoices_amount_in_cents"=>nil, "outstanding_invoices_count"=>nil, "overdue_invoices_count"=>0, "page_slug"=>nil, "parent"=>nil, "parent_id"=>nil, "party_member"=>false, "phone_normalized"=>nil, "phone_time"=>nil, "precinct_code"=>nil, "precinct_name"=>nil, "prefix"=>nil, "previous_party"=>nil, "primary_email_id"=>1, "priority_level"=>nil, "priority_level_changed_at"=>nil, "profile_content"=>nil, "profile_content_html"=>nil, "profile_headline"=>nil, "received_capital_amount_in_cents"=>500, "recruiter"=>nil, "recruits_count"=>0, "registered_address"=>nil, "registered_at"=>nil, "religion"=>nil, "rule_violations_count"=>0, "spent_capital_amount_in_cents"=>0, "submitted_address"=>nil, "subnations"=>[], "suffix"=>nil, "support_level_changed_at"=>nil, "support_probability_score"=>nil, "township"=>nil, "turnout_probability_score"=>nil, "twitter_address"=>nil, "twitter_description"=>nil, "twitter_followers_count"=>nil, "twitter_friends_count"=>nil, "twitter_location"=>nil, "twitter_login"=>nil, "twitter_updated_at"=>nil, "twitter_website"=>nil, "unsubscribed_at"=>nil, "user_submitted_address"=>nil, "username"=>nil, "voter_updated_at"=>nil, "ward"=>nil, "warnings_count"=>0, "website"=>nil, "work_address"=>nil}}
		begin

			if person.nbid
		  	response = token.put("/api/v1/people/#{person.nbid}/", :headers => standard_headers, :body => person.to_person_object)
		  else
		  	response = token.put("/api/v1/people/push/", :headers => standard_headers, :body => person.to_person_object)
		  end
		rescue => ex
			puts ex
			begin
				puts ex
				nb_error = JSON.parse(ex.response.body)
			  error = nb_error['message']
			  if nb_error['validation_errors']
			  	error += "<ul>"
			  	for v_error in nb_error['validation_errors']
			  		error = error + "<li>" + v_error + "</li>"
			  	end
			  	error += "</ul>"
			  end
			rescue JSON::ParserError => e
			  error = "Nationbuilder unresponsive, please try again"
			end
      return {status: false, error: error}
		else
		  nbperson = JSON.parse(response.body)["person"]
      return {status: true, person: nbperson}
		end

	end

	def send_rsvp_host_to_nationbuilder(host, person)
		begin
			response = token.get("/api/v1/people/#{person.nbid}", :headers => standard_headers)
		rescue => ex
			puts ex
		else
			nbperson = JSON.parse(response.body)["person"]
			if !nbperson['recruiter_id']
				recruiter_person = {
				  :person => {
				    :recruiter_id => host.nbid
				  }
				}
				begin
					response = token.put("/api/v1/people/#{person.nbid}", :headers => standard_headers, :body => recruiter_person.to_json)
				rescue => ex
					puts ex
				else
					return true
				end
			else
				return true
			end
		end
	end

	def get_person(r)
		begin
		  response = token.get("/api/v1/people/#{r['person_id']}", :headers => standard_headers)
		rescue => ex
		  puts ex
		else
		  return JSON.parse(response.body)["person"]
		end
	end
end