# frozen_string_literal: true

COMPONENTS_FOLDER = Rails.root.join(*%w[spec support swagger components]).freeze

def schema_list(resource)
  {
    type:  :array,
    items: resource_ref(resource)
  }
end

def pagination_headers
  metadata[:response][:headers] ||= {}

  metadata[:response][:headers]['Current-Page'] = header_ref(:current_page)
  metadata[:response][:headers]['Page-Items']   = header_ref(:page_items)
  metadata[:response][:headers]['Total-Count']  = header_ref(:total_count)
  metadata[:response][:headers]['Total-Pages']  = header_ref(:total_pages)
end

def cors_headers
  metadata[:response][:headers] ||= {}

  metadata[:response][:headers]['Access-Control-Allow-Origin']      = header_ref(:access_control_allow_origin)
  metadata[:response][:headers]['Access-Control-Allow-Credentials'] = header_ref(:access_control_allow_credentials)
  metadata[:response][:headers]['Access-Control-Expose-Headers']    = header_ref(:access_control_allow_headers)
  metadata[:response][:headers]['Access-Control-Allow-Methods']     = header_ref(:access_control_allow_methods)
  metadata[:response][:headers]['Access-Control-Max-Age']           = header_ref(:access_control_max_age)
end

def body_params(resource, type)
  { in: :body, name: resource, schema: metadata[:schema][:action_params][type] }
end

def query_params(type)
  metadata[:schema][:action_params][type].to_a.each { |param| parameter(in: :query, **param) }
end

def errors_schema
  { '$ref': '#/components/schemas/errors_object' }
end

def load_schema(name)
  yaml_load_erb([COMPONENTS_FOLDER, 'schemas', "#{name}.yml"].join('/'))
end

def resource_ref(name)
  { '$ref': "#/components/schemas/#{name}" }
end

def params_ref(name)
  { '$ref': "#/components/parameters/#{name}" }
end

def header_ref(name)
  { '$ref': "#/components/headers/#{name}" }
end

def generate_swagger_docs
  base_doc = yaml_load_erb(Rails.root.join('spec/support/swagger/docs_v1.yml'))

  base_doc[:components][:headers]    = response_headers_components
  base_doc[:components][:parameters] = query_params_components
  base_doc[:components][:schemas].merge!(resources_components)
  base_doc
end

def resources_components
  folder = [COMPONENTS_FOLDER, :schemas].join('/')
  Dir.entries(folder).filter { |f| !f[/\A..?\Z/] }.each_with_object({}) do |file_name, obj|
    resource = file_name.gsub('.yml', '')
    schema   = yaml_load_erb(Rails.root.join(folder, file_name))

    obj[resource] = schema[:response_attributes]
  end
end

def query_params_components
  folder = [COMPONENTS_FOLDER, :parameters].join('/')
  Dir.entries(folder).filter { |f| !f[/\A..?\Z/] }.each_with_object({}) do |file_name, obj|
    name      = file_name.gsub('.yml', '').camelcase(:lower)
    obj[name] = yaml_load_erb(Rails.root.join(folder, file_name))
  end
end

def response_headers_components
  folder = [COMPONENTS_FOLDER, :response, :headers].join('/')
  Dir.entries(folder).filter { |f| !f[/^\./] }.each_with_object({}) do |file_name, obj|
    name      = file_name.gsub('.yml', '')
    path      = Rails.root.join(folder, file_name)
    obj[name] =
      begin
        yaml_load_erb path
      rescue Psych::SyntaxError
        raise "#{path} is invalid"
      end
  end
end

def yaml_load_erb(path)
  YAML.safe_load(ERB.new(File.read(path)).result, permitted_classes: [Symbol], permitted_symbols: [], aliases: true)
end

def request_example_setup(options = {})
  consumes 'application/json'
  produces 'application/json'
  security [bearerAuth: []] unless options[:not_secure]
  return unless options[:permitted_action]

  metadata[:permitted_action] = options[:permitted_action]
  return if options[:no_query_params]

  query_params(options[:query_params] || options[:permitted_action])
end

def origin_parameter
  parameter name: :Origin, in: :header, description: 'Origin host', schema: { type: :string }
end

# rubocop:disable RSpec/VariableName
def origin_let
  let(:Origin) { 'http://nemo.data' }
end
# rubocop:enable RSpec/VariableName

def id_parameter
  parameter name: :id, in: :path, description: "#{metadata[:resource].to_s.titleize} UUID",
            schema: { type: :string, format: :uuid }
end
