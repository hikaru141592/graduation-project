class User < ApplicationRecord
  authenticates_with_sorcery!

  before_validation :assign_friend_code, if: -> { new_record? && friend_code.blank? }

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, confirmation: true,
                       if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true,
                                    if: -> { new_record? || changes[:crypted_password] }
  validates :name,      presence: true, length: { maximum: 6 }
  validates :egg_name,  presence: true, length: { maximum: 6 }
  validates :birth_month, presence: true, inclusion: { in: 1..12 }
  validates :birth_day,   presence: true, inclusion: { in: 1..31 }
  validates :friend_code, presence: true, uniqueness: true, format: { with: /\A\d{8}\z/ }

  validates :line_account,
            uniqueness: true,
            allow_nil:  true

  enum :role, { general: 0, admin: 1 }

  private
  def assign_friend_code
    loop do
      self.friend_code = rand(10**8).to_s.rjust(8, "0")
      break unless User.exists?(friend_code: friend_code)
    end
  end
end
