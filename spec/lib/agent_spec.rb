require 'spec_helper'

describe Phearb::Agent do
  subject { described_class.new(@fetch_url) }

  context '#fetch' do
    before(:example) do
      @fetch_url = 'dummy_url'
      @server_url = "#{Phearb::Configuration::DEFAULT_HOST}:#{Phearb::Configuration::DEFAULT_PORT}"
      @response = { foo: :bar }.to_json

      stub_request(:get, @server_url).
      with(query: { fetch_url: @fetch_url }).
      to_return(status: 200, body: @response)
    end

    it 'performs a get request' do
      expect(subject.fetch).to have_requested(:get, @server_url).
        with(query: { fetch_url: @fetch_url })
    end

    it 'handles options' do
      allow(RestClient).to receive(:get) do |url, _|
        expect(_[:params][:some_option]).to eq(:some_value)
      end.and_return(@response)

      subject.fetch(some_option: :some_value)
    end

    it 'returns an instance of Phearb::Response' do
      expect(subject.fetch).to be_an_instance_of Phearb::Response
    end

    it 'raises Error::Timeout when timeout reached' do
      allow(RestClient).to receive(:get) do |_|
        sleep(Phearb.configuration.timeout + 0.1)
      end

      expect { subject.fetch }.to raise_error(Phearb::Error::Timeout)
    end
  end
end
