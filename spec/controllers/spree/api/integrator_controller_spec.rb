require 'spec_helper'

module Spree
  describe Api::IntegratorController do
    render_views

    before do
      stub_authentication!
    end


    it 'gets all available collections' do
      api_get :index

      expect(json_response['collections']).to have(5).items
    end

    it 'gets orders changed since' do
      order = create(:completed_order_with_totals)
      Order.update_all(:updated_at => 2.days.ago)

      api_get :show_orders, since: 3.days.ago.utc.to_s,
                      page: 1,
                      per_page: 1

      json_response['orders']['count'].should eq 1
      json_response['orders']['current_page'].should eq 1

      json_response['orders']['page'].first['number'].should eq order.number
      json_response['orders']['page'].first.should have_key('ship_address')
      json_response['orders']['page'].first.should have_key('bill_address')
      json_response['orders']['page'].first.should have_key('payments')
      json_response['orders']['page'].first.should have_key('credit_cards')
    end

    it 'gets stock_transfers changed since' do
      source = create(:stock_location)
      destination = create(:stock_location_with_items, :name => 'DEST101')
      stock_transfer = StockTransfer.create do |transfer|
        transfer.source_location_id = source.id
        transfer.destination_location_id = destination.id
        transfer.reference = 'PO 666'
      end
      StockTransfer.update_all(:updated_at => 2.days.ago)

      StockMovement.create do |movement|
        movement.stock_item = source.stock_items.first
        movement.quantity = -1
        movement.originator = stock_transfer
      end

      StockMovement.create do |movement|
        movement.stock_item = destination.stock_items.first
        movement.quantity = 1
        movement.originator = stock_transfer
      end

      api_get :show_stock_transfers, since: 3.days.ago.utc.to_s,
        page: 1,
        per_page: 1

      transfer = json_response['stock_transfers']['page'].first
      transfer['destination_location']['name'].should eq 'DEST101'
      transfer['destination_movements'].first['quantity'].should eq 1
    end

    it 'gets products changed since' do
      product = create(:product)
      Product.update_all(:updated_at => 2.days.ago)

      api_get :show_products, since: 3.days.ago.utc.to_s,
                      page: 1,
                      per_page: 1

      json_response['products']['count'].should eq 1
      json_response['products']['current_page'].should eq 1
      json_response['products']['page'].first['id'].should eq product.id
    end
  end
end
