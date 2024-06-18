class RenameTokenToEncryptedTokenInRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    rename_column :refresh_tokens, :token, :encrypted_token
  end
end
