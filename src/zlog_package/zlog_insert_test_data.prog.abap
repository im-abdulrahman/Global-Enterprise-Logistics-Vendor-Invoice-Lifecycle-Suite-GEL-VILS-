*&---------------------------------------------------------------------*
*& Report ZLOG_INSERT_TEST_DATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zlog_insert_test_data.

DATA: ls_hdr  TYPE zlog_ship_hdr,
      lt_item TYPE STANDARD TABLE OF zlog_ship_item,
      ls_item TYPE zlog_ship_item.

" 1. Insert Header Record (Matched to ZLOG_SHIP_HDR fields)
ls_hdr-shipment_id   = 'SHIP001'.
ls_hdr-status        = 'A'.

MODIFY zlog_ship_hdr FROM ls_hdr.

IF sy-subrc = 0.
  WRITE: / 'Header record inserted successfully!'.
ELSE.
  WRITE: / 'Error inserting header record.' COLOR 6.
ENDIF.

" 2. Insert Item Records (Matched to ZLOG_SHIP_ITEM fields with ITEM_NO)
CLEAR ls_item.
ls_item-shipment_id = 'SHIP001'.
ls_item-item_no     = '0001'.
ls_item-order_qty   = 10.
ls_item-delv_qty    = 8.
ls_item-net_value   = 50000.
APPEND ls_item TO lt_item.

CLEAR ls_item.
ls_item-shipment_id = 'SHIP001'.
ls_item-item_no     = '0002'.
ls_item-order_qty   = 5.
ls_item-delv_qty    = 5.
ls_item-net_value   = 25000.
APPEND ls_item TO lt_item.

MODIFY zlog_ship_item FROM TABLE lt_item.

IF sy-subrc = 0.
  WRITE: / 'Item records inserted successfully!'.
  COMMIT WORK.
  WRITE: / 'Data committed successfully. You can now run your ALV Report!'.
ELSE.
  WRITE: / 'Error inserting item records.' COLOR 6.
ENDIF.
