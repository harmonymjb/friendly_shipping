# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::RL::SerializeLocation do
  subject(:call) { described_class.call(location) }

  let(:location) do
    FactoryBot.build(
      :physical_location,
      company_name: "ACME Inc",
      address1: "123 Maple St",
      address2: "Suite 100",
      city: "New York",
      region: "NY",
      zip: "10001",
      phone: "123-123-1234",
      email: "acme@example.com"
    )
  end

  it do
    is_expected.to eq(
      CompanyName: "ACME Inc",
      AddressLine1: "123 Maple St",
      AddressLine2: "Suite 100",
      City: "New York",
      StateOrProvince: "NY",
      ZipOrPostalCode: "10001",
      CountryCode: "USA",
      PhoneNumber: "123-123-1234",
      EmailAddress: "acme@example.com"
    )
  end

  context "when phone has leading country code" do
    let(:location) do
      FactoryBot.build(
        :physical_location,
        phone: "1-123-123-1234"
      )
    end

    it do
      is_expected.to match(
        hash_including(
          PhoneNumber: "123-123-1234"
        )
      )
    end
  end
end
