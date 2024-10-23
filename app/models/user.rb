class User < ApplicationRecord
  before_save{self.email = email.downcase}
  validates :name, presence: true, length: {maximum: Settings.default.name_user_max_length}
  validates :email, presence: true, length: {maximum: Settings.default.email_user_max_length},
                    format: {with: Rails.application.config.email_regex },
                    uniqueness: true
  validates :password, presence: true, length: {minimum: 6}
  has_secure_password
end
