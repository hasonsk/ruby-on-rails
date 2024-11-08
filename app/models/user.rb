class User < ApplicationRecord
  PERMITTED_ATTRIBUTES = [:name, :email, :password, :password_confirmation].freeze
  before_save{self.email = email.downcase}
  validates :name, presence: true, length: {maximum: Settings.default.name_user_max_length}
  validates :email, presence: true, length: {maximum: Settings.default.email_user_max_length},
                    format: {with: Rails.application.config.email_regex},
                    uniqueness: true
  validates :password, presence: true, length: {minimum: Settings.default.password_min_length}, allow_nil: true
  has_secure_password
  attr_accessor :remember_token

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def authenticated? remember_token
    return false if :remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def session_token
    remember_digest || remember
  end

  def forget
    update_attribute(:remember_digest, nil)
  end
end
