# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.shared_examples 'permissions' do |model, action, options = {}|
  before do
    request.headers['Content-Type']  = 'application/json'
    request.headers['Authorization'] = send('Authorization')
  end

  let(:fleet1) { create(:fleet) }
  let(:fleet2) { create(:fleet) }
  let(:permitted_fleet_ids) { [fleet1.id, fleet2.id] }
  let(:permitted_record) { create(model, fleet_id: permitted_fleet_ids.first) }
  let(:unpermitted_record) { create(model) }
  let(:attributes) { attributes_for(model) }

  context "unpermitted #{action} on permitted fleet" do
    authorize_user(model.to_s.pluralize, :dummy)
    it 'expects status 403' do
      verb, params = case action
                     when :show then [:get, { id: permitted_record.id }]
                     when :create then [:post, attributes]
                     when :update then [:put, attributes.merge!(id: permitted_record.id)]
                     when :destroy then [:delete, { id: permitted_record.id }]
                     else
                       fleet_id = permitted_record.attributes['fleet_id']
                       [:get, fleet_id ? { fleet_id: fleet_id } : nil]
                     end
      send(verb, action, **{ params: params }.compact)
      expect(response).to have_http_status :forbidden
    end
  end

  next if %i[create index].include?(action) || options[:skip_unpermitted_fleets]

  context "permitted #{action} on unpermitted fleet" do
    authorize_user(model.to_s.pluralize, action)
    it 'expects status 403' do
      verb, params = case action
                     when :show then [:get, { id: unpermitted_record.id }]
                     when :update then [:put, attributes.merge!(id: unpermitted_record.id)]
                     when :destroy then [:delete, { id: unpermitted_record.id }]
                     else
                       [:get, nil]
                     end
      send(verb, action, **{ params: params }.compact)

      expect(response).to have_http_status :forbidden
    end
  end
end
# rubocop:enable Metrics/BlockLength
