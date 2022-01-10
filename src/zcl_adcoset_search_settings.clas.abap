"! <p class="shorttext synchronized" lang="en">Access to search settings stored on the server</p>
CLASS zcl_adcoset_search_settings DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Retrieves server side code search settings</p>
      get_settings
        RETURNING
          VALUE(result) TYPE zif_adcoset_ty_adt_types=>ty_code_search_settings.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_adcoset_search_settings IMPLEMENTATION.


  METHOD get_settings.
    " as the default settings correspond to an empty entry sy-subrc <> 0 does
    " have to be handled
    SELECT SINGLE *
      FROM zadcoset_csset
      WHERE uname = @sy-uname
      INTO CORRESPONDING FIELDS OF @result.
  ENDMETHOD.


ENDCLASS.
