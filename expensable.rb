# Start here. Happy coding!
require "httparty"
require "json"
require "terminal-table"
require_relative "services/sessions"
# require_relative "helpers/helpers"
class ExpensableApp
  def initialize
    @user = nil
    @type = "expense"
    @today = DateTime.parse("2021-09-15")
    @categories=nil
  end
   def start
    puts welcome_message
    action = ""
    options=["login", "create_user", "exit"]
    puts options.join(" | ")
    until action == "exit"

        action = login_menu(options)[0]

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
    categories_page
  rescue HTTParty::ResponseError => error
    parsed_errorr = JSON.parse(error.message, symbolize_names: true)
    puts parsed_errorr[:errors]
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
    options2=[]
    options.each do |option|
      options2<<option.split[0]
    end
    loop do
      print "> " 
      action, id =gets.chomp.split (" ")
      break if options2.include?(action)
      puts "Invalid option"
    end
    [action, id.to_i]
  end

  def categories_page
    @categories = Services::Sessions.indexcategories(@user[:token])
    action = ""
    until action == "logout"
        get_month_categories
      # begin
        puts categories_table
        options=["create", "show ID", "update ID", "delete ID", "add-to ID", "toggle", "next","prev", "logout"]
        puts options.join(" | ")
        action, id = categories_menu(options)
        case action

        when "create" then create_category
        when "show" then show(id)
        when "update" then update_category(id)
        # when "delete" then delete_category(id)
        when "add-to" then add_to(id)
        when "toggle" then toggle_category#create_note
        when "next" then next_category#update_note(id)

        when "prev" then prev_category
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

  def update_category(id)
    category_data = update_category_form
    updated_category = Services::Sessions.update(@user[:token], id, category_data)

    found_category = @categories.find { |category| category[:id] == id }
    found_category.update(updated_category)
  end

  def update_category_form
    name = get_string("Name")#, required: true)
    transaction_type = get_string("Transaction Type")#, required: true)
   
    { 
      name: name,#.empty? "Cannot be blank" : name, 
      transaction_type: transaction_type#.empty? "Only income or expense" 
    } #falta poner que si no es income o expense
  end

  # def delete_category(id)
  #   deleted_category = Services::Sessions.update(@name[:token], id)
    
  #   found_category = @category.find { |category| category[:id] == id }
  #   # found_category.update(deleted_category)
  #   @categories.delete(found_category)
  # end

  def add_to(id)
  transaction_data=transaction_form
  new_transaction=Services::Sessions.addto(@user[:token],id,transaction_data)
  category_selected=get_category_data(id)
  transactions_data=category_selected[:transactions]
  transactions_data.push(new_transaction)
  end

  def transaction_form
    amount = get_string("Amount")
    date = get_string("Date")
    notes = get_string("Notes")
    { id: 516, amount: amount, date: date, notes: notes}
  end

  def get_category_data(id)
    @categories.find {|category| category[:id]==id}
  end

  def categories_table
    table = Terminal::Table.new
    table.title = "#{@type.capitalize}\n #{@today.strftime("%B %Y")}" #format fecha mm-yyyy
    table.headings = ["ID", "Category", "Total"]
    dates_category=@categories.select {|category| category [:transaction_type] == @type }
    table.rows = dates_category.map do |category|
        total_amount = 0
        category[:resum].each do |transaction|
          total_amount += transaction[:amount]
        end
      [category[:id], category[:name],total_amount]
    end
    table
  end

  def toggle_category
    @type =  @type == "expense" ? "income" : "expense"
  end

  def get_month_categories

    @categories = @categories.map! do |category| #categories actualizado

      month=[]
      category[:transactions].each do |transaction|
       date = DateTime.parse(transaction[:date])  #se convierte en fecha 
       init_month = DateTime.new(@today.strftime("%Y").to_i,@today.strftime("%-m").to_i) #primer dia del mes 
       final_month = DateTime.new(@today.next_month.strftime("%Y").to_i,@today.next_month.strftime("%-m").to_i)-1 #ultimo dia de mes 

       if date < final_month && date > init_month
        month<<transaction
       end

       
      end
      category.merge(resum:month) #agrega un key adicional "Resum: " y value:mount[] en transactions que almacena el mes completo 
    end
    @categories
  end

  def next_category
    @today = @today.next_month
  end

  def prev_category
    @today = @today.prev_month
  end

  def show(id)
    puts "HOLA CATEGORY WITH ID #{id}"
    @transactions = Services::Sessions.indextransactions(@user[:token],id)
    transaction_page(id)
  end
end


def create_category
  category_data = category_form
  new_data = Services::Sessions.create(@user[:token], category_data)
  @categories << new_data
end
def category_form
  name = get_string("Name")
  transaction_type = get_string("Transaction Type")
  { name: name, transaction_type: transaction_type, color: "red", icon: "bank", transaction: [] }
end


  def transaction_page(id_category)
    action = ""
    until action == "back"
        get_month_transactions
      # begin
        puts transactions_table(id_category)
        options=["add", "update ID", "delete ID", "next", "prev", "back"]
        puts options.join(" | ")
        action, id = categories_menu(options)

        case action
        when "add" then puts "add #{id}"#create_note
        when "update" then puts "update transaction #{id}"
        when "delete" then delete_transaction(id_category,id)
        when "next" then puts "next transaction #{id}"
        when "prev" then puts "prev transaction #{id}"
        end
      # rescue HTTParty::ResponseError => error
      #   parsed_error = JSON.parse(error.message, symbolize_names: true)
      #   puts parsed_error
      # end
    end
  end
# self.deletetransaction(token, id_category, id_transaction)
  # @categories = Services::Sessions.indexcategories(@user[:token])
  def delete_transaction(id_category, id_transaction)
    deleted_transaction=Services::Sessions.destroytransaction(@user[:token], id_category, id_transaction)
    transaction_selected=@transactions.find {|transaction| transaction[:id]==id_transaction}
    @transactions.delete(transaction_selected)
  end

  def transactions_table(id_category)
    table = Terminal::Table.new
    selected_category=get_category_data(id_category)
    table.title = "#{selected_category[:name].capitalize}\n #{@today.strftime("%B %Y")}" #format fecha mm-yyyy
    table.headings = ["ID", "Date", "Amount","Notes"]
    table.rows = @transactions.map do |transaction|
      date=DateTime.parse(transaction[:date])
      [transaction[:id], date.strftime("%a, %b %e"),transaction[:amount],transaction[:notes]]
    end
    table
  end

  def get_month_transactions
    @transactions = @transactions.map! do |transaction|
      month=[]
       date = DateTime.parse(transaction[:date])  #se convierte en fecha
       init_month = DateTime.new(@today.strftime("%Y").to_i,@today.strftime("%-m").to_i) #primer dia del mes
       final_month = DateTime.new(@today.next_month.strftime("%Y").to_i,@today.next_month.strftime("%-m").to_i)-1 #ultimo dia de mes
       if date < final_month && date > init_month
        month<<transaction
       end
      transaction.merge(resum:month) #agrega un key adicional "Resum: " y value:mount[] en transactions que almacena el mes completo
  end
    @transactions=@transactions.select {|transaction| transaction[:resum].size>0}
    @transactions
end
app=ExpensableApp.new
app.start