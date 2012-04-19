class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.string :rmas_id
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
