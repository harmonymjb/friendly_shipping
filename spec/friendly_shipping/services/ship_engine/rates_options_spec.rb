# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::RatesOptions do
  subject(:options) do
    described_class.new(
      carriers: [double(id: "se-12345")],
      service_code: "usps_priority_mail",
      ship_date: Time.parse("2023-11-16")
    )
  end

  it { is_expected.to respond_to(:carriers) }
  it { is_expected.to respond_to(:service_code) }
  it { is_expected.to respond_to(:ship_date) }
  it { is_expected.to be_a(FriendlyShipping::ShipmentOptions) }

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::PackageOptions }
    let(:required_attrs) { { carriers: [], service_code: nil } }
  end
end
