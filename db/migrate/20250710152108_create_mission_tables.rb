class CreateMissionTables < ActiveRecord::Migration[7.2]
  def change
    create_table :discord_users do |t|
      t.string :discord_uid
      t.string :username
      t.string :global_username
      t.string :display_name
      t.timestamps
    end

    create_table :wiki_users do |t|
      t.string :username
      t.belongs_to :discord_user, index: true
      t.timestamps
    end

    create_enum :mission_status, %w[active accepted submitted completed]
    create_enum :mission_priority, %w[low medium high]
    create_enum :mission_type, %w[page_create page_update image_upload page_translate]

    create_table :missions do |t|
      t.string :title
      t.text :description
      t.string :wiki_page
      t.string :language
      t.string :map_link
      t.string :discord_post_link
      t.string :discord_post_uid
      t.belongs_to :issuer, foreign_key: { to_table: :discord_users }, index: true, null: false
      t.belongs_to :assignee, foreign_key: { to_table: :discord_users }, index: true
      t.enum :status, enum_type: :mission_status, default: 'active', null: false
      t.enum :type, enum_type: :mission_type, default: 'page_create', null: false
      t.enum :priority, enum_type: :mission_priority, default: 'low', null: false
      t.datetime :completed_at
      t.timestamps
    end
  end
end
