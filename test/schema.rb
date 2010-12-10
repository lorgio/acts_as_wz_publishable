ActiveRecord::Schema.define(:version => 0) do
  create_table :pages, :force => true do |t|
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :created_on, :datetime
    t.column :updated_on, :datetime
    t.column :publish_id, :integer
    t.column :publish_state, :string
    t.column :publish_state_at, :datetime
    t.column :deleted, :boolean, :default => false
    t.column :archived, :boolean, :default => false
    t.column :revision, :integer
  end

  create_table :page_soft_deletes, :force => true do |t|
    t.column :version, :integer
    t.column :title, :string, :limit => 255
    t.column :body, :text
    t.column :created_on, :datetime
    t.column :updated_on, :datetime
    t.column :publish_id, :integer
    t.column :publish_state, :string
    t.column :publish_state_at, :datetime
    t.column :deleted, :boolean
    t.column :archived, :boolean, :default => false
    t.column :revision, :integer
  end
end