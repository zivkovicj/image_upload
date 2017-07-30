class CreateLabelPictures < ActiveRecord::Migration[5.0]
  def change
    create_table :label_pictures, id: false do |t|
      t.integer   :label_id
      t.integer    :picture_id
      t.timestamps
    end
    
    add_index   :label_pictures, [:label_id, :picture_id]
  end
end
