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
Tyre_family_name = db.execute("select family_title from TyreFamily").flatten
Tyre_width_name = db.execute("select distinct width from TyreModel order by width asc").flatten
Tyre_height_name = db.execute("select distinct height from TyreModel order by height asc").flatten
Tyre_diameter_name = db.execute("select distinct rim_diameter from TyreModel order by rim_diameter asc").flatten
Tyre_season = { "W" => "Зимові шини", "S" => "Літні шини", "A" => "Всесезоннні шини"}
Select_Array = ['Ширина', 'Висота', 'Діаметр', 'Виробник', 'Модель', 'Сезон']
Tyre_quantity = 4


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
    p @tyre_width = params[:tyre_width]
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
            article_quantity = params[("article-" + key.to_s).to_sym]
            delete_article = params[("delete-" + key.to_s).to_sym]
            article_price_quantity = article[3].to_f * article_quantity.to_i
            session[key] = [article[0],article[1],article[2],article[3],article_quantity,article_price_quantity]
            session.delete(key) if delete_article == key
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
    </head>
    <body>
        <form name="cart_form" method="GET" action="">
            <input name="form" type="hidden" value="cart_form">
            <%session.sort{|a,b| a[1]<=>b[1]}.each do |key,article|%>
                <p>
                    Товар <%=article[0]%> - <%=article[1]%> - <%=article[2]%> Ціна: <%=article[3]%>  
                    Кількість: <input name="article-<%=key%>" type="text" value="<%=article[4]%>"> Всьго: <%=article[5]%> 
                    <input name="delete-<%=key%>" type="checkbox" value="<%=key%>">Видалити     
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
        <form name="order" method="GET" action="">
            <p><b>Оформити замовлення</b></p>
            <p>Ім'я</p><input name="customer_name" type="text" required>
            <p>Прізвище</p><input name="customer_surname" type="text" required>
            <p>Адреса</p><input name="customer_address" type="text" required>
            <p>Електронна адреса</p><input name="customer_email" type="text" required>
            <p>Телефон</p><input name="customer_telephone" type="text" required>
            <p><a href="shopping_cart">Повернутися до кошика</a>
            <input type="submit" value="Замовити"></p>
        </form>
    </body>
</html>
