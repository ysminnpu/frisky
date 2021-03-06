require 'spec_helper'
require 'frisky/commands/event_scheduler'
require 'fixtures/classifiers/valid_classifier.rb'

describe Frisky::Commands::EventScheduler do
  before :all do
    reset_databases
  end

  let (:command) { Frisky::Commands::EventScheduler.new(url: "events", mute: true) }

  describe '#fetch_loaded_classifiers' do
    it "drops expired classifiers" do
      # add an expired classifier
      Frisky.redis.zadd("classifiers", (Time.now.utc.to_i - 120), "expired_classifier")
      command.fetch_loaded_classifiers
      command.classifiers.length == 0
    end

    it "doesn't drop alive classifiers" do
      # add a valid classifier
      Frisky.redis.zadd("classifiers", (Time.now.utc.to_i - 2), "not_expired_classifier")
      command.fetch_loaded_classifiers
      command.classifiers.length == 1
    end
  end

  describe '#perform' do
    before :each do
      reset_databases
      ValidClassifier.announce
      command.fetch_loaded_classifiers
      command.perform(1)
    end

    it "doesn't create events" do
      Frisky::Model::Event.count.should == 0
    end

    it "does queue some jobs" do
      Frisky.redis.llen("resque:queue:ValidClassifier").should > 0
    end
  end
end