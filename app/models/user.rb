class User < ApplicationRecord
  authenticates_with_sorcery!

  has_one :user_status, dependent: :destroy
  has_one :play_state, dependent: :destroy

  after_create :build_initial_game_states

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
  validates :reset_password_token, uniqueness: true, allow_nil: true

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

  def build_initial_game_states
    create_user_status!(
      hunger_value:    50,
      happiness_value: 10,
      love_value:      0,
      mood_value:      0,
      study_value:     0,
      sports_value:    0,
      art_value:       0,
      money:           0

    )
    first_set   = EventSet.find_by!(name: "何か言っている")
    first_event = Event.find_by!(event_set: first_set, derivation_number: 0)
    create_play_state!(
      current_event:             first_event,
      action_choices_position:   nil,
      action_results_priority:   nil,
      current_cut_position:      nil
    )
  end
end
