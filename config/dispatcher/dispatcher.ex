defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ],
    sparql: [ "application/sparql-results+json" ],
    any: [ "*/*" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  define_layers [ :static, :sparql, :services, :frontend_fallback, :resources, :not_found ]

  ###############
  # STATIC
  ###############

  # self-service
  match "/index.html", %{ layer: :static } do
    forward conn, [], "http://frontend/index.html"
  end

  get "/assets/*path",  %{ layer: :static } do
    forward conn, path, "http://frontend/assets/"
  end

  get "/@appuniversum/*path", %{ layer: :static } do
    forward conn, path, "http://frontend/@appuniversum/"
  end

  ###############
  # SPARQL
  ###############

  match "/sparql", %{ layer: :sparql, accept: %{ sparql: true } } do
    forward conn, [], "http://database:8890/sparql"
  end

  ###############
  # RESOURCES
  ###############

  match "/mock/sessions/*path", @json do
    Proxy.forward conn, path, "http://mocklogin/sessions/"
  end

  match "/admin-units/*path", @json do
    Proxy.forward conn, path, "http://resource/admin-units/"
  end

  match "/accounts/*path", @json do
    Proxy.forward conn, path, "http://resource/accounts/"
  end

  match "/users/*path", @json do
    Proxy.forward conn, path, "http://resource/users/"
  end

  match "/contact-points/*path", @json do
    Proxy.forward conn, path, "http://resource/contact-points/"
  end

  match "/addresses/*path", @json do
    Proxy.forward conn, path, "http://resource/addresses/"
  end

  match "/adres-search/*path" do
    forward conn, path, "http://adressenregister"
  end

  match "/address-representations/*path", @json do
    Proxy.forward conn, path, "http://resource/address-representations/"
  end

  match "/people/*path", @json do
    Proxy.forward conn, path, "http://resource/people/"
  end

  match "/identifiers/*path", @json do
    Proxy.forward conn, path, "http://resource/identifiers/"
  end

  match "/location-parcels/*path", @json do
    Proxy.forward conn, path, "http://resource/location-parcels/"
  end

  match "/cases/*path", @json do
    Proxy.forward conn, path, "http://resource/cases/"
  end

  match "/designation-objects/*path", @json do
    Proxy.forward conn, path, "http://resource/designation-objects/"
  end

  match "/postal-items/*path", @json do
    Proxy.forward conn, path, "http://resource/postal-items/"
  end
  #
  # Run `docker-compose restart dispatcher` after updating
  # this file.

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
