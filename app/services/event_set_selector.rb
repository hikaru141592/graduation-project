class EventSetSelector
  PRIORITY_LIST = [
    '泣いている(空腹)',
    '泣いている(よしよし不足)',
    '泣いている(ランダム)',
    '踊っている',
    '何かしたそう',
    '何か言っている'
  ].freeze

  def initialize(user)
    @user       = user
    @status     = user.user_status
    @event_sets = EventSet.all.to_a
  end

  def select_next
    PRIORITY_LIST.each do |name|
      set = @event_sets.find { |s| s.name == name }
      next unless set
      conds = set.trigger_conditions
      return set if conditions_met?(conds)
    end

    @event_sets.find { |s| s.name == '何か言っている' }
  end

  private

  def conditions_met?(conds)
    return true if conds['always'] == true

    op   = conds['operator'] || 'and'
    list = conds['conditions'] || []

    results = list.map do |c|
      case c['type']
      when 'status'
        @status
          .public_send(c['attribute'])
          .public_send(c['operator'], c['value'])
      when 'probability'
        rand(100) < c['percent']
      when 'item'
        @user.user_items
             .find_by(code: c['item_code'])
             .try(:count).to_i
             .public_send(c['operator'], c['value'])
      else
        false
      end
    end

    op == 'and' ? results.all? : results.any?
  end
end
