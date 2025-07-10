class User < ApplicationRecord
  authenticates_with_sorcery!

  has_one :user_status, dependent: :destroy
  has_one :play_state, dependent: :destroy
  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications
  has_many :user_event_category_invalidations, dependent: :destroy
  has_one :event_temporary_datum, dependent: :destroy
  has_many :daily_limit_event_set_counts, dependent: :destroy
  has_many :counted_event_sets, through: :daily_limit_event_set_counts, source: :event_set

  after_create :build_initial_game_states

  before_validation :assign_friend_code, if: -> { new_record? && friend_code.blank? }
  # before_validation :truncate_name_to_6_chars, if: -> { name_changed? && name.present? }

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, confirmation: true,
            if: -> { authentications.empty? && (new_record? || changes[:crypted_password]) }
  validates :password_confirmation, presence: true,
            if: -> { authentications.empty? && (new_record? || changes[:crypted_password]) }
  validates :name,      presence: true, length: { maximum: 6 }
  validates :egg_name,  presence: true, length: { maximum: 6 }, exclusion: { in: [ "未登録" ], message: "には「未登録」という文字列を使用できません" }
  validates :birth_month, presence: true, inclusion: { in: 1..12 }
  validates :birth_day,   presence: true, inclusion: { in: 1..31 }
  validates :friend_code, presence: true, uniqueness: true, format: { with: /\A\d{8}\z/ }
  validates :reset_password_token, uniqueness: true, allow_nil: true

  validates :line_account,
            uniqueness: true,
            allow_nil:  true

  enum :role, { general: 0, admin: 1 }

  def profile_completed?
    egg_name != "未登録"
  end

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
      sports_value:    0,
      art_value:       0,
      money:           0,
      arithmetic:      0,
      arithmetic_effort: 0,
      japanese:          0,
      japanese_effort:   0,
      science:           0,
      science_effort:    0,
      social_studies:    0,
      social_effort:     0,
    )
    first_set   = EventSet.find_by!(name: "何か言っている")
    first_event = Event.find_by!(event_set: first_set, derivation_number: 0)
    create_play_state!(
      current_event:             first_event,
      action_choices_position:   nil,
      action_results_priority:   nil,
      current_cut_position:      nil
    )
    create_event_temporary_datum!(
      reception_count: 0,
      success_count: 0,
      started_at: Time.current
    )
  end

  def truncate_name_to_6_chars
    self.name = name.each_char.take(6).join.to_s
  end
end
