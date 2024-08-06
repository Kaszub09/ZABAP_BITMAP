
CLASS ltcl_zabap_bytes_conv DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF t_test_data,
        int TYPE i,
        le  TYPE xstring,
        be  TYPE xstring,
      END OF t_test_data,
      tt_test_data TYPE STANDARD TABLE OF t_test_data WITH EMPTY KEY.
    METHODS:
      reverse_order FOR TESTING,
      int_to_system FOR TESTING,
      system_to_int FOR TESTING,
      le_to_system FOR TESTING,
      be_to_system FOR TESTING,
      system_to_le FOR TESTING,
      system_to_be FOR TESTING.

ENDCLASS.


CLASS ltcl_zabap_bytes_conv IMPLEMENTATION.

  METHOD reverse_order.
    DATA(test_data) = VALUE tt_test_data(
      ( le = '' be = '' )
      ( le = 'AF' be = 'AF' )
      ( le = 'AABB' be = 'BBAA' )
      ( le = 'AABBCCDD' be = 'DDCCBBAA' )
      ( le = '1122334455' be = '5544332211' )  ).

    LOOP AT test_data REFERENCE INTO DATA(test).
      cl_abap_unit_assert=>assert_equals( act = zcl_zabap_bytes_conv=>reverse_byte_order( test->le ) exp = test->be ).
    ENDLOOP.
  ENDMETHOD.

  METHOD int_to_system.
    DATA(test_data) = VALUE tt_test_data(
        ( int = 0 le = '00000000' be = '00000000' )
        ( int = 1 le = '01000000' be = '00000001' )
        ( int = 1234567890 le = 'D2029649' be = '499602D2' )  ).

    LOOP AT test_data REFERENCE INTO DATA(test).
      cl_abap_unit_assert=>assert_equals( msg = |{ test->int }| act = zcl_zabap_bytes_conv=>int_to_system( test->int )
        exp = COND #( WHEN zcl_zabap_bytes_conv=>is_system_le = abap_true THEN test->le ELSE test->be ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD system_to_int.
    DATA(test_data) = VALUE tt_test_data(
        ( int = 0 le = '00000000' be = '00000000' )
        ( int = 1 le = '01000000' be = '00000001' )
        ( int = 1234567890 le = 'D2029649' be = '499602D2' )  ).

    LOOP AT test_data REFERENCE INTO DATA(test).
      cl_abap_unit_assert=>assert_equals( msg = |{ test->int }| exp = test->int act = zcl_zabap_bytes_conv=>system_to_int(
        COND #( WHEN zcl_zabap_bytes_conv=>is_system_le = abap_true THEN test->le ELSE test->be ) ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD be_to_system.
    DATA(test_data) = VALUE tt_test_data( ( le = '01000000' be = '00000001' ) ( le = '01AAFF' be = 'FFAA01' ) ).

    LOOP AT test_data REFERENCE INTO DATA(test).
      cl_abap_unit_assert=>assert_equals( act = zcl_zabap_bytes_conv=>be_to_system( test->be )
        exp = COND #( WHEN zcl_zabap_bytes_conv=>is_system_le = abap_true THEN test->le ELSE test->be ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD le_to_system.
    DATA(test_data) = VALUE tt_test_data( ( le = '01000000' be = '00000001' ) ( le = '01AAFF' be = 'FFAA01' )  ).

    LOOP AT test_data REFERENCE INTO DATA(test).
      cl_abap_unit_assert=>assert_equals( act = zcl_zabap_bytes_conv=>le_to_system( test->le )
        exp = COND #( WHEN zcl_zabap_bytes_conv=>is_system_le = abap_true THEN test->le ELSE test->be ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD system_to_be.
    DATA(test_data) = VALUE tt_test_data( ( le = '01000000' be = '00000001' ) ( le = '01AAFF' be = 'FFAA01' )  ).

    LOOP AT test_data REFERENCE INTO DATA(test).
      cl_abap_unit_assert=>assert_equals( exp = test->be act = zcl_zabap_bytes_conv=>system_to_be(
        COND #( WHEN zcl_zabap_bytes_conv=>is_system_le = abap_true THEN test->le ELSE test->be ) ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD system_to_le.
    DATA(test_data) = VALUE tt_test_data( ( le = '01000000' be = '00000001' ) ( le = '01AAFF' be = 'FFAA01' )  ).

    LOOP AT test_data REFERENCE INTO DATA(test).
      cl_abap_unit_assert=>assert_equals( exp = test->le act = zcl_zabap_bytes_conv=>system_to_le(
        COND #( WHEN zcl_zabap_bytes_conv=>is_system_le = abap_true THEN test->le ELSE test->be ) ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
