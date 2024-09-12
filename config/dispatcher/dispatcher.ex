defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  define_layers [ :static, :services, :fall_back, :not_found ]

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

  match "/address-representations/*path", @json do
    Proxy.forward conn, path, "http://resource/address-representations/"
  end

  match "/persons/*path", @json do
    Proxy.forward conn, path, "http://resource/persons/"
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
