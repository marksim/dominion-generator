require 'rspec'
require_relative '../lib/generator'

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
      expect(kingdom.cards.count).to eql 10
    end

    it "generates a set of distinct cards" do
      kingdom = generator.randomize
      expect(kingdom.cards.map(&:name).uniq.count).to eql 10
    end

    it "generates a random set of cards" do
      kingdom = generator.randomize.cards.sort_by(&:name)
      kingdom2 = generator.randomize.cards.sort_by(&:name)
      expect(kingdom).to_not eql kingdom2
    end
  end

  context "specify cardsets" do
    it "only picks from the base when 'dominion' is specified" do
      kingdom = generator.randomize(limit: [:dominion])
      expect(kingdom.cards.map(&:cardset).uniq).to eql [:dominion]
    end

    it "only picks from seaside and base when specified" do
      kingdom = generator.randomize(limit: [:dominion, :seaside])
      expect(kingdom.cards.map(&:cardset).uniq).to match_array [:dominion, :seaside]
    end

    it "picks dark ages cards when specified" do
      kingdom = generator.randomize(limit: [:dominion, :dark_ages])
      expect(kingdom.cards.map(&:cardset).uniq).to match_array [:dominion, :dark_ages]
    end

    it "picks promo cards when specified" do
      kingdom = generator.randomize(limit: [:base, :promo])
      expect(kingdom.cards.map(&:cardset).uniq).to match_array [:base, :promo]
    end
  end

  context "alchemy picking" do
    it "kingdoms with fewer than 3 alchemy cards are invalid" do
      simple_set = generator.randomize(limit: [:dominion, :prosperity]).cards
      alchemy_set = generator.randomize(limit: [:alchemy]).cards
      kingdom = Kingdom.new(simple_set[0..8] + [alchemy_set.shuffle.first], alchemy_picking: true)
      expect(kingdom).to_not be_valid
    end
  end

  context "prosperity" do
    it "includes 'colonies and platinums' in every all-prosperity game" do
      kingdom = generator.randomize(limit: [:prosperity])
      expect(kingdom).to be_use_colonies
    end

    it "excludes 'colonies and platinums' in every non-prosperity game" do
      kingdom = generator.randomize(limit: [:intrigue])
      expect(kingdom).to_not be_use_colonies
    end
  end

  context "dark ages" do
    it "includes 'shelters' in every all-dark ages game" do
      kingdom = generator.randomize(limit: [:dark_ages])
      expect(kingdom).to be_use_shelters
    end

    it "excludes 'shelters' in every non-dark ages game" do
      kingdom = generator.randomize(limit: [:intrigue])
      expect(kingdom).to_not be_use_shelters
    end
  end
end

