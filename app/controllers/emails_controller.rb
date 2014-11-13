class EmailsController < ApplicationController
  # GET /emails
  # GET /emails.json
  require 'mailgun'
  require 'rest_client'
  require 'sendgrid-ruby'
  require 'mandrill'
  require 'set'


  # GET /emails/new
  # GET /emails/new.json
  def new
    @email = Email.new
  end

  # POST /emails
  # POST /emails.json

  def create
    emailSender = SendEmail.new
    if(emailSender.send_email(params[:email][:text],params[:email][:subject],params[:email][:send_from],params[:email][:send_to]))
      render :text =>'Email is succusfully send to '+params[:email][:send_to]   
    else
      render :text=>'Sorry, No email service is availabel now.'
    end 
  end

end



 class SendEmail
    require 'mailgun'
    require 'rest_client'
    require 'sendgrid-ruby'
    require 'mandrill'
    require 'set'
    EMAIL_SERVICE_LIST=['mandrill','sendgrid','mailgun']
    ####
    #  get email service name from choose_email_service method
    #  if email sercvice name is not mandrill sendgrid or mialgun
    #   return false which means no valid email service now
    ####

    def send_email (text,subject,sendFrom,sendTo)
      send_success=false;
      available_service_set=EMAIL_SERVICE_LIST.to_set
      while !send_success
        email_service=choose_email_service(available_service_set)
        case email_service
        when 'mandrill'
          send_success=send_email_from_mandrill(text,subject,sendFrom,sendTo)
        when 'sendgrid'  
          send_success=send_email_from_sendgrid(text,subject,sendFrom,sendTo)
        when  'mailgun'
          send_success=send_email_from_mailgun(text,subject,sendFrom,sendTo)
        else 
          return false
        end
        if(!send_success)
          available_service_set.delete(email_service)
        end
      end
      return true
    end

    ####
    #  generate random number and return 
    #  the service name for that random number
    #  if available_service_set empty no valid
    #  service string
    ####
    def choose_email_service available_service_set
      if (available_service_set.empty?)
        return 'no valid service'
      end
      random_num=rand(available_service_set.size)
      start_num=0
      available_service_set.each do |service_name| 
        if(start_num==random_num)
          return service_name
        end
        start_num+=1
      end
    end
   
   

    ####
    #   sending email from mandrill
    #   will try three times if fail. 
    #   return false if fail otherwise 
    #   return true 
    #
    ####

    def send_email_from_mandrill(text,subject,sendFrom,sendTo)
      

      num_of_retry=0
      begin
        man_drill_client = Mandrill::API.new 'DeLu3bzQlI35o1qjXI2lpw'
        mail_info ={"text"     =>  text,
                    "subject"   =>  subject + ' From ManDrill',
                    "from_email"=>  sendFrom,
                    "to"        =>   [{"email"=>sendTo,
                                       "type" =>"to"}],
                 }
        sending = man_drill_client.messages.send mail_info  
        puts sending
      rescue  Mandrill::Error => e
        if(num_of_retry<3)
          num_of_retry+=1
          retry
        else
          return false
        end
      end
      return true  
    end

    ####
    #   sending email from sendgrid
    #   will try three times if fail. 
    #   return false if fail otherwise 
    #   return true 
    #
    ####

    def send_email_from_sendgrid(text,subject,sendFrom,sendTo)
      num_of_retry=0
      begin
        send_grid_client = SendGrid::Client.new(api_user: 'chengyuan@leandatainc.com', api_key: '1390long')
        mail_info = SendGrid::Mail.new do |mail|
          mail.to = sendTo
          mail.from = sendFrom
          mail.subject = subject+' From SendGrid'
          mail.text = text
        end
        puts send_grid_client.send(mail_info) 
      rescue 
        if(num_of_retry<3)
          num_of_retry+=1
          retry
        else
          return false
        end
      end
      return true   
    end  


     ####
    #   sending email from mailgun
    #   will try three times if fail. 
    #   return false if fail otherwise 
    #   return true 
    #
    ####

    def send_email_from_mailgun(text,subject,sendFrom,sendTo)
      num_of_retry=0
      begin
        mail_gun_client = Mailgun::Client.new "key-359e4c17bea783d360a8fb2ced65394a"
        email_domain='leandatainc.com'
        # Define your message parameters
        mail_info = { :from    => sendFrom,
                      :to      => sendTo,
                      :subject => subject+' From MailGun',
                      :text    => text}

        # Send your message through the client
        mail_gun_client.send_message email_domain, mail_info
      rescue 
        if(num_of_retry<3)
          num_of_retry+=1
          retry
        else
          return false
        end
      end
      return true    
    end



    # GET /emails/1/edit
  end

