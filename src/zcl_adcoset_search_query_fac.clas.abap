"! <p class="shorttext synchronized">Factory for creating search queries</p>
CLASS zcl_adcoset_search_query_fac DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    "! <p class="shorttext synchronized">Creates query instance</p>
    CLASS-METHODS create_query
      IMPORTING
        parallel_processing TYPE zif_adcoset_ty_global=>ty_parl_processing OPTIONAL
        !scope              TYPE REF TO zif_adcoset_search_scope
        settings            TYPE zif_adcoset_ty_global=>ty_search_settings_int
      RETURNING
        VALUE(result)       TYPE REF TO zif_adcoset_search_query
      RAISING
        zcx_adcoset_static_error.
ENDCLASS.


CLASS zcl_adcoset_search_query_fac IMPLEMENTATION.
  METHOD create_query.
    DATA task_runner TYPE REF TO zif_adcoset_parl_task_runner.

    DATA(run_parallel) = parallel_processing-enabled.

    IF scope->count( ) < zif_adcoset_c_global=>c_parl_proc_min_objects.
      run_parallel = abap_false.
    ENDIF.

    IF run_parallel = abap_true.
      TRY.
          task_runner = zcl_adcoset_parl_task_runner=>new( server_group   = parallel_processing-server_group
*                                                           task_prefix    =
*                                                           max_tasks      = 10
                                                           " TODO: move handler_class/handler_method to parallel settings???
                                                           handler_class  = 'ZCL_ADCOSET_SEARCH_ENGINE'
                                                           handler_method = 'RUN_CODE_SEARCH_ARFC' ).

          IF settings-is_adt = abap_true.
            DATA(max_objs_for_parl_proc) = zcl_adcoset_search_settings=>get_settings( )-parallel_proc_pack_size.
          ENDIF.

          " update the package size
          scope->configure_package_size( max_task_count = task_runner->get_max_tasks( )
                                         max_objects    = max_objs_for_parl_proc ).
        CATCH zcx_adcoset_static_error INTO DATA(error) ##NEEDED.
          zcl_adcoset_log=>add_exception( error ).
      ENDTRY.
    ENDIF.

    result = COND #(
      WHEN task_runner IS BOUND
      THEN NEW zcl_adcoset_parl_search_query( task_runner = task_runner
                                              scope       = scope
                                              settings    = settings )
      ELSE NEW zcl_adcoset_search_query( scope           = scope
                                         settings        = settings-basic_settings
                                         custom_settings = settings-custom_settings
                                         matchers        = zcl_adcoset_matcher_factory=>create_matchers(
                                                               pattern_config = settings-pattern_config  ) ) ).
  ENDMETHOD.
ENDCLASS.
