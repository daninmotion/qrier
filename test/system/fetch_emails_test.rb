require "test_helper"
require "net/imap"
require "time"
require "qrier/models/email"
require "qrier/services/fetch_emails"

module Qrier
	class FetchEmailsTest <MiniTest::Test
		@@service = FetchEmails.new
		@@service.execute

		def test_fetches_emails
			assert_kind_of Email, @@service.emails.first
		end

		def test_email_has_propper_data
			assert_kind_of Time, @@service.emails.first.sent_at
		end
	end
end