module Qrier
	class FetchEmails
		attr_reader :emails
		def execute
			connect
			fetch_emails
			transform
		ensure
			@imap.disconnect
		end

		def emails
			@emails ||= []
		end

		private

		def connect
			@imap = Net::IMAP.new('imap.gmail.com', 993, true)
			@imap.login("dan85.cardenas@gmail.com", "lightsaber03")
		end

		def fetch_emails
			@email_data = []
			@imap.examine "INBOX"
			@imap.search([ "ALL" ]).each do |id|
				envelope = @imap.fetch(id, "ENVELOPE" )[0].attr["ENVELOPE"]
				uid = @imap.fetch(id, "UID"           )[0].attr["UID"]
				flags = @imap.fetch(id, "FLAGS"       )[0].attr["FLAGS"]
				body = @imap.fetch(id, "BODY[TEXT]"   )[0].attr["BODY[TEXT]"]

				@email_data << { envelope: envelope, uid: uid, flags: flags, body: body }
			end
		end

		def transform
			@email_data.each do |item|
				emails << Email.new({
					from: address(item[:envelope].from), 
					to: address(item[:envelope].to), 
					subject: item[:envelope].subject,
					sent_at: Time.parse(item[:envelope].date),
					body: item[:body].force_encoding('utf-8'),
				})
			end
			binding.pry
		end

		def address field
			field ? field.map { |item| [ item.mailbox, '@', item.host ].join } : nil
		end
	end
end