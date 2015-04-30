require 'ostruct'
require 'yaml'

class Generator
  attr_reader :cards
  def initialize filename
    cards = YAML.load_file('cards.yaml')
    @cards = cards.map{|c| Card.new(c)}
  end

  def randomize(opts={})
    limit = opts.delete(:limit)
    available_cards = limit ?  @cards.select {|c| limit.map(&:to_sym).include?(c.cardset) } : @cards
    begin
      kingdom = Kingdom.new(available_cards.shuffle.slice(0..9), opts)
    end until (kingdom.valid?)
    kingdom
  end
end

class Kingdom
  attr_reader :cards

  def initialize(cards, options={})
    @cards = cards
    @options = options
  end

  def extra_setup
    setup_steps = []
    setup_steps << "Use Colonies/Platinums" if use_colonies?
    setup_steps << "Use Shelters" if use_shelters?
  end

  def valid?
    if @options[:alchemy_picking]
      card_count(:alchemy) == 0 || card_count(:alchemy) >= 3 && card_count(:alchemy) <= 5
    else
      true
    end
  end

  def use_colonies?
    rand(10) < card_count(:prosperity)
  end

  def use_shelters?
    rand(10) < card_count(:dark_ages)
  end

  def card_count(set)
    @card_counts ||= {}
    @card_counts[set] ||= @cards.select{|c| c.cardset == set.to_sym}.count
  end

end

class Card < OpenStruct
  def cardset
    self[:cardset].to_s.gsub(' ', '_').to_sym
  end
end
