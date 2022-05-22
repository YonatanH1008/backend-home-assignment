# frozen_string_literal: true

# rubocop:disable RSpec/VariableName
def test_index(options = {})
  get("lists #{resource}") do
    tags resource.to_s
    request_example_setup permitted_action: :index
    description "returns a paginated array of #{resource} items"
    parameter params_ref(:page)
    parameter params_ref(:itemsPerPage)

    let(:page) { 1 }
    let(:itemsPerPage) { 20 }

    response 200, :successful do
      schema schema_list(resource)
      cors_headers
      pagination_headers
      authorize_user_request
      setup_all_fleet_permissions if resource == :fleet

      it 'returns a valid 200 response' do |example|
        if block_given?
          yield
        elsif resource == :fleet
          create_list(resource, 25)
        else
          create_list(resource, 25, fleet_id: permitted_fleet_ids.first)
        end

        run_example!(example)

        expect(response.parsed_body.size).to eq itemsPerPage
      end
    end
    test401
    test403 unless options[:skip403]
  end
end

def test_create(procc = nil)
  post "creates #{resource}" do
    tags resource.to_s
    request_example_setup permitted_action: :create, no_query_params: true
    description "creates and returns the created #{resource} item"
    parameter body_params(resource, :create)

    let(resource) { build_attributes :create, procc }

    response 201, "#{resource} created" do
      cors_headers
      schema resource_ref(resource)
      authorize_user_request

      it 'returns a valid 201 response' do |example|
        yield if block_given?
        run_example!(example)
      end
    end
    test401
    test403
  end
end

def test_show
  get("shows #{resource}") do
    tags resource.to_s
    request_example_setup permitted_action: :show, no_query_params: true
    description "returns the requested #{resource} item"

    setup_record
    permit_record if resource == :fleet
    setup_id

    response 200, :successful do
      schema metadata[:schema][:extended_response]
      cors_headers
      authorize_user_request

      it 'returns a valid 200 response' do |example|
        run_example!(example)
      end
    end
    test401
    test403
    test404
  end
end

def test_update(procc = nil)
  put "updates #{resource}" do
    tags resource.to_s
    request_example_setup permitted_action: :update, no_query_params: true
    description "updates and returns the updated #{resource} item"
    parameter body_params(resource, :update)

    setup_record
    permit_record if resource == :fleet
    setup_id
    let(resource) { build_attributes :update, procc }

    response 200, :successful do
      schema resource_ref(resource)
      cors_headers
      authorize_user_request

      it 'returns a valid 201 response' do |example|
        updated_at = record.updated_at
        travel_to 10.seconds.from_now

        run_example!(example)

        expect(updated_at).not_to eq(record.reload.updated_at)
      end
    end
    test401
    test403
    test404
  end
end

def test_destroy
  delete("destroys #{resource}") do
    tags resource.to_s
    request_example_setup permitted_action: :destroy, no_query_params: true
    description "deletes and returns the deleted #{resource} item"

    setup_record
    permit_record if resource == :fleet
    setup_id

    response 200, :successful do
      schema resource_ref(resource)
      cors_headers
      authorize_user_request

      it 'returns a valid 200 response' do |example|
        run_example!(example)

        expect(record.class.find_by(id: record.id)).to be_nil
      end
    end
    test401
    test403
    test404
  end
end

def run_example!(example)
  submit_request(example.metadata)
  assert_response_matches_metadata(example.metadata)
end

def build_attributes(type, procc)
  allowed_keys = self.class.metadata[:schema]["#{type}_attributes".to_sym].keys
  attributes   = attributes_for(resource).slice(*allowed_keys)
  attributes.merge!({ fleet_id: permitted_fleet_ids.first }) unless resource == :fleet
  procc&.call(attributes, type, permitted_fleet_ids)
  attributes
end

def setup_record
  let(:record) do
    resource == :fleet ? create(resource) : create(resource, fleet_id: permitted_fleet_ids.first)
  end
end

def setup_all_fleet_permissions
  let(:permitted_fleet_ids) { ['*'] }
end

def permit_record
  let(:permitted_fleet_ids) { [record.id] }
end

def setup_id
  let(:id) { record.id }
end

def resource
  (instance_of?(Class) ? metadata : self.class.metadata)[:resource]
end
# rubocop:enable RSpec/VariableName
