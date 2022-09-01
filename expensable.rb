# Start here. Happy coding!
require "httparty"
require "json"
require "terminal-table"
require_relative "services/sessions"
# require_relative "helpers/helpers"

class ExpensableApp
  def initialize
    @user = nil
  end

   def start
    puts welcome_message
    action = ""
    options=["login", "create_user", "exit"]
    puts options.join(" | ")
    until action == "exit"
        action=login_menu(options)[0]
        case action
        when "login" then login
        when "create_user" then create_user
        when "exit" then puts goodbye_message
        end
    end
  end

  def welcome_message
    ["####################################",
      "#       Welcome to Expensable      #",
      "####################################"
    ].join("\n")
  end

  def goodbye_message
    ["####################################",
      "#    Thanks for using Expensable   #",
      "####################################"
    ].join("\n")
  end

  def login_menu(options)
    get_with_options(options)
  end

  # def get_with_options(options)
  #   action = ""
  #   loop do
  #     print "> "
  #     action=gets.chomp
  #     break if options.include?(action)
  
  #     puts "Invalid option"
  #   end
  #   action
  # end

  def login
    credentials = credentials_form
    @user = Services::Sessions.login(credentials)
    # p @user
    categories_page
  end

  def credentials_form
    email = get_string("Email")
    password = get_string("Password")
  
    { email: email, password: password }
  end

  def get_string(label)
    input = ""
    loop do
      print "#{label}: "
      input = gets.chomp
      break unless input.empty?

      puts "Can't be blank"
    end
    
    input
  end

  def create_user
    credentials = user_form
    @user = Services::Sessions.signup(credentials)
    categories_page
    # notes_pages
    # p @user
  end

  def user_form
    email = get_string("Email")
    password = get_string("Password")
    first_name = get_string("First Name")
    last_name = get_string("Last Name")
    phone = get_string("Phone")
  
    { email: email, password: password, first_name: first_name, last_name:last_name, phone:phone }
  end

  def categories_menu(options)
    get_with_options(options)
  end

  # def get_with_options(options)
  #   action = ""
  #   loop do
  #     print "> "
  #     action=gets.chomp
  #     break if options.include?(action)
  
  #     puts "Invalid option"
  #   end
  #   action
  # end

  def get_with_options(options)
    action = ""
    id = nil
    loop do
      # puts options.join(" | ")
      print "> "
      action, id = gets.chomp.split(" ")
      # action ||= ""
      # Hacer el request!
      break if options.include?(action)
  
      puts "Invalid option"
    end
  
    # action.empty? && default ? [default, id] : [action, id.to_i]
    # action.empty? && default ? [default, id] : [action, id.to_i]
    #  true           nil
    [action, id.to_i]
  end

  def categories_page
    @categories = Services::Sessions.index(@user[:token])

    action = ""
    until action == "logout"
      # begin
        puts categories_table
        options=["create", "show", "update", "delete", "add-to", "toggle", "next", "logout"]
        puts options.join(" | ")
        action, id = categories_menu(options)
        # p action 
        # p id
        case action
        when "create" then puts "create #{id}"#create_note
        when "show" then puts "show "#update_note(id)
        when "update" then puts "update category"#delete_note(id)
        when "delete" then puts "delete category"#toggle_note(id)
        when "add-to" then puts "add-to category"#trash_page
        when "toggle" then puts "toggle category"#create_note
        when "next" then puts "next category"#update_note(id)
        when "logout" then puts "logout category"#delete_note(id)
        # when "exit" then puts "Thanks for using Keepable CLI"
        end
      # rescue HTTParty::ResponseError => error
      #   parsed_error = JSON.parse(error.message, symbolize_names: true)
      #   puts parsed_error
      # end
    end
  end
#   create | show ID | update ID | delete ID
# add-to ID | toggle | next | prev | logout

  def categories_table
    table = Terminal::Table.new
    table.title = "Expenses\nDecember 2021"
    table.headings = ["ID", "Category", "Total"]
    # table.rows = @categories
    table.rows = @categories.map do |category|
      [category[:id], category[:color], category[:icon]]
    end
    table
  end

end

app=ExpensableApp.new
app.start