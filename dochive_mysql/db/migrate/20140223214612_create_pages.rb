class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :document_id
      t.integer :user_id
      t.integer :template_id
      t.integer :number
      t.integer :dpi
      t.integer :height
      t.integer :width
      t.integer :top
      t.integer :bottom
      t.integer :left
      t.integer :right
      t.string :path
      t.string :url
      t.string :filename
      t.boolean :exclude
      t.boolean :public

      t.timestamps
    end
  end
end
