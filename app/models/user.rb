class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  before_save   :downcase_email
  before_create :create_activation_digest
  PERMITTED_ATTRIBUTES = [:name, :email, :password, :password_confirmation].freeze
  before_save{self.email = email.downcase}
  validates :name, presence: true, length: {maximum: Settings.default.name_user_max_length}
  validates :email, presence: true, length: {maximum: Settings.default.email_user_max_length},
                    format: {with: Rails.application.config.email_regex},
                    uniqueness: true
  validates :password, presence: true, length: {minimum: Settings.default.password_min_length}, allow_nil: true
  has_secure_password
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

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  def session_token
    remember_digest || remember
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
