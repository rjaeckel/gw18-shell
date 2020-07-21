With the release of GroupWise 18, the Vendor pushed out an updated version of the `Admin API`.

The WADL-Document describing this REST~ful~ API has changed in several, ~breaking~ manners.

 * Method IDs removed
 * Flattened `<wadl:method /> structure
 * Request and Response Elements for Domain Object Types' methods removed


# Challenge accepted.

As the relevant api describing wadl- and xsd-filed are publicly available, so I've decided to place them here too.


## Stats

> `gw14/application.wadl`
>
> WADL-GENERATOR: `Jersey: 1.13 06/29/2012 05:14 PM`
> UNIQUE Representation elements: `77`
> UNIQUE Methods: `447`

> `gw18/application.wadl`
>
> WADL-GENERATOR: `Enunciate-2.0`
> UNIQUE Representation elements: `123`
> UNIQUE Methods: `622`