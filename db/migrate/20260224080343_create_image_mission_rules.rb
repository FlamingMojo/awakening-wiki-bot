class CreateImageMissionRules < ActiveRecord::Migration[7.2]
  def change
    create_table :image_rules do |t|
      t.string :name
      t.integer :min_width
      t.integer :min_height
      t.integer :max_width
      t.integer :max_height
      t.float :ratio
      t.string :format
      t.timestamps
    end

    create_table :image_mission_rules do |t|
      t.belongs_to :image_rule
      t.belongs_to :mission
      t.timestamps
    end
  end
end
