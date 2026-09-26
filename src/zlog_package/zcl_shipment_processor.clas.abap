class ZCL_SHIPMENT_PROCESSOR definition
  public
  final
  create public .

public section.

  methods VALIDATE_QUANTITIES
    importing
      !IV_SHIPMENT_ID type ZSHIP_ID
    raising
      ZCX_LOGISTICS_ERROR .
  methods CALCULATE_TOTAL_VALUE
    importing
      !IV_SHIPMENT_ID type ZSHIP_ID
    returning
      value(RV_TOTAL) type DMBTR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SHIPMENT_PROCESSOR IMPLEMENTATION.


  method CALCULATE_TOTAL_VALUE.
    DATA: lt_items TYPE STANDARD TABLE OF zlog_ship_item.

    rv_total = 0.

    " Fetch items for the given shipment from our custom DDIC table
    SELECT * FROM zlog_ship_item
      INTO TABLE lt_items
      WHERE shipment_id = iv_shipment_id.

    LOOP AT lt_items INTO DATA(ls_item).
      rv_total = rv_total + ls_item-net_value.
    ENDLOOP.
  endmethod.


  method VALIDATE_QUANTITIES.
    DATA: lt_items TYPE STANDARD TABLE OF zlog_ship_item.

    " Fetch items for the given shipment
    SELECT * FROM zlog_ship_item
      INTO TABLE lt_items
      WHERE shipment_id = iv_shipment_id.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    " Business Rule: Check if delivered quantity exceeds ordered quantity
    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-delv_qty > ls_item-order_qty.
        RAISE EXCEPTION TYPE zcx_logistics_error.
      ENDIF.
    ENDLOOP.
  endmethod.
ENDCLASS.
