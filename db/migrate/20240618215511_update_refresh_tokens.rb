class UpdateRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    remove_index :refresh_tokens, name: :index_refresh_tokens_on_encrypted_token
    remove_index :refresh_tokens, name: :index_refresh_tokens_on_encrypted_token_iv

    remove_column :refresh_tokens, :encrypted_token, :string
    remove_column :refresh_tokens, :encrypted_token_iv, :string

    add_column :refresh_tokens, :token_ciphertext, :text
    add_column :refresh_tokens, :token_bidx, :string
    add_index  :refresh_tokens, :token_bidx, unique: true
  end
end
