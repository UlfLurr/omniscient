class AddActivatedToActivations < ActiveRecord::Migration
  def change
  	add_column :account_activations, :activated, :boolean, default: false  
  end
end
