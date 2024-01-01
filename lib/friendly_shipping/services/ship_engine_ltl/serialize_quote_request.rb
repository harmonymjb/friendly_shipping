# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Serializes a shipment and options for the rate quote API request.
      class SerializeQuoteRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment to serialize
          # @param options [QuoteOptions] the options to serialize
          # @return [Hash] the serialized request
          def call(shipment:, options:)
            {
              shipment: {
                service_code: options.service_code,
                pickup_date: options.pickup_date.strftime('%Y-%m-%d'),
                packages: options.packages_serializer_class.call(packages: shipment.packages, options: options),
                options: serialize_options(options),
                ship_from: serialize_ship_address(shipment.origin),
                ship_to: serialize_ship_address(shipment.destination),
                bill_to: serialize_bill_address(shipment.origin),
                requested_by: serialize_requested_by(shipment.origin),
              }.compact,
              shipment_measurements: serialize_shipment_measurements(shipment.packages)
            }
          end

          private

          # @param options [QuoteOptions]
          # @return [Array<Hash>]
          def serialize_options(options)
            options.accessorial_service_codes.map do |code|
              { code: code }
            end
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def serialize_ship_address(location)
            {
              account: location.properties.with_indifferent_access['account_number'],
              address: serialize_address(location),
              contact: serialize_contact(location)
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def serialize_bill_address(location)
            {
              type: "shipper",
              payment_terms: "prepaid",
              account: location.properties.with_indifferent_access['account_number'],
              address: serialize_address(location),
              contact: serialize_contact(location)
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def serialize_address(location)
            {
              company_name: location.company_name,
              address_line1: location.address1,
              city_locality: location.city,
              state_province: location.region.code,
              postal_code: location.zip,
              country_code: location.country.code
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def serialize_contact(location)
            {
              name: location.name,
              phone_number: location.phone,
              email: location.email
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def serialize_requested_by(location)
            {
              company_name: location.company_name,
              contact: serialize_contact(location)
            }.compact
          end

          # @param packages [Array<Physical::Package>]
          # @return [Hash]
          def serialize_shipment_measurements(packages)
            {
              total_linear_length: {
                value: packages.sum(&:length).convert_to(:inches).value.ceil,
                unit: "inches"
              },
              total_width: {
                value: packages.map(&:width).max.convert_to(:inches).value.ceil,
                unit: "inches"
              },
              total_height: {
                value: packages.map(&:height).max.convert_to(:inches).value.ceil,
                unit: "inches"
              },
              total_weight: {
                value: +packages.sum(&:weight).convert_to(:pounds).value.ceil,
                unit: "pounds"
              }
            }
          end
        end
      end
    end
  end
end
