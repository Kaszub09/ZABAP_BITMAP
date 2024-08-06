CLASS zcl_zabap_bytes_conv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      class_constructor,
      reverse_byte_order IMPORTING bytes TYPE xsequence RETURNING VALUE(reversed) TYPE xstring,
      le_to_system IMPORTING le TYPE xsequence RETURNING VALUE(system) TYPE xstring,
      be_to_system IMPORTING be TYPE xsequence RETURNING VALUE(system) TYPE xstring,
      system_to_le IMPORTING system TYPE xsequence RETURNING VALUE(le) TYPE xstring,
      system_to_be IMPORTING system TYPE xsequence RETURNING VALUE(be) TYPE xstring,
      system_to_int IMPORTING system TYPE xsequence RETURNING VALUE(int) TYPE i,
      int_to_system IMPORTING int TYPE i RETURNING VALUE(system) TYPE xstring.

    CLASS-DATA:
      is_system_le TYPE abap_bool READ-ONLY.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zabap_bytes_conv IMPLEMENTATION.

  METHOD be_to_system.
    IF is_system_le = abap_true.
      system = reverse_byte_order( be ).
    ELSE.
      system = be.
    ENDIF.
  ENDMETHOD.

  METHOD class_constructor.
    "Determine system endianness
    DATA(one) = CONV int4( 1 ).
    FIELD-SYMBOLS <xstring> TYPE x.
    ASSIGN one TO <xstring> CASTING.

    "We should have 00000000 00000000 00000000 00000001 in BE and 00000001 00000000 00000000 00000000 in LE
    is_system_le = COND #( WHEN <xstring>(1) = 1 THEN abap_true ELSE abap_false ).
  ENDMETHOD.

  METHOD le_to_system.
    IF is_system_le = abap_true.
      system = le.
    ELSE.
      system = reverse_byte_order( le ).
    ENDIF.
  ENDMETHOD.

  METHOD reverse_byte_order.
    "Some optimization for common cases
    CASE xstrlen( bytes ).
      WHEN 2.
        CONCATENATE bytes+1(1) bytes(1) INTO reversed IN BYTE MODE.

      WHEN 4.
        CONCATENATE bytes+3(1) bytes+2(1) bytes+1(1) bytes(1) INTO reversed IN BYTE MODE.

      WHEN 8.
        CONCATENATE bytes+7(1) bytes+6(1) bytes+5(1) bytes+4(1) bytes+3(1) bytes+2(1) bytes+1(1) bytes(1) INTO reversed IN BYTE MODE.

      WHEN OTHERS.
        DATA(index) = xstrlen( bytes ) - 1.
        WHILE index >= 0 .
          reversed = |{ reversed }{ bytes+index(1) }|.
          index = index - 1.
        ENDWHILE.
    ENDCASE.
  ENDMETHOD.

  METHOD system_to_be.
    IF is_system_le = abap_true.
      be = reverse_byte_order( system ).
    ELSE.
      be = system.
    ENDIF.
  ENDMETHOD.

  METHOD system_to_int.
    FIELD-SYMBOLS <int4> TYPE int4.
    DATA four_bytes TYPE x LENGTH 4.
    four_bytes = system.

    ASSIGN four_bytes TO <int4> CASTING.
    int = <int4>.
  ENDMETHOD.

  METHOD system_to_le.
    IF is_system_le = abap_true.
      le = system.
    ELSE.
      le = reverse_byte_order( system ).
    ENDIF.
  ENDMETHOD.

  METHOD int_to_system.
    FIELD-SYMBOLS <system> TYPE x.
    ASSIGN int TO <system> CASTING.
    system = <system>.
  ENDMETHOD.

ENDCLASS.
