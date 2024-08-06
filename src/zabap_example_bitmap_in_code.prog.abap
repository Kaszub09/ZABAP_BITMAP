*&---------------------------------------------------------------------*
*& Report zabap_example_bitmap_in_code
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_example_bitmap_in_code.
PARAMETERS: p_dummy TYPE i. "Dummy to be able to display container

AT SELECTION-SCREEN OUTPUT.
  DATA(orange) = VALUE zcl_zabap_bitmap=>t_pixel( red = 255 green = 201 blue = 14 ).
  DATA(green) = VALUE zcl_zabap_bitmap=>t_pixel( red = 34 green = 177 blue = 76 ).
  DATA(white) = VALUE zcl_zabap_bitmap=>t_pixel( red = 255 green = 255 blue = 255 ).
  DATA(black) = VALUE zcl_zabap_bitmap=>t_pixel( ).

  DATA(bitmap) = zcl_zabap_bitmap=>create_new( height = 8 width = 8 ).
  "We create image bottom to top, left to right
  bitmap->set_pixel_row( row = 0 pixel_row = VALUE #( ( black ) ( black ) ( black ) ( black ) ( black ) ( black ) ( black ) ( black ) ) ).
  bitmap->set_pixel_row( row = 1 pixel_row = VALUE #( ( black ) ( black ) ( black ) ( orange ) ( black ) ( orange ) ( black ) ( black ) ) ).
  bitmap->set_pixel_row( row = 2 pixel_row = VALUE #( ( black ) ( black ) ( white ) ( white ) ( white ) ( white ) ( white ) ( black ) ) ).
  bitmap->set_pixel_row( row = 3 pixel_row = VALUE #( ( black ) ( black ) ( white ) ( white ) ( white ) ( white ) ( white ) ( black ) ) ).
  bitmap->set_pixel_row( row = 4 pixel_row = VALUE #( ( black ) ( black ) ( white ) ( black ) ( black ) ( black ) ( black ) ( black ) ) ).
  bitmap->set_pixel_row( row = 5 pixel_row = VALUE #( ( black ) ( orange ) ( green ) ( black ) ( black ) ( black ) ( black ) ( black ) ) ).
  bitmap->set_pixel_row( row = 6 pixel_row = VALUE #( ( black ) ( black ) ( green ) ( black ) ( black ) ( black ) ( black ) ( black ) ) ).
  bitmap->set_pixel_row( row = 7 pixel_row = VALUE #( ( black ) ( black ) ( black ) ( black ) ( black ) ( black ) ( black ) ( black ) ) ).


  bitmap->display_in_container( container = NEW cl_gui_docking_container( ratio = 95 side = cl_gui_docking_container=>dock_at_top )
      display_mode = cl_gui_picture=>display_mode_fit_center ).
