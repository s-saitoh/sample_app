class User < ActiveRecord::Base
  before_save { self.email = email.downcase } #メールアドレスをDB保存前に小文字変換
  validates :name, presence: true, length: { maximum: 50 }
  # メールアドレスを示す正規表現
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX } , # メールアドレスのフォーマット検証
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
