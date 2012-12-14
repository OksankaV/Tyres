require 'rubygems'
require 'sinatra'
require 'sqlite3'

enable :sessions

if File.exists?("tyres.db") and File.mtime("tyres.db")>=File.mtime("db-dump.sql")
    db = SQLite3::Database.new("tyres.db")
else 
    Kernel.system("rm tyres.db") if File.exists?("tyres.db")
    Kernel.system("sqlite3 tyres.db < db-dump.sql")
    db = SQLite3::Database.new("tyres.db")    
end    

Tyre_brand_name = db.execute("select title from TyreBrand").flatten
Tyre_providers = db.execute("select id, title from TyreProvider")
Tyre_family_name = db.execute("select family_title from TyreFamily").flatten
Tyre_width_name = db.execute("select distinct width from TyreModel order by width asc").flatten
Tyre_canonical_size = db.execute("select distinct canonical_size from TyreModel order by width asc").flatten
Tyre_height_name = db.execute("select distinct height from TyreModel order by height asc").flatten
Tyre_diameter_name = db.execute("select distinct rim_diameter from TyreModel order by rim_diameter asc").flatten
Tyre_season = { "W" => "Зимові", "S" => "Літні", "A" => "Всесезонні"}
Select_Array = ['Ширина', 'Висота', 'Діаметр', 'Виробник', 'Модель', 'Сезон']
Tyre_quantity = 4
Status_Hash = { 0 => "Не виконано", 1 => "Підтверджено", 2 => "Відправлено", 3 => "Завершено"}
Popular_tyre_brands = ["Bridgestone","Dunlop","Nokian"]
Necessery_Order = ["<small class='muted'>обов'язково</small>", "<small class='muted'>не обов'язково</small>"]
Order_Error_Messages = ["Вкажіть, будь ласка, Ваше ім'я!", "Не коректний email!", "Вкажіть, будь ласка, Ваш номер телефону!"]

get '/' do
    @title = "Головна"
    shoping_cart_function()
    erb :index
end


def filter_select(select, value, check_value, text, hash_key)
    if value != check_value
        select = select + text
        @bind_hash[hash_key.to_sym] = value
    end  
    return select  
end

def shoping_cart_function()
	cart_elements = {}
	session.each_pair do |key,value|
        if key =~ /\d+/ and value.class == Array
            cart_elements[key] = value
        end    
    end

    all_quantity = 0
    all_price = 0.00
    if cart_elements.empty? == false
        cart_elements.each_value do |article|
            all_quantity += article[4].to_i
            all_price += article[5].to_f 
        end  
    end
    session["all_quantity"] = all_quantity 
    session["all_price"] = all_price 
    return cart_elements
end


get '/tyres' do
    @title = "Шини"
    @index_form = false
    if params[:tyre_brand] != nil 
    	if params[:tyre_brand] != ""
        	@tyre_brand = params[:tyre_brand].to_a
        else	
    		@tyre_brand = Tyre_brand_name
    		@index_form = true
    	end
    elsif params[:item] != nil
    	if params[:item] != ""     
        	@tyre_brand = params[:item]
        else 
    		@tyre_brand = ""     
    	end
    else 
    	@tyre_brand = ""		
    end
    @tyre_width = params[:tyre_width]
    @tyre_height = params[:tyre_height]
    @tyre_diameter = params[:tyre_diameter]
    @tyre_family = params[:tyre_family]
    @tyre_season = params[:tyre_season]
    
    if @tyre_brand.empty? == false
    
		select_family = "select TyreFamily.id from TyreModel,TyreFamily where TyreModel.family_id = TyreFamily.id"

		@bind_hash = {}
		if @tyre_brand != nil and @tyre_brand.empty? == false
		    i=0
		    select_family =  select_family + " and ( "
		    @tyre_brand.each do |tyre_brands_check|
		        if i == 0
		            select_family = filter_select(select_family, tyre_brands_check, Select_Array[3], "TyreFamily.brand_title = :brand" + i.to_s, "brand" + i.to_s)
		        else
		            select_family = filter_select(select_family, tyre_brands_check, Select_Array[3], " or TyreFamily.brand_title = :brand" + i.to_s, "brand" + i.to_s)
		        end
		        i += 1
		    end
		    select_family =  select_family + " ) "
		end
		
		select_family = filter_select(select_family, @tyre_family, Select_Array[4], " and TyreFamily.family_title = :family", "family") if @tyre_family != nil and @tyre_family != ""
		select_family = filter_select(select_family, @tyre_width, Select_Array[0], " and TyreModel.width = :width", "width") if @tyre_width != nil and @tyre_width != ""
		select_family = filter_select(select_family, @tyre_height, Select_Array[1], " and TyreModel.height = :height", "height") if @tyre_height != nil and @tyre_height != ""
		select_family = filter_select(select_family, @tyre_diameter, Select_Array[2], " and TyreModel.rim_diameter = :diameter", "diameter") if @tyre_diameter != nil and @tyre_diameter != ""
		select_family = filter_select(select_family, @tyre_season, Select_Array[5], " and TyreFamily.season = :season", "season") if @tyre_season != nil and @tyre_season != ""
		
		select_family_id = db.execute(select_family, @bind_hash).flatten.uniq
		
		@select_family = {}
		@select_brand = {}
		select_family_id.each do |family_id|
		    select_family_title = db.execute("select family_title from TyreFamily where id=?",family_id)
		    select_brand_title = db.execute("select brand_title from TyreFamily where id=?",family_id)
		    @select_family[family_id] = (select_family_title.to_s)
		    @select_brand[family_id] = (select_brand_title.to_s)
		end  
	else
		@select_family = {}
		@select_brand = {}
	end	
	@show_hide_brands_class = {}
	Tyre_brand_name.each do |tyre_brand|
		if Popular_tyre_brands.include?(tyre_brand)
			@show_hide_brands_class[tyre_brand] = "popular_brand"
		else
			@show_hide_brands_class[tyre_brand] = "hidden_brand"
		end
	end
    erb :tyres
end

get '/delivery' do
    @title = "Доставка"
    erb :delivery
end

get '/models' do
    tyre_brand = params[:tyre_brand]
    if tyre_brand.empty?
        @families = db.execute("select family_title from TyreFamily").flatten
    else
        @families = db.execute("select family_title from TyreFamily where brand_title=?", tyre_brand).flatten
    end
    erb :models, :layout => false
end

get '/family/:family_id' do
    @family_id = params[:family_id]
    @tyre_brand = params[:tyre_brand]
    @tyre_family = params[:tyre_family]
    @title = @tyre_brand + "/" + @tyre_family
    @description = db.execute("select description from TyreFamily where id=?",@family_id).to_s
    @family_image = db.execute("select image from TyreFamily where id=?",@family_id).to_s
    model_id_array = db.execute("select id from TyreModel where family_id=?",@family_id).flatten
    
    @article = {}
    model_id_array.each do |model_id|
        select_canonical_size = db.execute("select canonical_size from TyreModel where id=?",model_id).flatten
        select_price = db.execute("select max(price) from TyreArticle where model_id=?",model_id).flatten
        select_quantity = db.execute("select quantity from TyreArticle where model_id=:model and price=:price", {:model => model_id, :price => select_price.first}).flatten
        select_article_id = db.execute("select id from TyreArticle where model_id=:model and price=:price and quantity=:quantity",{:model => model_id, :price => select_price.first, :quantity => select_quantity.first}).flatten
        @article[select_article_id] = [select_canonical_size.to_s,select_price.to_s,select_quantity.to_s]
    end
    erb :family
end

get '/shopping_cart' do
    @title = "Кошик"
    form = params[:form]
    @back_href = params[:back_href]
    @cart_elements = {}
    if @back_href == nil
        @back_href = "/"
    end 
    if form == "buy_form" 
        article_id = params[:article_id] 
        family_id = params[:family_id]
        tyre_brand = params[:tyre_brand]
        tyre_family = params[:tyre_family]
        tyre_price = params[:tyre_price]
        tyre_model = params[:tyre_model]
        if session.has_key?(article_id)
            old_session = session[article_id]
            tyre_quantity= old_session[4].to_i + Tyre_quantity
            tyre_price_quantity = tyre_price.to_f * tyre_quantity.to_i
            session[article_id] = [tyre_brand,tyre_family,tyre_model,tyre_price,tyre_quantity,tyre_price_quantity]
        else 
            tyre_quantity = Tyre_quantity
            tyre_price_quantity = tyre_price.to_f * tyre_quantity.to_i
            session[article_id] = [tyre_brand,tyre_family,tyre_model,tyre_price,tyre_quantity,tyre_price_quantity]
        end
    end   

    if form == "cart_form"
        article_quantity = params[:article]
        delete_article = params[:delete]
        session.each_pair do |key,article|
            if key =~ /\d+/ and article.class == Array
                article_price_quantity = article[3].to_f * article_quantity[key].to_i
                session[key] = [article[0],article[1],article[2],article[3],article_quantity[key],article_price_quantity]
                if delete_article != nil
                    session.delete(key) if delete_article[key].to_i == key.to_i
                end   
            end
        end  
    end 
	@cart_elements = shoping_cart_function()
    erb :shopping_cart
end

get '/order' do
    @title = "Оформлення замовлення"
    @control_group = {"control_name" => ["control-group", Necessery_Order[0]], "control_phone" => ["control-group",Necessery_Order[0]],"control_email" => ["control-group", Necessery_Order[1]]}
    @input_value = {"control_name" => "", "control_phone" => "","control_email" => ""}
    form = params[:form] 
    if form == "order_form" 
    	if ((params[:customer_name].empty? or params[:customer_name] == nil) or (params[:customer_phone].empty? or params[:customer_phone] == nil) or ((/^([a-z0-9_-]+\.)*[a-z0-9_-]+@[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,4}$/.match(params[:customer_email]) == nil) and params[:customer_email].empty? == false))
    		if (params[:customer_name].empty? or params[:customer_name] == nil)
    			@control_group["control_name"] = ["control-group error", Order_Error_Messages[0]]
    		else
    			@input_value["control_name"] = params[:customer_name]
    		end
    		if (params[:customer_phone].empty? or params[:customer_phone] == nil)
    			@control_group["control_phone"] = ["control-group error", Order_Error_Messages[2]]
    		else
    			@input_value["control_phone"] = params[:customer_phone]	
    		end
    		if ((/^([a-z0-9_-]+\.)*[a-z0-9_-]+@[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,4}$/.match(params[:customer_email]) == nil) and params[:customer_email].empty? == false)
    			@control_group["control_email"] = ["control-group error", Order_Error_Messages[1]]
    			@input_value["control_email"] = params[:customer_email]
    		else	
    			@input_value["control_email"] = params[:customer_email]	
    		end
    	else
        customer_name = params[:customer_name]
        customer_address = params[:customer_address]
        customer_email = params[:customer_email]
        customer_phone = params[:customer_phone]
        order_date = Time.now.strftime("%d/%m/%Y&nbsp;%H:%M:%S")
        db.execute("insert into Orders(name, address, email, phone, date, status) values(:name, :address, :email, :phone, :date, :status)", {:name => customer_name, :address => customer_address, :email => customer_email, :phone => customer_phone, :date => order_date, :status => 0})
        order_id = db.execute("select id from Orders where phone=? and name=? and date=?", [customer_phone, customer_name, order_date]).to_s.to_i
        session.each_pair do |article_id,propetries|
            if article_id =~ /\d+/ and propetries.class == Array 
                db.execute("insert into OrdersElements(order_id, article_id, price, quantity) values(:order_id, :article_id, :price, :quantity)", {:order_id => order_id, :article_id => article_id, :price => propetries[3], :quantity => propetries[4]})    
            end
        end
        session.clear
        session["all_quantity"] = 0
		session["all_price"] = 0.00
		redirect to('/thanks_page')
		end
    end
    erb :order
end

get '/orders_table' do
    @title = "Таблиця замовлень"
    form = params[:form]   
    if form == "order_table_form"
        customer_name = params[:customer_name]
        customer_address = params[:customer_address]
        customer_email = params[:customer_email]
        customer_phone = params[:customer_phone]
        order_status = params[:status]
        delete_order = params[:delete]
        orders_id = db.execute("select id from Orders").flatten
        orders_id.each do |order_id|
            db.execute("update Orders set name=:name,address=:address,email=:email,phone=:phone,status=:status where id=:id", {:name => customer_name[order_id.to_s], :address => customer_address[order_id.to_s], :email => customer_email[order_id.to_s], :phone => customer_phone[order_id.to_s], :status => order_status[order_id.to_s], :id => order_id}).flatten
            if delete_order != nil
                if delete_order[order_id.to_s].to_i == order_id
                    db.execute("delete from Orders where id=?",order_id).flatten
                    db.execute("delete from OrdersElements where order_id=?",order_id).flatten
                end
            end
        end
    end 
    @orders = {}
    select_orders_id = db.execute("select id from Orders").flatten
    select_orders_id.each do |select_order_id|
        @orders[select_order_id] = db.execute("select name, address, email, phone, date, status from Orders where id=?",select_order_id).flatten
    end
    erb :orders_table
end

get '/article_family' do
    tyre_brand = params[:tyre_brand]
    if tyre_brand.empty?
        @families = db.execute("select family_title from TyreFamily").flatten
    else
        @families = db.execute("select family_title from TyreFamily where brand_title=?", tyre_brand).flatten
    end
    erb :article_family, :layout => false
end

get '/article_model' do
    tyre_brand = params[:tyre_brand]
    tyre_family = params[:tyre_family]
    if tyre_family.empty?
        @models = db.execute("select canonical_size from TyreModel").flatten
    else
        @models = db.execute("select canonical_size from TyreModel where TyreModel.family_id=(select id from TyreFamily where brand_title=:brand_title and family_title=:family_title)", {:brand_title => tyre_brand, :family_title => tyre_family}).flatten
    end
    erb :article_model, :layout => false
end

get '/article_provider' do
    tyre_brand = params[:tyre_brand]
    tyre_family = params[:tyre_family]
    tyre_model = params[:tyre_model]
    if tyre_model.empty?
        @providers = db.execute("select title from TyreProvider").flatten
    else
        providers_id = db.execute("select provider_id from TyreArticle where model_id=(select id from TyreModel where TyreModel.canonical_size=:tyre_model and TyreModel.family_id=(select id from TyreFamily where brand_title=:brand_title and family_title=:family_title))", {:tyre_model => tyre_model, :brand_title => tyre_brand, :family_title => tyre_family}).flatten
        @providers = []
        providers_id.each do |provider_id|
            @providers.push(db.execute("select id, title from TyreProvider where id=?", provider_id).flatten)
        end
    end
    erb :article_provider, :layout => false
end

get '/detect_article_id' do
    @old_id = params[:old_id]
    tyre_brand = params[:tyre_brand]
    tyre_family = params[:tyre_family]
    tyre_model = params[:tyre_model]
    tyre_provider = params[:tyre_provider]
    if tyre_provider.empty? == false
        @detected_article_id = db.execute("select id from TyreArticle where provider_id=:tyre_provider and model_id=(select id from TyreModel where canonical_size=:tyre_model and family_id=(select id from TyreFamily where brand_title=:brand_title and family_title=:family_title))", {:tyre_provider => tyre_provider.to_i, :tyre_model => tyre_model, :brand_title => tyre_brand, :family_title => tyre_family}).flatten.first.to_i
    end
    erb :detect_article_id, :layout => false
end

get '/orders_elements/:id' do
    @title = "Елементи замовлення"
    @order_id = params[:id]
    form = params[:form]   
    if form == "one_order_form"
        db.execute("begin transaction")   
        db.execute("delete from OrdersElements where order_id=?", @order_id).flatten
        article_id_params = params[:article_id]
        tyre_quantity_params = params[:quantity]
        delete_article_params = params[:delete]
        article_id_params.each_pair do |old_id, new_id|
            db.execute("update OrdersElements set quantity=:quantity where article_id=:article_id and order_id=:order_id", {:quantity => tyre_quantity_params[old_id].to_i, :article_id => new_id.to_i, :order_id => @order_id}).flatten 
            new_tyre_price = db.execute("select price from TyreArticle where id=?", new_id.to_i).flatten.first 
            if delete_article_params == nil
                db.execute("insert into OrdersElements(order_id, article_id, price, quantity) values(:order_id, :article_id, :price, :quantity)", {:order_id => @order_id, :article_id => new_id.to_i, :price => new_tyre_price, :quantity => tyre_quantity_params[old_id].to_i})
            elsif delete_article_params.has_value?(old_id) == false
                db.execute("insert into OrdersElements(order_id, article_id, price, quantity) values(:order_id, :article_id, :price, :quantity)", {:order_id => @order_id, :article_id => new_id.to_i, :price => new_tyre_price, :quantity => tyre_quantity_params[old_id].to_i})       
            end   
        end
        db.execute("commit")   
    end
    @customer_data = db.execute("select name,address,email,phone from Orders where id=?", @order_id).flatten
    order_elements = db.execute("select article_id,price,quantity from OrdersElements where order_id=?", @order_id)
    @order_elements  = {}
    @family_value = {}
    @model_value = {}
    @provider_value = {}
    @total_price = {}
    order_elements.each do |row|
        article_id = row[0]
        model_id = db.execute("select model_id from TyreArticle where id=?", article_id).to_s.to_i
        row.delete_at(0)
        model = db.execute("select family_id, canonical_size from TyreModel where TyreModel.id = ?", model_id).flatten
        family = db.execute("select brand_title,family_title from TyreFamily where TyreFamily.id = ?", model[0].to_i).flatten
        row.insert(0,family[0].to_s)
        @family_value[article_id] = db.execute("select family_title from TyreFamily where brand_title = ?", family[0].to_s).flatten
        row.insert(1,family[1].to_s)
        @model_value[article_id] = db.execute("select canonical_size from TyreModel where TyreModel.family_id=(select id from TyreFamily where brand_title=:brand_title and family_title=:family_title)", {:brand_title => family[0].to_s, :family_title => family[1].to_s}).flatten
        row.insert(2,model[1].to_s)
        @provider_value[article_id] = db.execute("select TyreProvider.id, TyreProvider.title from TyreProvider,TyreArticle where TyreArticle.provider_id=TyreProvider.id and TyreArticle.model_id=?", model_id)
        provider = db.execute("select TyreProvider.id from TyreProvider,TyreArticle where TyreArticle.provider_id=TyreProvider.id and TyreArticle.id=?", article_id).flatten.first
        row.insert(3,provider)
        @total_price[article_id] = row[4] * row[5]
        @order_elements[article_id] = row
    end
    @order_price = 0.00
    @total_price.each_value do |element_price|
        @order_price += element_price 
    end
    erb :orders_elements
end

get '/add_order_element' do
    @id = "new_" + params[:id_param].to_s
    erb :add_order_element, :layout => false
end

get '/thanks_page' do
    @title = "Дякуємо"
    erb :thanks_page
end

__END__

@@ models
<option value="" selected>Модель</option>
<%@families.each do |family|%>
    <option value="<%=family%>"><%=family%></option>   
<%end%>


@@ article_family
<option value="" selected>Модель</option>
<%@families.each do |family|%>
    <option value="<%=family%>"><%=family%></option>   
<%end%>


@@ article_model
<option value="" selected>Розмір</option>
<%@models.each do |model|%>
    <option value="<%=model%>"><%=model%></option>   
<%end%>

@@ article_provider
<option value="" selected>Провайдер</option>
<%@providers.each do |id,provider|%>
    <option value="<%=id%>"><%=provider%></option>   
<%end%>

@@ detect_article_id
<input name="article_id[<%=@old_id%>]" type="hidden" value="<%=@detected_article_id%>">








