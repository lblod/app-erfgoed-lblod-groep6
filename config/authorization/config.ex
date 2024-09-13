alias Acl.Accessibility.Always, as: AlwaysAccessible
alias Acl.GraphSpec.Constraint.Resource, as: ResourceConstraint
alias Acl.GraphSpec, as: GraphSpec
alias Acl.GroupSpec, as: GroupSpec
alias Acl.GroupSpec.GraphCleanup, as: GraphCleanup
alias Acl.Accessibility.ByQuery, as: AccessByQuery
alias Acl.GraphSpec.Constraint.Resource.AllPredicates, as: AllPredicates
alias Acl.GraphSpec.Constraint.Resource.NoPredicates, as: NoPredicates
alias Acl.GraphSpec.Constraint.ResourceFormat, as: ResourceFormatConstraint

defmodule Acl.UserGroups.Config do

  defp is_admin() do
    %AccessByQuery{
      vars: ["bestuurseenheidUUID"],
      query: "
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        PREFIX muAccount: <http://mu.semte.ch/vocabularies/account/>
        PREFIX mu: <http://mu.semte.ch/vocabularies/core/>

        SELECT DISTINCT ?bestuurseenheidUUID WHERE {
          <SESSION_ID> muAccount:account ?onlineAccount .

          ?onlineAccount a foaf:OnlineAccount .

          ?agent
            a foaf:Person ;
            foaf:account ?onlineAccount .

          <http://lblod.data.gift/groups/admins>
            a foaf:Group ;
            foaf:member ?agent .

          ?bestuurseenheid
            foaf:member ?agent ;
            mu:uuid ?bestuurseenheidUUID .
        }"
      }
  end


  def user_groups do
    [
      # // Admin access
      # Only admins can see personal data
      %GroupSpec{
        name: "admin",
        useage: [:write, :read_for_write, :read],
        access: is_admin(),
        graphs: [
          %GraphSpec{
            graph: "http://data.lblod/graphs/admin/",
            constraint: %ResourceConstraint{
              resource_types: [
                "https://data.vlaanderen.be/ns/persoon#Person",
                "http://www.w3.org/ns/adms#Identifier",
                "http://schema.org/ContactPoint"
              ],
              predicates: %AllPredicates{}
            }
          }
        ]
      },

      # // PUBLIC
      # All other data is publicly available
      %GroupSpec{
        name: "public",
        useage: [:read],
        access: %AlwaysAccessible{},
        graphs: [
          %GraphSpec{
            graph: "http://mu.semte.ch/graphs/public",
            constraint: %ResourceConstraint{
              resource_types: []
            }
          }
        ]
      },

      # // CLEANUP
      #
      %GraphCleanup{
        originating_graph: "http://mu.semte.ch/application",
        useage: [:write],
        name: "clean"
      }
    ]
  end
end

