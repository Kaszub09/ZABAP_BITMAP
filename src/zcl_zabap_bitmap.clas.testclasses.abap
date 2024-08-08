CLASS ltcl_flip DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup.

    CLASS-DATA:
      before_flip_4x6          TYPE xstring,
      flipped_horizontally_4x6 TYPE xstring,
      flipped_vertically_4x6   TYPE xstring,
      before_flip_3x7          TYPE xstring,
      flipped_vertically_3x7   TYPE xstring,
      flipped_horizontally_3x7 TYPE xstring.

    METHODS:
      flip_vertically_even FOR TESTING,
      flip_horizontally_even  FOR TESTING,
      flip_vertically_odd FOR TESTING,
      flip_horizontally_odd  FOR TESTING.

ENDCLASS.

CLASS ltcl_flip IMPLEMENTATION.
  METHOD class_setup.
    before_flip_4x6 = |424D8600000000000000360000002800| &
                      |00000600000004000000010018000000| &
                      |00000000000000000000000000000000| &
                      |000000000000000000FFFFFF000000FF| &
                      |0000FF0000FF00000000000000000000| &
                      |000000FFFFFFFFFFFFFF0000000000FF| &
                      |0000FF00FFFFFFFFFFFF0000FFFFFFFF| &
                      |000000FF00FFFFFFFFFFFF0000FF0000| &
                      |FF0000FF0000|.
    flipped_horizontally_4x6 = |424D8600000000000000360000002800| &
                               |00000600000004000000010018000000| &
                               |00000000000000000000000000000000| &
                               |000000000000FF0000FF0000FF000000| &
                               |0000FFFFFF0000000000FF0000FFFFFF| &
                               |FFFFFF0000000000000000000000FFFF| &
                               |FF0000FFFFFFFFFFFFFF00FF0000FF00| &
                               |00000000FF0000FF0000FFFFFFFFFFFF| &
                               |FF00FF000000|.
    flipped_vertically_4x6 = |424D8600000000000000360000002800| &
                             |00000600000004000000010018000000| &
                             |00000000000000000000000000000000| &
                             |00000000000000FF00FFFFFFFFFFFF00| &
                             |00FF0000FF0000FF000000FF0000FF00| &
                             |FFFFFFFFFFFF0000FFFFFFFF00000000| &
                             |00000000000000FFFFFFFFFFFFFF0000| &
                             |0000000000FFFFFF000000FF0000FF00| &
                             |00FF00000000|.
    before_flip_3x7 = |424D7E00000000000000360000002800| &
                      |00000700000003000000010018000000| &
                      |00000000000000000000000000000000| &
                      |000000000000FF0000FFFFFFFFFFFF00| &
                      |0000000000000000000000000000FFFF| &
                      |FF0000FFFFFFFFFFFFFF00FF0000FF00| &
                      |0000000000000000FF0000FF0000FFFF| &
                      |FFFFFFFFFF00FF00000000000000|.
    flipped_vertically_3x7 = |424D7E00000000000000360000002800| &
                             |00000700000003000000010018000000| &
                             |00000000000000000000000000000000| &
                             |0000000000000000FF0000FF0000FFFF| &
                             |FFFFFFFFFF00FF00000000000000FFFF| &
                             |FF0000FFFFFFFFFFFFFF00FF0000FF00| &
                             |000000000000FF0000FFFFFFFFFFFF00| &
                             |0000000000000000000000000000|.
    flipped_horizontally_3x7 = |424D7E00000000000000360000002800| &
                               |00000700000003000000010018000000| &
                               |00000000000000000000000000000000| &
                               |00000000000000000000000000000000| &
                               |0000FFFFFFFFFFFFFF00000000000000| &
                               |0000FF0000FF00FFFFFFFFFFFF0000FF| &
                               |FFFFFF00000000000000FF00FFFFFFFF| &
                               |FFFF0000FF0000FF0000FF000000|.
  ENDMETHOD.

  METHOD flip_horizontally_even.
    DATA(bitmap) = zcl_zabap_bitmap=>create_from_bitmap( before_flip_4x6 ).
    bitmap->flip_horizontally( ).
    cl_abap_unit_assert=>assert_equals( act = bitmap->get_as_xstring( ) exp = flipped_horizontally_4x6 ).
  ENDMETHOD.

  METHOD flip_horizontally_odd.
    DATA(bitmap) = zcl_zabap_bitmap=>create_from_bitmap( before_flip_3x7 ).
    bitmap->flip_horizontally( ).
    cl_abap_unit_assert=>assert_equals( act = bitmap->get_as_xstring( ) exp = flipped_horizontally_3x7 ).
  ENDMETHOD.

  METHOD flip_vertically_even.
    DATA(bitmap) = zcl_zabap_bitmap=>create_from_bitmap( before_flip_4x6 ).
    bitmap->flip_vertically( ).
    cl_abap_unit_assert=>assert_equals( act = bitmap->get_as_xstring( ) exp = flipped_vertically_4x6 ).
  ENDMETHOD.

  METHOD flip_vertically_odd.
    DATA(bitmap) = zcl_zabap_bitmap=>create_from_bitmap( before_flip_3x7 ).
    bitmap->flip_vertically( ).
    cl_abap_unit_assert=>assert_equals( act = bitmap->get_as_xstring( ) exp = flipped_vertically_3x7 ).
  ENDMETHOD.
ENDCLASS.
