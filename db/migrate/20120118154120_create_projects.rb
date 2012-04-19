class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :status
      t.references :proposal

      t.timestamps
    end
  end
end
