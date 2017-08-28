
pic = Picture.new(:name => "Hope it works")
pic.user = User.first
image_src = File.join(Rails.root, "app/assets/images/20170405_181345.jpg")
src_file = File.new(image_src)
pic.image = src_file
pic.save