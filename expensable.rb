# Start here. Happy coding!
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
        when "add-to" then add_to(id)  #@categories#"#{@categories[:id]}" #trash_page
        when "toggle" then puts "toggle category"#create_note
        when "next" then puts "next category"#update_note(id)
        when "logout" 
          puts welcome_message
          options=["login", "create_user", "exit"]
          puts options.join(" | ")
        end
      # rescue HTTParty::ResponseError => error
      #   parsed_error = JSON.parse(error.message, symbolize_names: true)
      #   puts parsed_error
      # end
    end
  end

  # def start_welcome
  #   welcome_message
  #   options=["login", "create_user", "exit"]
  #   puts options.join(" | ")
  #   # break
  # end

  def add_to(id)
  category_selected=get_category_data(id)
  p category_selected
  transactions_data=category_selected[:transactions]
  p transactions_data
  transactions_data.push(new_transaction)
  p transactions_data
  end

  def new_transaction
    amount = get_string("Amount")
    date = get_string("Date")
    notes = get_string("Notes")
    { id: 516, amount: amount, date: "2021-11-30", notes: notes}
  end

  def get_category_data(id)
    @categories.find {|category| category[:id]==id}
  end

  def categories_table
    table = Terminal::Table.new
    # transaction_type=["income","expense"]
    # current_transaction=transaction_type[0]==(@categories[0][:transaction_type]) ? transaction_type[0] : transaction_type[1]
    
    table.title = "#{@categories[0][:transaction_type].capitalize}\nDecember 2021"
    table.headings = ["ID", "Category", "Total"]
    # table.rows = @categories
    table.rows = @categories.map do |category|
      [category[:id], category[:name], category[:icon]]
    end
    table
  end

end

app=ExpensableApp.new
app.start