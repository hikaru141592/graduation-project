class User < ApplicationRecord
  authenticates_with_sorcery!

  NAME_MAX_LENGTH = 6

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

  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, confirmation: true,
            if: -> { authentications.empty? && (new_record? || changes[:crypted_password]) }
  validates :password_confirmation, presence: true,
            if: -> { authentications.empty? && (new_record? || changes[:crypted_password]) }
  validates :name,      presence: true, length: { maximum: NAME_MAX_LENGTH }
  validates :egg_name,
    presence: true,
    length: { maximum: 6 }

  # LINE認証による仮登録時のみ未登録とし、仮登録ユーザーをrootに通したりしないようにするための判断基準とする。
  validates :egg_name,
    exclusion: {
      in: [ "未登録" ],
      message: "には「未登録」という文字列を使用できません"
    },
    unless: :line_registration?
  validates :birth_month, presence: true, inclusion: { in: 1..12 }
  validates :birth_day,   presence: true, inclusion: { in: 1..31 }
  validates :friend_code, presence: true, uniqueness: true, format: { with: /\A\d{8}\z/ }
  validates :reset_password_token, uniqueness: true, allow_nil: true

  enum :role, { general: 0, admin: 1 }
  enum :name_suffix, { no_suffix: 0, chan: 1, kun: 2, sama: 3 }

  attr_accessor :line_registration

  def profile_completed?
    egg_name != "未登録"
  end

  def clear_event_category_invalidations!
    user_event_category_invalidations.where("expires_at < ?", Time.current).delete_all
  end

  def pick_next_event_set_and_event
    selector = EventSetSelector.new(self)
    next_set = selector.select_next
    next_event = next_set.events.find_by!(derivation_number: 0)
    [ next_set, next_event ]
  end

  def reset_event_temporary_data!
    event_temporary_datum.update!(
      reception_count: 0,
      success_count: 0,
      started_at: nil,
      special_condition: nil,
      ended_at: nil,
    )
  end

  def egg_name_with_suffix
    suffix_map = {
      "no_suffix" => "",
      "kun"       => "くん",
      "chan"      => "ちゃん",
      "sama"      => "さま"
    }

    self.egg_name + suffix_map[self.name_suffix]
  end

  def name_suffix_change!(event, position)
    return unless event.name == "たまごのなまえ"
    self.name_suffix = position - 1
    save!
  end

  def birthday?
    today = Time.current.to_date
    if self.birth_month == 2 && self.birth_day == 29 && !Date.leap?(today.year)
      today.month == 2 && today.day == 28
    else
      today.month == self.birth_month && today.day == self.birth_day
    end
  end

  def invalidate_event_category!(event_category, expires_at)
    inv = user_event_category_invalidations.find_or_initialize_by(event_category: event_category)
    inv.expires_at = expires_at
    inv.save!
  end

  def line_registration?
    line_registration == true
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
      love_value:      50,
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
    first_set   = EventSet.find_by!(name: "イントロ")
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
