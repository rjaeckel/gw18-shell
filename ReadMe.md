With the release of GroupWise 18, the Vendor pushed out an updated version of the `Admin API`.

The WADL-Document describing this REST~ful~ API has changed in several, ~breaking~ manners.

 * [-] Method `ID`s removed
 * [-] Request and Response Elements for methods of `Domain Object Types' removed
 * [~] Flattened `<wadl:method /> structure


# Challenge accepted.

As the relevant api describing wadl- and xsd-files are publicly available, I've decided to place theese here too.


## Stats

This api is huge.

>
> **`gw14/application.wadl`**
>
> WADL-GENERATOR: `Jersey: 1.13 06/29/2012 05:14 PM`
> 
> TOTAL Methods: `447`
> UNIQUE Representation elements: `77`

> **`gw18/application.wadl`**
>
> WADL-GENERATOR: `Enunciate-2.0`
>
> TOTAL Methods: `622`
> UNIQUE Representation elements: `123`