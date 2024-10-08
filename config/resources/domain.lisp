(in-package :mu-cl-resources)

(setf *include-count-in-paginated-responses* t)
(setf *supply-cache-headers-p* t)
(setf sparql:*experimental-no-application-graph-for-sudo-select-queries* t)
(setf *cache-model-properties-p* t)

(define-resource person ()
  :class (s-prefix "person:Person")
  :properties `((:last-name :string ,(s-prefix "foaf:familyName"))
                (:used-first-name :string ,(s-prefix "persoon:gebruikteVoornaam")))
  :has-many `((contact-point :via ,(s-prefix "schema:contactPoint")
                             :as "contact-points"))
  :has-one `(
             (identifier :via ,(s-prefix "persoon:registratie")
                            :as "identifier"))
  :resource-base (s-url "http://data.lblod.info/id/persons/")
  :features '(include-uri)
  :on-path "people")

(define-resource identifier ()
  :class (s-prefix "adms:Identifier")
  :properties `((:identifier :string ,(s-prefix "skos:notation")))
  :resource-base (s-url "http://data.lblod.info/id/identifiers/")
  :features '(include-uri)
  :on-path "identifiers")

(define-resource address ()
  :class (s-prefix "adres:Adres")
  :has-many `((address-representation :via ,(s-prefix "adres:verwijstNaar")
                                     :inverse t
                                     :as "referenced-by"))
  :resource-base (s-url "http://data.lblod.info/id/addresses/")
  :features '(include-uri)
  :on-path "addresses")

(define-resource address-representation ()
  :class (s-prefix "locn:Address")
  :properties `((:municipality-name :string ,(s-prefix "adres:gemeentenaam"))
                (:street-name :string ,(s-prefix "locn:thoroughfare"))
                (:postal-code :string ,(s-prefix "locn:postCode"))
                (:bus-number :string ,(s-prefix "adres:Adresvoorstelling.busnummer"))
                )
  :has-one `(
             (address :via ,(s-prefix "adres:verwijstNaar")
                         :as "references"))
  :resource-base (s-url "http://data.lblod.info/id/address-representations/")
  :features '(include-uri)
  :on-path "address-representations")


(define-resource contact-point ()
  :class (s-prefix "schema:ContactPoint")
  :properties `((:name :string ,(s-prefix "foaf:name"))
                (:email :string ,(s-prefix "schema:email"))
                (:telephone :string ,(s-prefix "schema:telephone"))
                )

  :has-one `((address-representation :via ,(s-prefix "locn:address")
                    :as "address"))
  :features '(include-uri)
  :resource-base (s-url "http://data.lblod.info/id/contact-points/")
  :on-path "contact-points")

(define-resource location-parcel ()
  :class (s-prefix "oe:LocatieElementPerceel")
  :properties `((:cadastral-department :string ,(s-prefix "ext:cadastralDepartment"))
               (:section :string ,(s-prefix "ext:cadastralSection"))
               (:number :string ,(s-prefix "ext:cadastralNumber")))
  :features '(include-uri)
  :resource-base (s-url "http://data.lblod.info/id/location-parcels/")
  :on-path "location-parcels"
  )

(define-resource case ()
  :class (s-prefix "oe:Dossier")
  :properties `(
                (:created :datetime ,(s-prefix "dct:created")))
  :has-one `(
             (admin-unit :via ,(s-prefix "oe:dos_heeftAlsOEGemeente")
                         :as "admin-unit")
             (postal-item :via ,(s-prefix "oe:dos_werdOpgestartDoorPoststuk")
                          :as "started-by")
             (person :via ,(s-prefix "oe:dos_werdAangevraagdDoor")
                     :as "submitter")
             (designation-object :via ,(s-prefix "oe:dos_handeltPrimairOver")
                                 :as "primary-subject")
             )
  :has-many `((contact-point :via ,(s-prefix "schema:contactPoint")
                             :as "contact-points"))
  :features '(include-uri)
  :resource-base (s-url "http://data.lblod.info/id/cases/")
  :on-path "cases"
  )

(define-resource designation-object ()
  :class (s-prefix "oe:Aanduidingsobject")
  :properties `(
                (:full-address :string ,(s-prefix "locn:fullAddress"))
                (:admin-unit-name :string ,(s-prefix "adres:Gemeentenaam"))
                (:name :string ,(s-prefix "sdo:name"))
                (:keywords :string ,(s-prefix "sdo:keyword"))
                (:identifier :string ,(s-prefix "generiek:lokaleIndentificator")))
  :has-one `((address-representation :via ,(s-prefix "locn:address")
                                     :as "address")
             (location-parcel :via ,(s-prefix "ext:parcel") ;; TODO: proper predicate
                              :as "parcel")
             )
  :features '(include-uri)
  :resource-base (s-url "http://data.lblod.info/id/designation-objects/")
  :on-path "designation-objects"
  )

(define-resource postal-item ()
  :class (s-prefix "oe:Poststuk")
  :properties `((:body :string ,(s-prefix "rdf:value")))
  :features '(include-uri)
  :resource-base (s-url "http://data.lblod.info/id/postal-items/")
  :on-path "postal-items"
  )


(define-resource user ()
  :class (s-prefix "foaf:Person")
  :properties `((:first-name :string ,(s-prefix "foaf:firstName"))
                (:last-name :string ,(s-prefix "foaf:familyName"))
                )
  :has-one `((account :via ,(s-prefix "foaf:account")
                      :as "account")
             (admin-unit :via ,(s-prefix "foaf:member")
                         :as "admin-unit"
                         :inverse t)
             )
  :resource-base (s-url "http://data.lblod.info/id/users/")
  :on-path "users"
  )

(define-resource account ()
  :class (s-prefix "foaf:OnlineAccount")
  :properties `((:provider :string ,(s-prefix "foaf:accountServiceHomepage"))
                (:identifier :string ,(s-prefix "dct:identifier"))
                )
  :has-one `((user :via ,(s-prefix "foaf:account")
                   :as "user"
                   :inverse t))
  :resource-base (s-url "http://data.lblod.info/id/accounts/")

  :on-path "accounts"
  )
(define-resource admin-unit ()
  :class (s-prefix "besluit:Bestuurseenheid")
  :properties `((:name :string ,(s-prefix "skos:prefLabel")))
  :resource-base (s-url "http://data.lblod.info/id/bestuurseenheden/")
  :on-path "admin-units"
  )
;; ;; reading in the domain.json
;; ;(read-domain-file "domain.json")
