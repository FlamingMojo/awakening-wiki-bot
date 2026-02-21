class CreateRewards < ActiveRecord::Migration[7.2]
  def change
    create_table :reward_types do |t|
      t.integer :reward_key, null: false, default: 0
      t.string :name, null: false
      t.boolean :active, default: true
      t.integer :threshold
      t.integer :threshold_type, default: 0, null: false
      t.timestamps
    end

    create_table :rewards do |t|
      t.belongs_to :reward_type, null: false, index: true
      t.belongs_to :user_reward
      t.text :encrypted_key, null: false
      t.timestamps
    end

    create_table :user_rewards do |t|
      t.integer :status, null: false, default: 0
      t.integer :issue_type, null: false, default: 0
      t.belongs_to :discord_user, null: false, index: true
      t.belongs_to :reward, null: false, index: true
      t.belongs_to :issuer, foreign_key: { to_table: :discord_users }, index: true
      t.string :discord_uid, null: false
      t.string :comment
      t.datetime :issued_at, null: false
      t.timestamps
    end
  end
end
