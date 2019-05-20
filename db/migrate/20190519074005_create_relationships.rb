class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    #↑高速化の為
    add_index :relationships, [:follower_id, :followed_id], unique: true
    #一意性を担保する為
  end
end
