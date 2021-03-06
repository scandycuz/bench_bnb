class User < ActiveRecord::Base

  attr_reader :password

  after_initialize :ensure_token

  validates :password_digest, presence: true
  validates :username, :session_token, presence: true, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }

  def self.find_by_credentials(username, password)
    user = User.find_by_username(username)

    return nil if user.nil?
    user.is_password?(password) ? user : nil
  end

  def self.generate_token
    SecureRandom.urlsafe_base64
  end

  def ensure_token
    self.session_token ||= User.generate_token
  end

  def reset_token!
    self.session_token = User.generate_token
    self.save
    self.session_token
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password);
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end
end
