# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(OkComputer::Checks) do
  let(:response) do
    {
      status: 200,
      body: MultiJson.encode(status: { 'c4-fr' => 'operational' }),
    }
  end

  subject(:collection) { described_class.register }

  before { stub_request(:get, %r{/1/status}).to_return(response) }

  describe('.register') do
    let(:app_id) { 'APPID' }
    let(:api_key) { 'apikey' }

    context('when klass') do
      before do
        described_class.register do |r|
          r.add(:algolia, :search, app_id: app_id, api_key: api_key)
        end
        collection.run
      end

      it { expect(collection.fetch(:search)).to(be_present) }
      it { is_expected.to(be_success) }
    end

    context('when check') do
      let(:check) { OkComputer::AlgoliaCheck.new(app_id: app_id, api_key: api_key) }

      before do
        described_class.register do |r|
          r.add(check, :search)
        end
        collection.run
      end

      it { expect(collection.fetch(:search)).to(be_present) }
      it { is_expected.to(be_success) }
    end

    context('when check collection') do
      let(:check) { OkComputer::AlgoliaCheck.new(app_id: app_id, api_key: api_key) }
      let(:check_collection) { OkComputer::CheckCollection.new(:custom) }

      before do
        check_collection.register(:search, check)
        described_class.register do |r|
          r.add(check_collection, :custom)
        end
        collection.run
      end

      it { expect(collection.fetch(:custom)).to(be_present) }
      it { expect(collection.fetch(:search)).to(be_present) }
      it { is_expected.to(be_success) }
    end
  end
end
