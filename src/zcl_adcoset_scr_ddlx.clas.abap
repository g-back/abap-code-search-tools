"! <p class="shorttext synchronized">Source code reader for metadata extensions</p>
CLASS zcl_adcoset_scr_ddlx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_adcoset_src_code_reader.

    METHODS constructor
      IMPORTING
        is_multiline TYPE abap_bool
        line_feed    TYPE string.

  PRIVATE SECTION.
    CONSTANTS c_ddlx_tabname TYPE tabname VALUE 'DDLXSRC_SRC'.

    DATA line_feed TYPE string.
    DATA is_multiline TYPE abap_bool.

    METHODS read_ddlx
      IMPORTING
        !name         TYPE zif_adcoset_ty_global=>ty_ddlxname
      RETURNING
        VALUE(result) TYPE string
      RAISING
        zcx_adcoset_src_code_read.
ENDCLASS.


CLASS zcl_adcoset_scr_ddlx IMPLEMENTATION.
  METHOD constructor.
    me->line_feed    = line_feed.
    me->is_multiline = is_multiline.
  ENDMETHOD.

  METHOD zif_adcoset_src_code_reader~get_source_code.
    DATA source TYPE TABLE OF string.
    DATA indexes TYPE zif_adcoset_source_code=>ty_line_indexes.

    DATA(source_text) = read_ddlx( name ).

    IF is_multiline = abap_true.
      indexes = zcl_adcoset_string_util=>determine_line_indexes( source_text = source_text
                                                                 line_feed   = line_feed ).
      source = VALUE #( ( source_text ) ).
    ELSE.
      SPLIT source_text AT line_feed INTO TABLE source.
    ENDIF.

    result = NEW zcl_adcoset_source_code( source        = source
                                          line_indexes  = indexes
                                          comment_regex = zif_adcoset_c_global=>c_cds_comment_regex ).
  ENDMETHOD.

  METHOD read_ddlx.
    DATA(ddlx_name) = to_upper( name ).

    SELECT SINGLE source
      FROM (c_ddlx_tabname)
      WHERE ddlxname = @ddlx_name
        AND version = 'A' " only active source
      INTO @result.

    IF sy-subrc <> 0 OR result IS INITIAL.
      RAISE EXCEPTION TYPE zcx_adcoset_src_code_read.
    ENDIF.

    " handle line feed
    result = zcl_adcoset_string_util=>adjust_line_endings( text      = result
                                                           line_feed = line_feed ).
  ENDMETHOD.
ENDCLASS.
