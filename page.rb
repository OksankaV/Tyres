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
Tyre_providers = db.execute("select id, title from TyreProvider").flatten
Tyre_family_name = db.execute("select family_title from TyreFamily").flatten
Tyre_width_name = db.execute("select distinct width from TyreModel order by width asc").flatten
Tyre_canonical_size = db.execute("select distinct canonical_size from TyreModel order by width asc").flatten
Tyre_height_name = db.execute("select distinct height from TyreModel order by height asc").flatten
Tyre_diameter_name = db.execute("select distinct rim_diameter from TyreModel order by rim_diameter asc").flatten
Tyre_season = { "W" => "Зимові шини", "S" => "Літні шини", "A" => "Всесезоннні шини"}
Select_Array = ['Ширина', 'Висота', 'Діаметр', 'Виробник', 'Модель', 'Сезон']
Tyre_quantity = 4
Status_Hash = { 0 => "Не виконано", 1 => "Підтверджено", 2 => "Відправлено", 3 => "Завершено"}

get '/' do
    erb :index
end


def filter_select(select, value, check_value, text, hash_key)
    if value != check_value
        select = select + text
        @bind_hash[hash_key.to_sym] = value
    end  
    return select  
end


get '/tyres' do
    if params[:tyre_brand] != nil
        @tyre_brand = params[:tyre_brand].to_a
    elsif params[:item] != nil     
        @tyre_brand = params[:item]
    else 
        @tyre_brand = Tyre_brand_name    
    end
    @tyre_width = params[:tyre_width]
    @tyre_height = params[:tyre_height]
    @tyre_diameter = params[:tyre_diameter]
    @tyre_family = params[:tyre_family]
    @tyre_season = params[:tyre_season]
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
    select_family_id.each do |family_id|
        select_family_title = db.execute("select family_title from TyreFamily where id=?",family_id)
        select_brand_title = db.execute("select brand_title from TyreFamily where id=?",family_id)
        @select_family[family_id] = ([select_family_title.to_s,select_brand_title.to_s])
    end  
    erb :tyres
end

get '/delivery' do
    erb :delivery
end

get '/models' do
    tyre_brand = params[:tyre_brand]
    
    if tyre_brand.empty?
        @families = db.execute("select family_title from TyreFamily").flatten
    else
        @families = db.execute("select family_title from TyreFamily where brand_title=?", tyre_brand).flatten
    end
    erb :models
end

get '/family/:family_id' do
    @family_id = params[:family_id]
    @tyre_brand = params[:tyre_brand]
    @tyre_family = params[:tyre_family]
    
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
    @form = params[:form]
    @back_href = params[:back_href]
    if @back_href == nil
        @back_href = "/"
    end 
    if @form == "buy_form" 
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
    if @form == "cart_form"
        session.each do |key,article|
            article_quantity = params[("article_" + key.to_s).to_sym].to_i
            delete_article = params[("delete_" + key.to_s).to_sym]
            article_price_quantity = article[3].to_f * article_quantity
            session[key] = [article[0],article[1],article[2],article[3],article_quantity,article_price_quantity]
            session.delete(key) if delete_article.to_i == key.to_i
        end  
    end 

    @all_quantity = 0
    @all_price = 0.00
    session.each_value do |article|
        @all_quantity += article[4].to_i
        @all_price += article[5].to_f  
    end   
    erb :shopping_cart
end

get '/order' do
    erb :order
end

get '/orders_table' do
    @form = params[:form]   
    if @form == "order_form" 
        customer_name = params[:customer_name]
        customer_address = params[:customer_address]
        customer_email = params[:customer_email]
        customer_phone = params[:customer_phone]
        order_date = Time.now.strftime("%d/%m/%Y %H:%M:%S")
        
        db.execute("insert into Orders(name, address, email, phone, date, status) values(?,?,?,?,?,?)", [customer_name, customer_address, customer_email, customer_phone, order_date, 0])

        order_id = db.execute("select id from Orders where phone=? and name=? and date=?", [customer_phone, customer_name, order_date]).to_s.to_i
        
        session.each do |article_id,propetries|
            db.execute("insert into OrdersElements(order_id, article_id, price, quantity) values(?,?,?,?)", [order_id, article_id, propetries[3], propetries[4]])    
        end
    end
    if @form == "order_table_form"
        orders_id = db.execute("select id from Orders").flatten
        orders_id.each do |order_id|
            customer_name = params[("customer_name_" + order_id.to_s).to_sym]
            customer_address = params[("customer_address_" + order_id.to_s).to_sym]
            customer_email = params[("customer_email_" + order_id.to_s).to_sym]
            customer_phone = params[("customer_phone_" + order_id.to_s).to_sym]
            order_status = params[("status_" + order_id.to_s).to_sym]
            db.execute("update Orders set name=?,address=?,email=?,phone=?,status=? where id=?", [customer_name, customer_address, customer_email, customer_phone, order_status, order_id]).flatten
            delete_order = params[("delete_" + order_id.to_s).to_sym].to_i
            if delete_order == order_id
                db.execute("delete from Orders where id=?",order_id).flatten
                db.execute("delete from OrdersElements where order_id=?",order_id).flatten
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
    erb :article_family
end

get '/article_model' do
    tyre_brand = params[:tyre_brand]
    tyre_family = params[:tyre_family]
    
    if tyre_family.empty?
        @models = db.execute("select canonical_size from TyreModel").flatten
    else
        @models = db.execute("select canonical_size from TyreModel where TyreModel.family_id=(select id from TyreFamily where brand_title=? and family_title=?)", [tyre_brand,tyre_family]).flatten
    end
    erb :article_model
end

get '/article_provider' do
    tyre_brand = params[:tyre_brand]
    tyre_family = params[:tyre_family]
    tyre_model = params[:tyre_model]
   
    if tyre_model.empty?
        @providers = db.execute("select title from TyreProvider").flatten
    else
        providers_id = db.execute("select provider_id from TyreArticle where model_id=(select id from TyreModel where TyreModel.canonical_size=? and TyreModel.family_id=(select id from TyreFamily where brand_title=? and family_title=?))", [tyre_model,tyre_brand,tyre_family]).flatten
        @providers = []
        providers_id.each do |provider_id|
            @providers.push(db.execute("select id, title from TyreProvider where id=?", provider_id).flatten)
        end
    end
    erb :article_provider
end

get '/orders_elements/:id' do
    @order_id = params[:id]
    @form = params[:form]   
    if @form == "one_order_form"
        
        select_articles_id = db.execute("select article_id from OrdersElements where order_id=?",@order_id).flatten
        select_articles_id.each do |select_article_id|
            tyre_quantity_param = params[("quantity_" + select_article_id.to_s).to_sym].to_i
            db.execute("update OrdersElements set quantity=? where article_id=? and order_id=?", [tyre_quantity_param, select_article_id, @order_id]).flatten
            article_id_param = params[("article_" + select_article_id.to_s).to_sym].to_i
            tyre_brand_param = params[("tyre_brand_" + select_article_id.to_s).to_sym]
            tyre_family_param = params[("tyre_family_" + select_article_id.to_s).to_sym]
            tyre_model_param = params[("tyre_model_" + select_article_id.to_s).to_sym]
            tyre_provider_param = params[("tyre_provider_" + select_article_id.to_s).to_sym].to_i
                       
            new_article_id = db.execute("select id from TyreArticle where provider_id=? and model_id=(select id from TyreModel where canonical_size=? and family_id=(select id from TyreFamily where brand_title=? and family_title=?))", [tyre_provider_param, tyre_model_param, tyre_brand_param, tyre_family_param]).flatten.first.to_i
            
            new_tyre_price = db.execute("select price from TyreArticle where id=?", new_article_id).flatten.first

            if ((article_id_param != new_article_id) and (new_tyre_price != nil))
                db.execute("delete from OrdersElements where article_id=? and order_id=?", [ select_article_id, @order_id]).flatten
                db.execute("insert into OrdersElements(order_id, article_id, price, quantity) values(?,?,?,?)", [@order_id, new_article_id, new_tyre_price, tyre_quantity_param])    
            end
            
            delete_article = params[("delete_" + select_article_id.to_s).to_sym]
            if delete_article == select_article_id.to_s
                db.execute("delete from OrdersElements where article_id=? and order_id=?", [new_article_id,@order_id]).flatten
            end
        end  
        
        check_articles_id = db.execute("select article_id from OrdersElements where order_id=?",@order_id).flatten
        add_aricle_array = params[:add_aricle]
        if add_aricle_array != nil
            add_tyre_brands = params[:new_tyre_brand]
            add_tyre_families = params[:new_tyre_family]
            add_tyre_models = params[:new_tyre_model]
            add_tyre_providers = params[:new_tyre_provider]
            add_tyre_quantity = params[:new_quantity]
            new_delete_article = params[:new_delete]
            
            add_aricle_array.each_key do |key|
                add_tyre_article_id = db.execute("select id from TyreArticle where provider_id=? and model_id=(select id from TyreModel where canonical_size=? and family_id=(select id from TyreFamily where brand_title=? and family_title=?))", [add_tyre_providers[key], add_tyre_models[key], add_tyre_brands[key], add_tyre_families[key]]).flatten.first.to_i
                new_add_price = db.execute("select price from TyreArticle where id=?", add_tyre_article_id).flatten.first
                if check_articles_id.include?(add_tyre_article_id) == false
                    if new_delete_article == nil
                        db.execute("insert into OrdersElements(order_id, article_id, price, quantity) values(?,?,?,?)", [@order_id, add_tyre_article_id, new_add_price, add_tyre_quantity[key]])
                    else 
                        db.execute("insert into OrdersElements(order_id, article_id, price, quantity) values(?,?,?,?)", [@order_id, add_tyre_article_id, new_add_price, add_tyre_quantity[key]]) if new_delete_article.has_key?(key) == false     
                    end   
                end     
            end    
        end  
    end
    
    @customer_data = db.execute("select name,address,email,phone from Orders where id=?", @order_id)
    
    order_elements = db.execute("select article_id,price,quantity from OrdersElements where order_id=?", @order_id)
    @order_elements  = {}
    @family_value = {}
    @model_value = {}
    @provider_value = {}
    order_elements.each do |row|
        article_id = row[0]
        model_id = db.execute("select model_id from TyreArticle where id=?", article_id).to_s.to_i
        row.delete_at(0)
        model = db.execute("select family_id, canonical_size from TyreModel where TyreModel.id = ?", model_id).flatten
        family = db.execute("select brand_title,family_title from TyreFamily where TyreFamily.id = ?", model[0].to_i).flatten
        row.insert(0,family[0].to_s)
        @family_value[article_id] = db.execute("select family_title from TyreFamily where brand_title = ?", family[0].to_s).flatten
        row.insert(1,family[1].to_s)
        @model_value[article_id] = db.execute("select canonical_size from TyreModel where TyreModel.family_id=(select id from TyreFamily where brand_title=? and family_title=?)", [family[0].to_s,family[1].to_s]).flatten
        row.insert(2,model[1].to_s)
        @provider_value[article_id] = db.execute("select TyreProvider.id, TyreProvider.title from TyreProvider,TyreArticle where TyreArticle.provider_id=TyreProvider.id and TyreArticle.model_id=?", model_id)
        provider = db.execute("select TyreProvider.id from TyreProvider,TyreArticle where TyreArticle.provider_id=TyreProvider.id and TyreArticle.id=?", article_id).flatten.first
        row.insert(3,provider)
        @order_elements[article_id] = row
    end
    
    erb :orders_elements
end

get '/add_order_element' do
    @id = params[:id_param]
    erb :add_order_element
end



__END__

@@ index
<html>
    <head>
        <title>Main</title>
        <meta charset="utf-8">
        <script type="text/javascript" src="http://code.jquery.com/jquery.js"></script> 
        <script>
            function change_families()
            {
                var brand = $('select[name="tyre_brand"]').val();
                $.get(
                    "/models",
                    {tyre_brand: brand},
                    function(data) {$('select[name="tyre_family"]').html(data)}
                );
            }  

        </script>    
    </head>
    <body>
        <ul>
            <li><a href="/tyres?tyre_brand=">Шини</a></li>
            <li>Диски</li>
            <li><a href="/delivery">Доставка</a></li>
        </ul>
        <form name="search_tyre_form" method="GET" action="tyres">
            <select name="tyre_width">
                <option value="">Ширина</option>
                <%Tyre_width_name.each do |tyre_width_name|%>  
                    <option value="<%=tyre_width_name%>"><%=tyre_width_name%></option>  
                <%end%>   
            </select>
            <b>/</b>
            <select name="tyre_height">
                <option value="">Висота</option>
                <%Tyre_height_name.each do |tyre_height_name|%>
                    <option value="<%=tyre_height_name%>"><%=tyre_height_name%></option>  
                <%end%>   
            </select>
            <b>R</b>
            <select name="tyre_diameter">
                <option value="">Діаметр</option>
                <%Tyre_diameter_name.each do |tyre_diameter_name|%> 
                    <option value="<%=tyre_diameter_name%>"><%=tyre_diameter_name%></option>  
                <%end%>   
            </select> 
            <br>

            <select name="tyre_brand" onChange="change_families()">
                <option value="">Виробник</option>
                <%Tyre_brand_name.each do |tyre_brand_name|%>    
                    <option value="<%=tyre_brand_name%>"><%=tyre_brand_name%></option>  
                <%end%>
            </select>
             
            <select name="tyre_family">
                <option value="" selected>Модель</option>
                <%Tyre_family_name.each do |tyre_family_name|%>
                    <option value="<%=tyre_family_name%>"><%=tyre_family_name%></option> 
                <%end%>
            </select> 
            <br>
            <select name="tyre_season">
                <option value="">Сезон</option>
                <%Tyre_season.each do |key_tyre_season,value_tyre_season|%>  
                    <option value="<%=key_tyre_season%>"><%=value_tyre_season%></option>  
                <%end%>
            </select>
            <br>
            
            <input type="submit" value="Пошук"> 
        </form>        
    </body>
</html>



@@ tyres
<html>
    <head>
        <title>Tyres</title>
        <meta charset="utf-8">
    </head>
    <body>
    
        <form method="GET" action="tyres"> 
        
            <ul>Виробники  
            <%Tyre_brand_name.each do |tyre_brand_name|%>
                <%if @tyre_brand.include?(tyre_brand_name.to_s) or @tyre_brand.empty?%>
                    <li><input type="checkbox" name="item[]" value="<%=tyre_brand_name%>" checked><%=tyre_brand_name%></li>
                <%else%> 
                    <li><input type="checkbox" name="item[]" value="<%=tyre_brand_name%>" ><%=tyre_brand_name%></li>   
                <%end%>  
            <%end%>
            </ul> 
                 
            <select name="tyre_width">
                <option value="">Ширина</option>
                <%Tyre_width_name.each do |tyre_width_name|%>
                    <%if @tyre_width == tyre_width_name.to_s%>
                        <option value="<%=tyre_width_name%>" selected><%=tyre_width_name%></option>   
                     <%else%>    
                        <option value="<%=tyre_width_name%>"><%=tyre_width_name%></option>  
                    <%end%>
                <%end%>     
            </select>
            <b>/</b>
            <select name="tyre_height">
                <option value="">Висота</option>
                <%Tyre_height_name.each do |tyre_height_name|%>
                    <%if @tyre_height == tyre_height_name.to_s%>
                        <option value="<%=tyre_height_name%>" selected><%=tyre_height_name%></option>   
                    <%else%>    
                        <option value="<%=tyre_height_name%>"><%=tyre_height_name%></option>  
                    <%end%> 
                <%end%>    
            </select>
            <b>R</b>
            <select name="tyre_diameter">
                <option value="">Діаметр</option>
                <%Tyre_diameter_name.each do |tyre_diameter_name|%>
                    <%if @tyre_diameter == tyre_diameter_name.to_s%>
                        <option value="<%=tyre_diameter_name%>" selected><%=tyre_diameter_name%></option>   
                    <%else%>    
                        <option value="<%=tyre_diameter_name%>"><%=tyre_diameter_name%></option>  
                    <%end%> 
                <%end%>    
            </select> 

            <select name="tyre_season">
                <option value="">Сезон</option>
                <%Tyre_season.each do |key_tyre_season,value_tyre_season|%>
                    <%if @tyre_season == key_tyre_season.to_s%>
                        <option value="<%=key_tyre_season%>" selected><%=value_tyre_season%></option>   
                    <%else%>    
                        <option value="<%=key_tyre_season%>"><%=value_tyre_season%></option>  
                    <%end%> 
               <%end%>
            </select>
            <input type="submit" value="Пошук"> 
            
            <%if @select_family.empty?%>
                <p>Нічого не знайдено</p>
            <%else%>      
                <%@select_family.sort{|a,b| a[1]<=>b[1]}.each do |family_id,brand_family|%>
                    <li><a href="/family/<%=family_id%>?family_id=<%=family_id%>&tyre_brand=<%=brand_family[1]%>&tyre_family=<%=brand_family[0]%>"><%=brand_family[1]%> - <%=brand_family[0]%></a></li>   
                <%end%> 
            <%end%> 
              
        </form>        
    </body>
</html>

@@ delivery
<html>
    <head>
        <title>Delivery</title>
        <meta charset="utf-8">
    </head>
    <body>
         
    </body>
</html>


@@ models

<option value="" selected>Модель</option>
<%@families.each do |family|%>
    <option value="<%=family%>"><%=family%></option>   
<%end%>


@@ family
<html>
    <head>
        <title><%=@tyre_brand%>/<%=@tyre_family%></title>
        <meta charset="utf-8">
    </head>
    <body>
    <%=@tyre_brand%>/<%=@tyre_family%>
    <p>Опис:<br><%=@description%></p>
    <img src="/Images/<%=@family_image%>">
    <ul>Моделі:<br>
        <%@article.each do |article_id,propetries|%>
            <li>
                <form name="buy_form" method="GET" action="/shopping_cart">
                    <input name="form" type="hidden" value="buy_form">
                    <%=propetries[0]%> Ціна моделі: <%=propetries[1]%> грн. Кількість: <%=propetries[2]%>
                    <input name="tyre_brand" type="hidden" value="<%=@tyre_brand%>"> 
                    <input name="tyre_family" type="hidden" value="<%=@tyre_family%>">
                    <input name="tyre_model" type="hidden" value="<%=propetries[0]%>">
                    <input name="tyre_price" type="hidden" value="<%=propetries[1]%>">
                    <input name="family_id" type="hidden" value="<%=@family_id%>">
                    <input name="article_id" type="hidden" value="<%=article_id%>">
                    <input name="back_href" type="hidden" value="/family/<%=@family_id%>?family_id=<%=@family_id%>&tyre_brand=<%=@tyre_brand%>&tyre_family=<%=@tyre_family%>">
                    <%if propetries[2].to_i > 0%>
                        <input type="submit" value="Купити">
                    <%else%>
                         <b>Немає в наявності</b>
                    <%end%>

                </form> 
            </li>
        <%end%>
     
    </ul>    
    </body>
</html>

@@ shopping_cart
<html>
    <head>
        <title>Кошик</title>
        <meta charset="utf-8">
                <script>
        
            function validate_form()
            {
	            var form = document.cart_form;
	            
	            for (i=0; i<=form.length; i++)
	            {
                    if ((form.elements[i].type == "text") && (form.elements[i].value == 0 || form.elements[i].value == ""))
                    {
                        alert ( "Кількість товару не може бути 0" );
                        return false;
                    }
                    if (form.elements[i].type == "checkbox" && form.elements[i].checked == true)
                    { 
                        delete_confirm = confirm("Видалити виділені елементи замовлення?");
                        if (delete_confirm == false)
                        {
                            return false;
                        }
                    }
                    
                }
                
                return true;
            }

           </script>  
    </head>
    <body>
        <form name="cart_form" method="GET" action="" onsubmit="return validate_form()">
            <input name="form" type="hidden" value="cart_form">
            <%session.sort{|a,b| a[1].first<=>b[1].first}.each do |key,article|%>
                <p>
                    Товар <%=article[0]%> - <%=article[1]%> - <%=article[2]%> Ціна: <%=article[3]%>  
                    Кількість: <input name="article_<%=key%>" type="text" value="<%=article[4]%>"> Всьго: <%=article[5]%> 
                    <input name="delete_<%=key%>" type="checkbox" value="<%=key%>">Видалити     
                </p>    
            <%end%>
            Всього товарів: <%=@all_quantity%> на суму <%=@all_price%> грн.
            <input name="back_href" type="hidden" value="<%=@back_href%>">
            <input type="submit" value="Перерахувати">
        </form>
        <a href="<%=@back_href%>">Повернутися до покупок</a>
        <a href='/order'>Оформити замовлення</a>   
    </body>
</html>

@@ order
<html>
    <head>
        <title>Замовлення</title>
        <meta charset="utf-8">
    </head>
    <body>
        <form name="order" method="GET" action="/orders_table">
            <input name="form" type="hidden" value="order_form">
            <p><b>Оформити замовлення</b></p>
            <p>Імя</p><input name="customer_name" type="text" required>
            <p>Адреса</p><input name="customer_address" type="text">
            <p>Електронна адреса</p><input name="customer_email" type="text">
            <p>Телефон</p><input name="customer_phone" type="text" required>
            <p><a href="shopping_cart">Повернутися до кошика</a>
            <input type="submit" value="Замовити"></p>
        </form>
    </body>
</html>

@@ orders_table
<html>
    <head>
        <title>Список замовлень</title>
        <meta charset="utf-8">
                <script type="text/javascript" src="http://code.jquery.com/jquery.js"></script> 
        <script>
        
            function validate_form()
            {
	            var form = document.order_table_form;
	            
	            for (i=0; i<=form.length; i++)
	            {
                    if ( form.elements[i].value == "" &&  /customer_name_/.test(form.elements[i].name) == true)
                    {
                        alert ( "Заповніть і’мя покупця в замовленні" );
                        return false;
                    }
                    if ( form.elements[i].value == "" &&  /customer_phone_/.test(form.elements[i].name) == true)
                    {
                        alert ( "Заповніть телефон покупця в замовленні" );
                        return false;
                    }
                    if (form.elements[i].type == "checkbox" && form.elements[i].checked == true)
                    { 
                        delete_confirm = confirm("Видалити виділені замовлення?");
                        if (delete_confirm == false)
                        {
                            return false;
                        }
                    }
                    
                }
                
                return true;
            }

        </script>   

    </head>
    <body>
        <p><b>Список замовлень</b></p>
        <form name="order_table_form" method="GET" action="" onsubmit="return validate_form()">
            <input name="form" type="hidden" value="order_table_form">
            <table border="1">
                <tr>
                    <td>Номер</td>
                    <td>Покупець</td>
                    <td>Адреса</td>
                    <td>Мило</td>
                    <td>Телефон</td>
                    <td>Дата</td>
                    <td>Статус</td>
                    <td>Видалити</td>
                </tr>
            <%@orders.sort.each do |order_id,order_data|%>
                <tr>
                    <td onclick="window.location.href='orders_elements/<%=order_id%>'"><%=order_id%></td>
                    <%order_data.each_index do |index|%>
                    <%if index == 0%> 
                        <td><input name="customer_name_<%=order_id%>" type="text"  type="text" value="<%=order_data[index]%>" size="10"></td> 
                    <%elsif index == 1%> 
                        <td><input name="customer_address_<%=order_id%>" type="text"  type="text" value="<%=order_data[index]%>" size="10"></td> 
                    <%elsif index == 2%> 
                        <td><input name="customer_email_<%=order_id%>" type="text"  type="text" value="<%=order_data[index]%>" size="10"></td>
                    <%elsif index == 3%> 
                        <td><input name="customer_phone_<%=order_id%>" type="text"  type="text" value="<%=order_data[index]%>" size="10"></td>  
                    <%elsif index == 5%>
                        <td>
                            <select name="status_<%=order_id%>">
                                <%Status_Hash.each do |status_key,status_value|%>
                                    <%if order_data[index] == status_key%>
                                        <option value="<%=status_key%>" selected><%=status_value%></option>
                                    <%else%>    
                                        <option value="<%=status_key%>"><%=status_value%></option>
                                    <%end%>        
                                <%end%>
                            </select>    
                        </td>
                    <%else%>
                        <td onclick="window.location.href='orders_elements/<%=order_id%>'"><%=order_data[index]%></td>
                    <%end%>
                <%end%>
                <td><input name="delete_<%=order_id%>" type="checkbox" value="<%=order_id%>"></td>
                </tr>
            <%end%>
            </table>
            <br>
            <input type="submit" value="Оновити дані">
        </form>
    </body>
</html>


@@ article_family
<option value="" selected>Оберіть модель</option>
<%@families.each do |family|%>
    <option value="<%=family%>"><%=family%></option>   
<%end%>


@@ article_model
<option value="" selected>Оберіть розміри</option>
<%@models.each do |model|%>
    <option value="<%=model%>"><%=model%></option>   
<%end%>

@@ article_provider
<option value="" selected>Оберіть провайдера</option>
<%@providers.each do |id,provider|%>
    <option value="<%=id%>"><%=provider%></option>   
<%end%>

@@ orders_elements
<html>
    <head>
        <title>orders_elements</title>
        <meta charset="utf-8">
        <script type="text/javascript" src="http://code.jquery.com/jquery.js"></script> 
        <script>
            function change_families(row_index, check_value)
            {       
                if (check_value == 0)
                {
                    var brand_select = "select[name='tyre_brand_" + row_index + "']"
                    var family_select = "select[name='tyre_family_" + row_index + "']"
                    var brand = $(brand_select).val();
                }
                else
                {
                    var brand_select = "select[name='new_tyre_brand[" + row_index + "]']"
                    var family_select = "select[name='new_tyre_family[" + row_index + "]']"
                    var brand = $(brand_select).val();
                }
                $.get(
                    "/article_family",
                    {tyre_brand: brand},
                    function(data) {$(family_select).html(data)}
                );
                change_models(row_index, check_value);
            } 
            
            function change_models(row_index, check_value)
            {
                if (check_value == 0)
                {
                    var brand_select = "select[name='tyre_brand_" + row_index + "']"
                    var family_select = "select[name='tyre_family_" + row_index + "']"
                    var model_select = "select[name='tyre_model_" + row_index + "']"
                    var brand = $(brand_select).val();
                    var family = $(family_select).val();
                }
                else
                {
                    var brand_select = "select[name='new_tyre_brand[" + row_index + "]']"
                    var family_select = "select[name='new_tyre_family[" + row_index + "]']"
                    var model_select = "select[name='new_tyre_model[" + row_index + "]']"
                    var brand = $(brand_select).val();
                    var family = $(family_select).val();
                }

                $.get(
                    "/article_model",
                    {tyre_brand: brand, tyre_family: family},
                    function(data) {$(model_select).html(data)}
                );
                change_providers(row_index, check_value);
            }  
            
            function change_providers(row_index, check_value)
            {
                if (check_value == 0)
                {
                    var brand_select = "select[name='tyre_brand_" + row_index + "']"
                    var family_select = "select[name='tyre_family_" + row_index + "']"
                    var model_select = "select[name='tyre_model_" + row_index + "']"
                    var provider_select = "select[name='tyre_provider_" + row_index + "']"
                    var brand = $(brand_select).val();
                    var family = $(family_select).val();
                    var model = $(model_select).val();
                }
                else
                {
                    var brand_select = "select[name='new_tyre_brand[" + row_index + "]']"
                    var family_select = "select[name='new_tyre_family[" + row_index + "]']"
                    var model_select = "select[name='new_tyre_model[" + row_index + "]']"
                    var provider_select = "select[name='new_tyre_provider[" + row_index + "]']"
                    var brand = $(brand_select).val();
                    var family = $(family_select).val();
                    var model = $(model_select).val();
                }

                $.get(
                    "/article_provider",
                    {tyre_brand: brand, tyre_family: family, tyre_model: model},
                    function(data) {$(provider_select).html(data)}
                );
            } 
            
            function add_new_row(id)
            {
                var tbody = document.getElementById("order_elements_table").getElementsByTagName("TBODY")[0];
                
                var tr = document.createElement("TR");
                var tr_id = document.createAttribute("id");
                tr_id.value = id;
                tr.setAttributeNode(tr_id);
                tbody.appendChild(tr);
                
                var button = document.getElementById("add_button");
                var button_click = document.createAttribute("onclick");
                var new_id = id + 1
                button_click.value = "add_new_row(" + new_id + ")";
                button.setAttributeNode(button_click);
                
                var new_order = "tr[id='" + id + "']"
                $.get(
                    "/add_order_element",
                    {id_param: id},
                    function(data) {$(new_order).html(data)}
                );
            } 
            
            
            function validate_form()
            {
	            var form = document.one_order_form;
	            for (i=0; i<=form.length; i++)
	            {
                    if ( form.elements[i].value == "")
                    {
                        alert ( "Заповніть всі елементи замовлення" );
                        return false;
                    }
                    if (form.elements[i].type == "text" && form.elements[i].value == 0)
                    {
                        alert ( "Кількість товару не може бути 0" );
                        return false;
                    }
                    if (form.elements[i].type == "checkbox" && form.elements[i].checked == true)
                    {
                        delete_confirm = confirm ( "Видалити виділені елементи замовлення?" );
                        if (delete_confirm == false)
                        {
                            return false;
                        }
                    }
                    
                }
                
                return true;
            }

            
           </script>   
    </head>
    <body>
        <%i = 0%>  
        <p><%=@customer_data.join(" ")%></p>
        <form name="one_order_form" method="GET" action="" onsubmit="return validate_form()">
            <input name="form" type="hidden" value="one_order_form">
            <table id="order_elements_table" border="1">
            <tbody>
                <tr id="0">
                    <td>Товар</td>
                    <td>Провайдер</td>
                    <td>Ціна</td>
                    <td>Кількість</td>
                    <td>Видалити</td>
                </tr>
             
            <%@order_elements.sort.each do |article_id,article_data|%>
                <tr id="<%=i = i+1%>">
                <%article_data.each_index do |index|%>
                    <%if index == 0%>
                    <td>
                        <select name="tyre_brand_<%=article_id%>" onchange="change_families(<%=article_id%>,0)">
                            <%Tyre_brand_name.each do |tyre_brand_name|%>
                                <%if article_data[index] == tyre_brand_name%>
                                    <option value="<%=tyre_brand_name%>" selected><%=tyre_brand_name%></option>
                                <%else%>    
                                    <option value="<%=tyre_brand_name%>"><%=tyre_brand_name%></option> 
                                <%end%>     
                            <%end%>
                        </select>
                    <%elsif index == 1%>      
                        <select name="tyre_family_<%=article_id%>" onchange="change_models(<%=article_id%>,0)">
                            <%family_value = @family_value[article_id]%>
                            <%family_value.each do |tyre_family_name|%>
                                <%if article_data[index] == tyre_family_name%>
                                    <option value="<%=tyre_family_name%>" selected><%=tyre_family_name%></option>
                                <%else%>    
                                    <option value="<%=tyre_family_name%>"><%=tyre_family_name%></option> 
                                <%end%>   
                            <%end%>
                        </select>
                    <%elsif index == 2%>
                        <select name="tyre_model_<%=article_id%>" onchange="change_providers(<%=article_id%>,0)">
                        <%model_value = @model_value[article_id]%>
                            <%model_value.each do |tyre_canonical_size|%>
                                <%if article_data[index] == tyre_canonical_size%>
                                    <option value="<%=tyre_canonical_size%>" selected><%=tyre_canonical_size%></option>
                                <%else%>    
                                    <option value="<%=tyre_canonical_size%>"><%=tyre_canonical_size%></option> 
                                <%end%>  
                            <%end%>
                        </select>      
                    </td>
                    <%elsif index == 3%>
                    <td>                        
                        <select name="tyre_provider_<%=article_id%>">
                        <%provider_value = @provider_value[article_id]%>
                            <%provider_value.sort.each do |tyre_provider_id,tyre_provider_title|%>
                                <%if article_data[index] == tyre_provider_id%>
                                    <option value="<%=tyre_provider_id%>" selected><%=tyre_provider_title%></option>
                                <%else%>    
                                    <option value="<%=tyre_provider_id%>"><%=tyre_provider_title%></option> 
                                <%end%>  
                            <%end%>
                        </select>      
                    </td>
                    <%elsif index == 5%>
                        <td><input name="quantity_<%=article_id%>" type="text" value="<%=article_data[index].to_i%>" size="3"></td>      
                    <%else%>
                        <td><%=article_data[index]%></td>
                    <%end%>
                <%end%>
                <td><input name="delete_<%=article_id%>" type="checkbox" value="<%=article_id%>"></td>
                </tr>
                <input name="article_<%=article_id%>" type="hidden" value="<%=article_id%>">
            <%end%>
            </tbody>
            </table>
            <br>
            <input id="add_button" type="button" value="Додати новий рядок" onclick="add_new_row(<%=i=i+1%>)">
            <input type="submit" value="Оновити дані" >
        </form>
       
    </body>
</html>

@@ add_order_element
    <td>
        <select name="new_tyre_brand[<%=@id%>]" onchange="change_families(<%=@id%>,1)">
            <option value="">Оберіть виробника</option>
            <%Tyre_brand_name.each do |tyre_brand_name|%>    
                <option value="<%=tyre_brand_name%>"><%=tyre_brand_name%></option>  
            <%end%>
        </select>
        <select name="new_tyre_family[<%=@id%>]" onchange="change_models(<%=@id%>,1)">
            <option value="">Оберіть модель</option>
            <%Tyre_family_name.each do |tyre_family_name|%>    
                <option value="<%=tyre_family_name%>"><%=tyre_family_name%></option>  
            <%end%>
        </select>
        <select name="new_tyre_model[<%=@id%>]" onchange="change_providers(<%=@id%>,1)">
            <option value="">Оберіть розмір</option>
            <%Tyre_canonical_size.each do |tyre_model_name|%>    
                <option value="<%=tyre_model_name%>"><%=tyre_model_name%></option>  
            <%end%>
        </select>
    </td>
    <td>                        
        <select name="new_tyre_provider[<%=@id%>]">
            <option value="">Оберіть провайдера</option>
            <%Tyre_providers.each do |tyre_provider_id,tyre_provider_title|%>    
                <option value="<%=tyre_provider_id%>"><%=tyre_provider_title%></option> 
            <%end%>
        </select>      
    </td>
    <td>0.00</td>
    <td><input name="new_quantity[<%=@id%>]" type="text" value="4" size="3"></td> 
    <td><input name="new_delete[<%=@id%>]" type="checkbox" value="0" onclick="if (this.checked) return confirm('Видалити елемент замовлення?')"></td>
    <input name="add_aricle[<%=@id%>]" type="hidden" value="<%=@id%>">



