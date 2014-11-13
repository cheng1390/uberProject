class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :text
      t.string :subject
      t.string :send_to
      t.string :send_from

      t.timestamps
    end
  end
end
