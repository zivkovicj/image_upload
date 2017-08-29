# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Admin
Admin.create!(first_name:  "Jeff",
             last_name:   "Zivkovic",
             title: "Mr.",
             email: "zivkovic.jeff@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             user_number: 1,
             activated: true,
             activated_at: Time.zone.now)
             
jeff = Admin.first

Admin.create!(first_name:  "Second",
             last_name:   "InCommand",
             title: "Mr.",
             email: "noobsauce@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             user_number: 2,
             activated: true,
             activated_at: Time.zone.now)
 
Admin.create!(first_name:  "Business",
             last_name:   "Partner",
             title: "Mrs.",
             email: "businesspartner@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             user_number: 3,
             activated: true,
             activated_at: Time.zone.now)
             
Admin.create!(first_name:  "Last",
             last_name:   "Admin",
             title: "Ms.",
             email: "lastadmin@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             user_number: 4,
             activated: true,
             activated_at: Time.zone.now)

title_array = ["Mrs.", "Mr.", "Miss", "Ms.", "Dr."]

# Teachers
9.times do |n|
  first_name  = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  which_title = rand(title_array.length)
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  Teacher.create!(first_name:  first_name,
               last_name:   last_name,
               email: email,
               title: title_array[which_title],
               password:              password,
               password_confirmation: password,
               user_number: n,
               activated: true,
               activated_at: Time.zone.now)
end

# Seminars
Seminar.create!(name: "1st Period",
                user_id: 5,
                consultantThreshold: 7)
Seminar.create!(name: "2nd Period",
                user_id: 5,
                consultantThreshold: 7)
Seminar.create!(name: "Another Teacher, First  Period",
                user_id: 6,
                consultantThreshold: 7)
                
# objectives

assignNameArray = [[1,"Add and Subtract Numbers"],[1,"Multiply and Divide Numbers"],
    [1,"Numbers Summary"],
    [1,"Intercept"], [1,"Slope"], [1,"Scatterplots"], [1,"Association"],
    [1,"One-step Equations"], [2,"Integers"], [2,"Volume"], [2,"Fractions"], [2,"Rationals"], 
    [2,"Irrationals"], [3,"Volcanos"], [3,"Evolution"], [3,"Taxonomy"], [3,"Cells"], [3,"Anatomy"]]
    
assignNameArray.each_with_index do |objective, index|
    @objective = Objective.create(name: objective[1], :user => jeff, :extent => "public")
    ObjectiveSeminar.create(:seminar_id => objective[0], :objective => @objective, :priority => 2, :pretest => 0)
end


# Students       
29.times do |n|
  first_name  = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email = "example-#{n+20}@railstutorial.org"
  password = "password"
  @student = Student.create!(first_name:  first_name,
               last_name:   last_name,
               email: email,
               user_number: n,
               password: password)
   SeminarStudent.create!(seminar_id: 1, user_id: @student.id)
end

# Some students are registered to two class periods
SeminarStudent.create!(seminar_id: 2, user_id: 17)
SeminarStudent.create!(seminar_id: 2, user_id: 18)

18.times do |n|
  first_name  = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email = "example-#{n+50}@railstutorial.org"
  password = "password"
  @student = Student.create!(first_name:  first_name,
               last_name:   last_name,
               email: email,
               user_number: n,
               password: password)
   SeminarStudent.create!(seminar_id: 2, user_id: @student.id)
end

36.times do |n|
  first_name  = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email = "example-#{n+100}@railstutorial.org"
  password = "password"
  @student = Student.create!(first_name:  first_name,
               last_name:   last_name,
               email: email,
               user_number: n,
               password: password)
   SeminarStudent.create!(seminar_id: 3, user_id: @student.id)
end

Student.all.each do |student|
    student.update(:user_number => student.id)
    student.update(:username => "#{student.first_name[0,1].downcase}#{student.last_name[0,1].downcase}#{student.id}")
    student.update(:password => "#{student.id}")
end

# Scores
skillMatrix = [[0,0,0,0,5,7],[0,0,5,5,7,10],[0,5,7,10,10,10]]
Student.all.each do |student|
    skill = rand(3)
    student.seminar_students.each do |ss|
        seminar = ss.seminar
        seminar.objectives.each do |obj|
            scooby = rand(6)
            doo = skillMatrix[skill][scooby]
            ss.update(pref_request: skill)
            student.objective_students.create!(objective: obj, points: doo)
        end
    end
end

Label.create(:name => "Label for Pictures", :extent => "public", :user => jeff)
Label.create(:name => "Other Label for Pictures", :extent => "public", :user => jeff)

add_label = Label.create(:name => "Adding Numbers", :extent => "public", :user => jeff)
subtract_label = Label.create(:name => "Subtracting Numbers", :extent => "public", :user => jeff)
multiply_label = Label.create(:name => "Multiplying Numbers", :extent => "public", :user => jeff)
divide_label = Label.create(:name => "Dividing Numbers", :extent => "public", :user => jeff)

teacher_user = Teacher.first
Label.create(:name => "Intercept from Graphs", :extent => "public", :user => teacher_user)
Label.create(:name => "Intercept from Equations", :extent => "public", :user => teacher_user)
Label.create(:name => "Intercept from Tables", :extent => "public", :user => teacher_user)

add_and_sub_obj = Objective.find_by(:name => "Add and Subtract Numbers")
mult_and_div_obj = Objective.find_by(:name => "Multiply and Divide Numbers")
sum_obj = Objective.find_by(:name => "Numbers Summary")

LabelObjective.create(:label => add_label, :objective => add_and_sub_obj,
    :quantity => 2, :point_value => 2)
LabelObjective.create(:label => subtract_label, :objective => add_and_sub_obj,
    :quantity => 3, :point_value => 1)
    
LabelObjective.create(:label => multiply_label, :objective => mult_and_div_obj,
    :quantity => 3, :point_value => 2)
LabelObjective.create(:label => divide_label, :objective => mult_and_div_obj,
    :quantity => 2, :point_value => 2)
    
LabelObjective.create(:label => add_label, :objective => sum_obj,
    :quantity => 2, :point_value => 1)
LabelObjective.create(:label => subtract_label, :objective => sum_obj,
    :quantity => 1, :point_value => 2)
LabelObjective.create(:label => multiply_label, :objective => sum_obj,
    :quantity => 2, :point_value => 3)
LabelObjective.create(:label => divide_label, :objective => sum_obj,
    :quantity => 1, :point_value => 4)

pic_array = [["Labels", "app/assets/images/labels.png"],
    ["Objectives", "app/assets/images/objectives.png"],
    ["Desk Consultants", "app/assets/images/desk_consult.png"],
    ["Fraction 1", "app/assets/images/fraction_1.png"], 
    ["Fraction 2", "app/assets/images/fraction_2.png"],
    ["Fraction 3", "app/assets/images/fraction_3.png"],
    ["Fraction 4", "app/assets/images/fraction_4.png"],
    ["Fraction 5", "app/assets/images/fraction_5.png"],
    ["Grid 01", "app/assets/images/Grids_1.png"],
    ["Grid 02", "app/assets/images/Grids_2.png"],
    ["Grid 03", "app/assets/images/Grids_3.png"],
    ["Grid 04", "app/assets/images/Grids_4.png"],
    ["Grid 05", "app/assets/images/Grids_5.png"],
    ["Grid 06", "app/assets/images/Grids_6.png"],
    ["Grid 07", "app/assets/images/Grids_7.png"],
    ["Grid 08", "app/assets/images/Grids_8.png"],
    ["Grid 09", "app/assets/images/Grids_9.png"],
    ["Grid 10", "app/assets/images/Grids_10.png"],
    ["Grid 11", "app/assets/images/Grids_11.png"],
    ["Grid 12", "app/assets/images/Grids_12.png"],
    ["Grid 13", "app/assets/images/Grids_13.png"],
    ["Money Bags 1", "app/assets/images/money_bags_1.png"],
    ["Money Bags 2", "app/assets/images/money_bags_2.png"],
    ["Money Bags 3", "app/assets/images/money_bags_3.png"],
    ["Money Bags 4", "app/assets/images/money_bags_4.png"],
    ["Money Bags 5", "app/assets/images/money_bags_5.png"],
    ["Money Bags 6", "app/assets/images/money_bags_6.png"]]

pic_array.each do |n|
    pic = Picture.new(:name => n[0], :user => User.first)
    image_src = File.join(Rails.root, n[1])
    src_file = File.new(image_src)
    pic.image = src_file
    pic.save
end

Label.first.pictures << Picture.first
Label.first.pictures << Picture.second
Label.second.pictures << Picture.third

(1..10).each do |n|
    question = Question.new(:user => jeff, :extent => "public", :style => "multiple-choice")
    r = rand(10 * n)
    s = rand(6 * n)
    prompt_string = "What is #{r} + #{s} ?"
    question.prompt = prompt_string
    question.choice_0 = r + s
    question.choice_1 = r + s + 1
    question.choice_2 = r + s - 1
    question.choice_3 = r - s
    question.correct_answers = ["#{r + s}"]
    question.label = add_label
    question.save
    
    question = Question.new(:user => jeff, :extent => "public", :style => "multiple-choice")    
    r = rand(9 * n)
    s = rand(5 * n)
    prompt_string = "What is #{r} - #{s} ?"
    question.prompt = prompt_string
    question.choice_0 = r - s
    question.choice_1 = r + 1 - s
    question.choice_2 = (r - 1) - s 
    question.choice_3 = r + s
    question.correct_answers = ["#{r - s}"]
    question.label = subtract_label
    question.save
    
    question = Question.new(:user => jeff, :extent => "public", :style => "multiple-choice")
    r = rand(12)
    prompt_string = "What is #{n} x #{r} ?"
    question.prompt = prompt_string
    question.choice_0 = n * r
    question.choice_1 = n * (r + 1)
    question.choice_2 = n * (r - 1) 
    question.choice_3 = n * r
    question.choice_4 = (n - 1) * r
    question.correct_answers = ["#{(n) * r}"]
    question.label = multiply_label
    question.save
    
    question = Question.new(:user => jeff, :extent => "public", :style => "multiple-choice")
    r = rand(12)
    prompt_string = "What is #{n * r} / #{n} ?"
    question.prompt = prompt_string
    question.choice_0 = r
    question.choice_1 = r + 1
    question.choice_2 = r - 1
    question.choice_3 = r - 2
    question.choice_4 = 2 * r
    question.correct_answers = ["#{r}"]
    question.label = divide_label
    question.save
    
    question = Question.new(:user => jeff, :extent => "public", :style => "fill-in")
    r = rand(10 * n)
    s = rand(6 * n)
    prompt_string = "What is #{r} + #{s} ?"
    question.prompt = prompt_string
    question.correct_answers = ["#{r + s}"]
    question.label = add_label
    question.save
end

Precondition.create(:preassign => Objective.first, :mainassign => Objective.second)

c1 = Seminar.first.consultancies.create()
t1 = c1.teams.create(:consultant => Student.all[0])
t1.users << Student.all[1]
t1.users << Student.all[2]
t1.users << Student.all[3]
t2 = c1.teams.create(:consultant => Student.all[4])
t2.users << Student.all[5]
t2.users << Student.all[6]
t2.users << Student.all[7]

    
    