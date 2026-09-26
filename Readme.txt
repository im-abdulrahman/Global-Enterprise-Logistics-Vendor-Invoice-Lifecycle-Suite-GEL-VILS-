Project Title: GEL-VIL Suite / Global Enterprise Logistics & Vendor Invoice Lifecycle Suite (GEL-VILS)
Environment: SAP ECC / S/4HANA (ABAP Workbench, DDIC, OOP, ALV, Smart Forms/Adobe Forms)
description: Developed an end-to-end logistics automation suite to process inbound vendor shipments, validate line items via custom DDIC tables, and streamline invoice clearing.

************************************************************************************************

#1: PACKAGES:
Super Package Name : ZLOG_SUPER_PACKAGE
1 Sub Package Name : ZLOG_PACKAGE

#2: DDIC:
TABLE 01: ZLOG_SHIP_HDR
TABLE 02: ZLOG_SHIP_ITEM

#3: Exception handling/ error CLASSES:
Exception Class : ZCX_LOGISTICS_ERROR
Shipment Processing Business Logic : ZCL_SHIPMENT_PROCESSOR

#4 : Tax Calculation:
Function Group : Z_LOGISTICS_FG

#5 : Programs:
Test Data Upload HDR Table : zlog_insert_test_data
ALV Report : ZLOG_SHIPMENT_REPORT
TCODE ALV Report : Enterprise Shipment ALV Report

************************************************************************************************