class AddRmasIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :rmas_id, :string
  end
end
