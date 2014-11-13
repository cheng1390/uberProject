class Email < ActiveRecord::Base
  attr_accessible :send_from, :send_to, :subject, :text
end
