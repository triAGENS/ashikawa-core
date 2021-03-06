# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/faraday_factory'

describe Ashikawa::Core::FaradayFactory do
  describe 'FaradayFactory.create_connection' do
    subject { Ashikawa::Core::FaradayFactory }
    let(:config_block) { double('Block') }
    let(:api_string) { double('ApiString') }

    before do
      allow(Faraday).to receive(:new).with(api_string).and_yield(config_block)
      allow(config_block).to receive(:request).with(:json)
      allow(config_block).to receive(:request).with(:x_arango_version)
      allow(config_block).to receive(:response).with(:error_response)
      allow(config_block).to receive(:response).with(:json)
      allow(config_block).to receive(:adapter).with(Faraday.default_adapter)
    end

    it 'should initialize with a specific logger' do
      logger = double('Logger')
      expect(config_block).to receive(:response).with(:minimal_logger, logger, debug_headers: false)
      subject.create_connection(api_string, logger: logger)
    end

    it 'should initialize with a specific adapter' do
      adapter = double('Adapter')
      expect(config_block).to receive(:adapter).with(adapter)
      subject.create_connection(api_string, adapter: adapter)
    end

    it 'should initialize with the default adapter when no specific adapter was given' do
      expect(config_block).to receive(:adapter).with(Faraday.default_adapter)
      subject.create_connection(api_string, {})
    end

    it 'should allow to add additional request middlewares with options' do
      expect(config_block).to receive(:request).with(:my_middleware, :options)
      subject.create_connection(api_string, additional_request_middlewares: [[:my_middleware, :options]])
    end

    it 'should allow to add additional response middlewares with options' do
      expect(config_block).to receive(:response).with(:my_middleware, :options)
      subject.create_connection(api_string, additional_response_middlewares: [[:my_middleware, :options]])
    end

    it 'should allow to add additional middlewares with options' do
      expect(config_block).to receive(:use).with(:my_middleware, :options)
      subject.create_connection(api_string, additional_middlewares: [[:my_middleware, :options]])
    end
  end
end
