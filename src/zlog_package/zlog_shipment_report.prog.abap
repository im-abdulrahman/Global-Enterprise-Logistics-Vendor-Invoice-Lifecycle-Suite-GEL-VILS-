*&---------------------------------------------------------------------*
*& Report ZLOG_SHIPMENT_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zlog_shipment_report.

TABLES: zlog_ship_hdr.

SELECT-OPTIONS: s_shipid FOR zlog_ship_hdr-shipment_id.

" 1. Enhanced Local Event Receiver Class
CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click
        FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,
      on_added_function
        FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD on_double_click.
    MESSAGE |Drill-down triggered for row index: { row }| TYPE 'I'.
  ENDMETHOD.

  METHOD on_added_function.
    CASE e_salv_function.
      WHEN 'PROCESS_BTN'.
        MESSAGE 'Custom Toolbar Button Clicked: Processing Shipments...' TYPE 'S'.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

" Extended structure with an Icon field for Traffic Lights
TYPES: BEGIN OF ty_item_disp,
         icon        TYPE icon-id,
         shipment_id TYPE zlog_ship_item-shipment_id,
         item_no     TYPE zlog_ship_item-item_no,
         matnr       TYPE zlog_ship_item-matnr,
         order_qty   TYPE zlog_ship_item-order_qty,
         delv_qty    TYPE zlog_ship_item-delv_qty,
         net_value   TYPE zlog_ship_item-net_value,
         meins       TYPE zlog_ship_item-meins,
         waers       TYPE zlog_ship_item-waers,
       END OF ty_item_disp.

DATA: gt_items     TYPE STANDARD TABLE OF zlog_ship_item,
      gt_disp      TYPE STANDARD TABLE OF ty_item_disp,
      go_processor TYPE REF TO zcl_shipment_processor,
      go_alv       TYPE REF TO cl_salv_table,
      go_events    TYPE REF TO cl_salv_events_table,
      go_listener  TYPE REF TO lcl_event_receiver,
      gx_exception TYPE REF TO zcx_logistics_error,
      gv_text      TYPE string.

START-OF-SELECTION.

  SELECT * FROM zlog_ship_item
    INTO TABLE gt_items
    WHERE shipment_id IN s_shipid.

  IF sy-subrc NE 0.
    MESSAGE 'No shipment records found.' TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " Populate display table and assign traffic light icons based on delivery ratio
  LOOP AT gt_items INTO DATA(ls_item).
    DATA(ls_disp) = CORRESPONDING ty_item_disp( ls_item ).

    IF ls_disp-delv_qty >= ls_disp-order_qty.
      ls_disp-icon = icon_green_light. " Fully Delivered
    ELSEIF ls_disp-delv_qty > 0.
      ls_disp-icon = icon_yellow_light. " Partially Delivered
    ELSE.
      ls_disp-icon = icon_red_light.    " Pending / Undelivered
    ENDIF.

    APPEND ls_disp TO gt_disp.
  ENDLOOP.

  CREATE OBJECT go_processor.

  TRY.
      LOOP AT gt_items INTO DATA(ls_val).
        go_processor->validate_quantities( iv_shipment_id = ls_val-shipment_id ).
      ENDLOOP.
    CATCH zcx_logistics_error INTO gx_exception.
      gv_text = gx_exception->get_text( ).
      MESSAGE gv_text TYPE 'E' DISPLAY LIKE 'E'.
      EXIT.
  ENDTRY.

  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_disp ).

      DATA(lo_functions) = go_alv->get_functions( ).
      lo_functions->set_all( abap_true ).

      " Enable specific custom toolbar function if using PF-Status or standard additions
      DATA(lo_columns) = go_alv->get_columns( ).
      lo_columns->set_optimize( abap_true ).

      " Format Icon Column
      TRY.
          DATA(lo_column) = CAST cl_salv_column_table( lo_columns->get_column( 'ICON' ) ).
          lo_column->set_short_text( 'Status' ).
          lo_column->set_medium_text( 'Status' ).
          lo_column->set_long_text( 'Status' ).
          lo_column->set_icon( abap_true ).
        CATCH cx_salv_not_found.
      ENDTRY.

      " Register Events (Double Click & Toolbar Actions)
      go_events = go_alv->get_event( ).
      CREATE OBJECT go_listener.
      SET HANDLER go_listener->on_double_click FOR go_events.
      SET HANDLER go_listener->on_added_function FOR go_events.

      go_alv->display( ).

    CATCH cx_root INTO DATA(lo_root).
      MESSAGE lo_root->get_text( ) TYPE 'E'.
  ENDTRY.
