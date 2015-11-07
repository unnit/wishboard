# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

cat_names = ["BIKES & TWO WHEELERS", "ADVENTURE | SPORTS | TRAVEL GEAR", "BOOKS | CDs | HOBBIES", "ELECTRONICS", "HOME & OFFICE", "FASHION | RENT A DRESS",
"CHILD & OLD AGE CARE", "LAST MINUTE TICKETS", "PARTIES & CELEBRATIONS", "TOOLS | MACHINES", "VACATION HOMES| HOME STAYS", "VEHICLES & ACCESSORIES",
"SKILLS & SERVICES", "TRIALS & TEST DRIVES"]
sub_categories = {"BIKES & TWO WHEELERS" => ["Cycles", "Scooters", "100-124 CC Bikes", "125-150 CC Bikes", "151-180 CC Bikes", "Bullets | Cruise | Super Bikes", "Accessories | Helmets | Saddle Bags"],
  "ADVENTURE | SPORTS | TRAVEL GEAR" => ["Sports | Gym & Fitness", "BOOKS | CDs | HOBBIES", "Boots | Jackets", "Sleeping Bags | Mats | Tents", "Surfing | Skating | Fishing Equipments", "Everything Else"],
  "BOOKS | CDs | HOBBIES" => ["Books | Magazines", "CD/DVDs | Digital Media", "Carrom | Chess | Board Games", "Musical Instruments", "Video Games | Consoles", "Pets | Pet Care", "Everything Else"],
  "ELECTRONICS" => ["3D Printers | Drones | Google Glass | IoT", "Cameras & Accessories", "Computers | Laptops & Accessories", "Mobiles | Tabs", "Music & Audio Solutions"],
  "HOME & OFFICE" => ["Furniture", "Fridge | AC & Kitchen Appliances", "Art | Antiques | Handicrafts", "Mattresses | Cushions | Bean Bags", "Decor & Furnishing", "Everything Else"],
  "FASHION | RENT A DRESS" => ["Fancy Dress | Dance | Convocations", "Kids Wear & Accessories", "Women's Clothing", "Women's Footwear | Accessories", "Imitation | Jewelery | Make Over", "Men's Clothing", "Men's Footwear | Accessories", "Everything Else"],
  "CHILD & OLD AGE CARE" => ["Elders & Old Age Care", "Toys | Furniture | Games", "Cradles | Strolleys | Accessories", "Everything Else"],
  "LAST MINUTE TICKETS" => ["Cinema | Concerts | Drama", "Gift Vouchers | Coupons", "Everything Else"],
  "PARTIES & CELEBRATIONS" => ["Barbeque Grills | Cookware | Ovens", "Cutlery | Drinkware | Serveware", "Shamiyanas | Decorations | Tableskirts", "Religious | Cultural", "Everything Else"], 
  "TOOLS | MACHINES" => ["Garden | Farming", "Drills | Electric | Carpentry Tools", "Ladders | Vacuum Cleaners | Sewing Machines", "Trolleys | Painting | Plumbing | Construction", "Everything Else"],
  "VACATION HOMES| HOME STAYS" => ["House Boats | Yachts", "Vacation Homes | Guest House | Home Stay", "Heritage Homes | Tree Houses", "Room Sharing", "Everything Else"],
  "VEHICLES & ACCESSORIES" => ["Cars | Four Wheelers", "Accessories", "Commercial Vehicles", "Aircrafts | Boats", "Racing | Off Road", "Everything Else"],
  "SKILLS & SERVICES" => ["Tuitions | Coaching| Training", "Electronics | Computer Repair", "Maids & Domestic Help", "Movers & Packers", "Everything Else"], 
  "TRIALS & TEST DRIVES" => ["Cycles", "Bikes", "Four Wheeler"]
}

cat_names.each do |name|
  puts "Create #{name}"
  if category = Category.find_or_create_by(name: name)
    subs = sub_categories[name]
    subs.each do |sub|
      puts "......Create #{name} subs .... #{sub}"
      Category.find_or_create_by(name: sub, parent_id: category.id)
    end
  end
end

c = Category.find_by_name "ELECTRONICS"
c.update_columns feature_pos: 1, image: "icons/Electronics.png"

c = Category.find_by_name "CHILD & OLD AGE CARE"
c.update_columns feature_pos: 2, image: "icons/Children.png"

c = Category.find_by_name "BIKES & TWO WHEELERS"
c.update_columns feature_pos: 1, image: "icons/Vehicle.png"


u = User.find_or_create_by(email: "admin@cocociti.com")
u.password = '1234qwer'
u.role = 'admin'
u.save
