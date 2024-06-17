class CreateRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :refresh_tokens do |t|
      t.string :token, null: false
      t.boolean :revoked, null: false, default: false
      t.datetime :expires_at, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :refresh_tokens, :token, unique: true
    add_index :refresh_tokens, :expires_at
    add_index :refresh_tokens, :revoked
  end
end
