require 'rubygems'
require 'sinatra'
require 'sqlite3'


if File.exists?("tyres.db")
    db = SQLite3::Database.new("tyres.db")
else 
    Kernel.system("sqlite3 tyres.db < db-dump.sql")
    db = SQLite3::Database.new("tyres.db")    
end    

Tyre_brand_name = db.execute("select title from TyreBrand").to_a
Tyre_family_name = db.execute("select family_title from TyreFamily").to_a
Tyre_width_name = db.execute("select distinct width from TyreModel order by width asc").to_a
Tyre_height_name = db.execute("select distinct height from TyreModel order by height asc").to_a
Tyre_diameter_name = db.execute("select distinct rim_diameter from TyreModel order by rim_diameter asc").to_a
Tyre_season = ["Зимові шини","Літні шини","Всесезоннні шини"]
Select_Array = ['Ширина', 'Висота', 'Діаметр', 'Виробник', 'Модель', 'Сезон']


get '/' do
    erb :index
end


def filter_select(select, value, check_value, text)
    if value != check_value
        select = select + text
    end  
    return select  
end

def detect_season(value)
    if value == Tyre_season[0]
        return 'W' 
    elsif value == Tyre_season[1]
        return 'S'
    elsif value == Tyre_season[2]
        return 'A'
    else 
        return Select_Array[5]    
    end 
end



get '/tyres' do
    @tyre_brand_select = params[:tyre_brand]
    @tyre_brands_check = params[:item]
    @tyre_width = params[:tyre_width]
    @tyre_height = params[:tyre_height]
    @tyre_diameter = params[:tyre_diameter]
    @tyre_family = params[:tyre_family]
    @tyre_season = params[:tyre_season]
    @detect_tyre_season = detect_season(params[:tyre_season])
    select_family = "select family_title from TyreModel,TyreFamily where TyreModel.family_id=TyreFamily.id"
    
    if @tyre_brand_select != nil and @tyre_brand_select != ""
        select_family = filter_select(select_family, @tyre_brand_select, Select_Array[3], " and TyreFamily.brand_title='" + @tyre_brand_select + "'")
        select_family = filter_select(select_family, @tyre_family, Select_Array[4], " and TyreFamily.family_title='" + @tyre_family + "'") if @tyre_family != nil and @tyre_family != ""
    end
    
    if @tyre_brands_check != nil
        i=0
        select_family =  select_family + " and ( "
        @tyre_brands_check.each do |tyre_brands_check|
            if i == 0
                select_family = filter_select(select_family, tyre_brands_check, Select_Array[3], "TyreFamily.brand_title='" + tyre_brands_check.to_s + "'")
            else
                select_family = filter_select(select_family, tyre_brands_check, Select_Array[3], " or TyreFamily.brand_title='" + tyre_brands_check.to_s + "'")
            end
            i += 1
        end
        select_family =  select_family + " ) "
    end
    
    select_family = filter_select(select_family, @tyre_width, Select_Array[0], " and TyreModel.width=" + @tyre_width) if @tyre_width != nil and @tyre_width != ""
    select_family = filter_select(select_family, @tyre_height, Select_Array[1], " and TyreModel.height=" + @tyre_height) if @tyre_height != nil and @tyre_height != ""
    select_family = filter_select(select_family, @tyre_diameter, Select_Array[2], " and TyreModel.rim_diameter=" + @tyre_diameter) if @tyre_diameter != nil and @tyre_diameter != ""

    select_family = filter_select(select_family, @detect_tyre_season, Select_Array[5], " and TyreFamily.season='" + @detect_tyre_season + "'") if @detect_tyre_season != nil and @detect_tyre_season != ""
    
    @xxx = select_family

    select_family_titles = db.execute(select_family).to_a.uniq
    
    @select_brand_titles = {}
    select_family_titles.each do |select_family_title|
        select_brand = "select brand_title from TyreFamily where family_title='" + select_family_title.to_s + "'"
        @select_brand_titles[select_family_title] = (db.execute(select_brand))
    end  
    erb :tyres
end

get '/delivery' do
    erb :delivery
end

get '/models' do
    tyre_brand = params[:tyre_brand]
    select = "select family_title from TyreFamily where brand_title='" + tyre_brand.to_s + "'" 
    @families = db.execute(select).to_a
    erb :models
end

get '/:href_tyre_brand/family/:href_tyre_family' do
    @tyre_brand = params[:tyre_brand]
    @tyre_family = params[:tyre_family]
    select_description = "select description from TyreFamily where brand_title='" + @tyre_brand.to_s + "' and family_title='" + @tyre_family.to_s + "'"
    @description = db.execute(select_description)
    
    select_family_id = "select TyreFamily.id from TyreFamily where brand_title='" + @tyre_brand.to_s + "' and family_title='" + @tyre_family.to_s + "'"
    
    select_image = "select TyreFamily.image from TyreFamily where brand_title='" + @tyre_brand.to_s + "' and family_title='" + @tyre_family.to_s + "'"
    @family_image = db.execute(select_image)

    select_canonical_size = "select TyreModel.canonical_size from TyreModel where TyreModel.family_id=(" + select_family_id + ")"
    canonical_size_array = db.execute(select_canonical_size).to_a

    @article = {}
    canonical_size_array.each do |canonical_size|
        select_model_id = "select TyreModel.id from TyreModel where canonical_size='" + canonical_size.to_s + "' and family_id=(" + select_family_id +")"
        select_price = "select max(TyreArticle.price) from TyreArticle where TyreArticle.model_id=(" + select_model_id + ")"
        select_quantity = "select TyreArticle.quantity from TyreArticle where TyreArticle.model_id=(" + select_model_id + ") and TyreArticle.price=(" + select_price + ")"
        @article[canonical_size] = [db.execute(select_price),db.execute(select_quantity)]
    end
    
    erb :family
end



__END__

@@ index
<html>
    <head>
        <title>Main</title>
        <meta charset="utf-8" />
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
        <ul>
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
                <%Tyre_season.each do |tyre_season|%>  
                    <option value="<%=tyre_season%>"><%=tyre_season%></option>  
                <%end%>
            </select>
            <br>
            
            <input type="submit" value="Пошук"/> 
        </form>        
    </body>
</html>



@@ tyres
<html>
    <head>
        <title>Tyres</title>
        <meta charset="utf-8" />
    </head>
    <body>
    
        <form method="GET" action="tyres"> 
        
           <ul>Виробники 
            
            <%if @tyre_brand_select != nil %>
                <%check_value = false%>
                <%Tyre_brand_name.each do |tyre_brand_name|%>
                    <%if @tyre_brand_select.to_s == tyre_brand_name.to_s%>
                        <%check_value = true%>   
                    <%elsif @tyre_brand_select.to_s == ""%>
                        <%check_value = true%>
                    <%else%> 
                        <%check_value = false%>   
                    <%end%>
                    <%if check_value%> 
                        <li><input type="checkbox" name="item[]" value="<%=tyre_brand_name%>" checked><%=tyre_brand_name%></li>   
                    <%else%>
                        <li><input type="checkbox" name="item[]" value="<%=tyre_brand_name%>" ><%=tyre_brand_name%></li>
                    <%end%>    
                <%end%>
            <%else%>
                <%Tyre_brand_name.each do |tyre_brand_name|%>
                    <%check_value = false%>
                    <%if @tyre_brands_check != nil%>
                        <%if @tyre_brands_check.include?(tyre_brand_name.to_s)%>
                            <%check_value = true%>
                        <%else%> 
                            <%check_value = false%>   
                        <%end%>
                    <%else%>
                        <%check_value = false%> 
                    <%end%>
                    <%if check_value%> 
                        <li><input type="checkbox" name="item[]" value="<%=tyre_brand_name%>" checked><%=tyre_brand_name%></li>   
                    <%else%>
                        <li><input type="checkbox" name="item[]" value="<%=tyre_brand_name%>" ><%=tyre_brand_name%></li>
                    <%end%>     
                <%end%>
            <%end%>
            
            </ul> 
            <p><%=@xxx%></p>          
            <select name="tyre_width">
                <option value="">Ширина</option>
                <%Tyre_width_name.each do |tyre_width_name|%>
                    <%if @tyre_width.to_s == tyre_width_name.to_s%>
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
                    <%if @tyre_height.to_s == tyre_height_name.to_s%>
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
                    <%if @tyre_diameter.to_s == tyre_diameter_name.to_s%>
                        <option value="<%=tyre_diameter_name%>" selected><%=tyre_diameter_name%></option>   
                    <%else%>    
                        <option value="<%=tyre_diameter_name%>"><%=tyre_diameter_name%></option>  
                    <%end%> 
                <%end%>    
            </select> 

            <select name="tyre_season">
                <option value="">Сезон</option>
                <%Tyre_season.each do |tyre_season|%>
                    <%if @tyre_season.to_s == tyre_season.to_s%>
                        <option value="<%=tyre_season%>" selected><%=tyre_season%></option>   
                    <%else%>    
                        <option value="<%=tyre_season%>"><%=tyre_season%></option>  
                    <%end%> 
               <%end%>
            </select>
            <input type="submit" value="Пошук"/> 
            
            <%if @select_brand_titles.empty?%>
                <p>Нічого не знайдено</p>
            <%else%>      
                <%@select_brand_titles.sort{|a,b| a[1]<=>b[1]}.each do |family_title,brand_title|%>
                    <%href_brand_title = brand_title.to_s.gsub(/\s/,'_')%>
                    <%href_family_title = family_title.to_s.gsub(/\s/,'_').gsub(/\//,'-')%>
                    <li><a href="<%=href_brand_title%>/family/<%=href_family_title%>?tyre_brand=<%=brand_title%>&tyre_family=<%=family_title%>&href_tyre_brand=<%=href_brand_title%>&href_tyre_family=<%=href_family_title%>"><%=brand_title%> - <%=family_title%></a></li>   
                <%end%> 
            <%end%> 
              
        </form>        
    </body>
</html>

@@ delivery
<html>
    <head>
        <title>Delivery</title>
        <meta charset="utf-8" />
    </head>
    <body>
         
    </body>
</html>


@@ models

<option value="" selected>Модель</option>
<%if @families.empty? %>
    <%Tyre_family_name.each do |tyre_family_name|%>
        <option value="<%=tyre_family_name%>"><%=tyre_family_name%></option> 
    <%end%>
<%else%>    
    <%@families.each do |family|%>
        <option value="<%=family%>"><%=family%></option>   
    <%end%>
<%end%>


@@ family
<html>
    <head>
        <title><%=@tyre_brand%>/<%=@tyre_family%></title>
        <meta charset="utf-8" />
    </head>
    <body>
    <%=@tyre_brand%>/<%=@tyre_family%>
    <p>Опис:<br><%=@description%></p>
    <img src="http://localhost:4567/Images/<%=@family_image%>">
    <ul>Моделі:<br>
        <%@article.each do |key,value|%>
            <li><%=key%> Ціна моделі: <%=value[0]%> грн. Кількість: <%=value[1]%> </li>
        <%end%>
    </ul>    
    </body>
</html>



