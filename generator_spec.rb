require 'rspec'
require 'ostruct'
require 'yaml'

class Card < OpenStruct
end

class Generator
  attr_reader :cards
  def initialize filename
    cards = YAML.load_file('cards.yaml')
    @cards = cards.map{|c| Card.new(c)}
  end

  def randomize(opts={})
    available_cards = opts[:limit] ?  @cards.select {|c| opts[:limit].map(&:to_sym).include?(c.cardset.to_sym) } : @cards
    available_cards.shuffle.slice(0..9)
  end
end

describe Generator do
  let(:generator) { Generator.new('cards.yaml') }
  it "loads all cards into card objects" do
    expect(generator.cards.count).to eql 234
  end

  it "creates cards from hashes" do
    expect(generator.cards.first.name).to eql "Alchemist"
  end

  context "generating a set" do
    it "generates a set of 10 cards" do
      kingdom = generator.randomize
      expect(kingdom.count).to eql 10
    end

    it "generates a set of distinct cards" do
      kingdom = generator.randomize
      expect(kingdom.map(&:name).uniq.count).to eql 10
    end

    it "generates a random set of cards" do
      kingdom = generator.randomize.sort_by(&:name)
      kingdom2 = generator.randomize.sort_by(&:name)
      expect(kingdom).to_not eql kingdom2
    end
  end

  context "specify cardsets" do
    it "only picks from the base when 'base' is specified" do
      kingdom = generator.randomize(limit: [:base])
      expect(kingdom.map(&:cardset).uniq).to eql ['base']
    end

    it "only picks from seaside and base when specified" do
      kingdom = generator.randomize(limit: [:base, :seaside])
      expect(kingdom.map(&:cardset).uniq).to match_array ['base', 'seaside']
    end

    it "picks promo cards when specified" do
      kingdom = generator.randomize(limit: [:base, :promo])
      expect(kingdom.map(&:cardset).uniq).to match_array ['base', 'promo']
    end
  end

  context "alchemy picking" do

  end


end

