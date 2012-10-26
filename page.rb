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
    
    if @tyre_brand_select != nil 
        select_family = filter_select(select_family, @tyre_brand_select, Select_Array[3], " and TyreFamily.brand_title='" + @tyre_brand_select + "'")
        select_family = filter_select(select_family, @tyre_family, Select_Array[4], " and TyreFamily.family_title='" + @tyre_family + "'")
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
    
    select_family = filter_select(select_family, @tyre_width, Select_Array[0], " and TyreModel.width=" + @tyre_width) if @tyre_width != nil
    select_family = filter_select(select_family, @tyre_height, Select_Array[1], " and TyreModel.height=" + @tyre_height) if @tyre_height != nil
    select_family = filter_select(select_family, @tyre_diameter, Select_Array[2], " and TyreModel.rim_diameter=" + @tyre_diameter) if @tyre_diameter != nil

    select_family = filter_select(select_family, @detect_tyre_season, Select_Array[5], " and TyreFamily.season='" + @detect_tyre_season + "'") if @detect_tyre_season != nil
    
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
            <li><a href="/tyres">Шини</a></li>
            <li>Диски</li>
            <li><a href="/delivery">Доставка</a></li>
        <ul>
        <form name="myform" method="GET" action="tyres">
            <select name="tyre_width">
                <option value="Ширина">Ширина</option>
                <%Tyre_width_name.each do |tyre_width_name|%>  
                    <option><%=tyre_width_name%></option>  
                <%end%>   
            </select>
            <b>/</b>
            <select name="tyre_height">
                <option value="Висота">Висота</option>
                <%Tyre_height_name.each do |tyre_height_name|%>
                    <option><%=tyre_height_name%></option>  
                <%end%>   
            </select>
            <b>R</b>
            <select name="tyre_diameter" value="Діаметр">
                <option>Діаметр</option>
                <%Tyre_diameter_name.each do |tyre_diameter_name|%> 
                    <option><%=tyre_diameter_name%></option>  
                <%end%>   
            </select> 
            <br>

            <select name="tyre_brand" onChange="change_families()">
                <option value="Виробник">Виробник</option>
                <%Tyre_brand_name.each do |tyre_brand_name|%>    
                    <option><%=tyre_brand_name%></option>  
                <%end%>
            </select>
             
            <select name="tyre_family">
                <option value="Модель" selected>Модель</option>
                <%Tyre_family_name.each do |tyre_family_name|%>
                    <option><%=tyre_family_name%></option> 
                <%end%>
            </select> 
            <br>
            <select name="tyre_season">
                <option value="Сезон">Сезон</option>
                <%Tyre_season.each do |tyre_season|%>  
                    <option><%=tyre_season%></option>  
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
                    <%elsif @tyre_brand_select.to_s == 'Виробник'%>
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
                <option value="Ширина">Ширина</option>
                <%Tyre_width_name.each do |tyre_width_name|%>
                    <%if @tyre_width.to_s == tyre_width_name.to_s%>
                        <option selected><%=tyre_width_name%></option>   
                     <%else%>    
                        <option><%=tyre_width_name%></option>  
                    <%end%>
                <%end%>     
            </select>
            <b>/</b>
            <select name="tyre_height">
                <option value="Висота">Висота</option>
                <%Tyre_height_name.each do |tyre_height_name|%>
                    <%if @tyre_height.to_s == tyre_height_name.to_s%>
                        <option selected><%=tyre_height_name%></option>   
                    <%else%>    
                        <option><%=tyre_height_name%></option>  
                    <%end%> 
                <%end%>    
            </select>
            <b>R</b>
            <select name="tyre_diameter">
                <option value="Діаметр">Діаметр</option>
                <%Tyre_diameter_name.each do |tyre_diameter_name|%>
                    <%if @tyre_diameter.to_s == tyre_diameter_name.to_s%>
                        <option selected><%=tyre_diameter_name%></option>   
                    <%else%>    
                        <option><%=tyre_diameter_name%></option>  
                    <%end%> 
                <%end%>    
            </select> 

            <select name="tyre_season">
                <option value="Сезон">Сезон</option>
                <%Tyre_season.each do |tyre_season|%>
                    <%if @tyre_season.to_s == tyre_season.to_s%>
                        <option selected><%=tyre_season%></option>   
                    <%else%>    
                        <option><%=tyre_season%></option>  
                    <%end%> 
               <%end%>
            </select>
            <input type="submit" value="Пошук"/> 
            
            <%if @select_brand_titles.empty?%>
                <p>Нічого не знайдено</p>
            <%else%>      
                <%@select_brand_titles.sort{|a,b| a[1]<=>b[1]}.each do |family_title,brand_title|%>
                    <li><%=brand_title%> - <%=family_title%></li>   
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

<option value="Модель" selected>Модель</option>
<%if @families.empty? %>
    <%Tyre_family_name.each do |tyre_family_name|%>
        <option><%=tyre_family_name%></option> 
    <%end%>
<%else%>    
    <%@families.each do |family|%>
        <option><%=family%></option>   
    <%end%>
<%end%>



