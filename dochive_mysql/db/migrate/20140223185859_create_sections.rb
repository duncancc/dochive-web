class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :template_id
      t.string :name
      t.integer :yOrigin
      t.integer :xOrigin
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
