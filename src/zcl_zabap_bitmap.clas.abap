CLASS zcl_zabap_bitmap DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF t_pixel,
        blue  TYPE int1,
        green TYPE int1,
        red   TYPE int1,
      END OF t_pixel,
      tt_pixel TYPE STANDARD TABLE OF t_pixel WITH EMPTY KEY.

    CLASS-METHODS:
      create_new IMPORTING height TYPE i width TYPE i RETURNING VALUE(bitmap_obj) TYPE REF TO zcl_zabap_bitmap,
      create_from_bitmap IMPORTING bitmap TYPE xstring RETURNING VALUE(bitmap_obj) TYPE REF TO zcl_zabap_bitmap RAISING zcx_zabap_bitmap.

    METHODS:
      "! @parameter row | <p class="shorttext synchronized" lang="en">Indexed from 0, bottom to top.</p>
      set_pixel_row IMPORTING row TYPE i pixel_row TYPE tt_pixel,
      "! @parameter row | <p class="shorttext synchronized" lang="en">Indexed from 0, bottom to top.</p>
      "! @parameter col | <p class="shorttext synchronized" lang="en">Indexed from 0, left to right.</p>
      set_pixel IMPORTING row TYPE i col TYPE i pixel TYPE t_pixel,
      "! @parameter row | <p class="shorttext synchronized" lang="en">Indexed from 0, bottom to top.</p>
      "! @parameter col | <p class="shorttext synchronized" lang="en">Indexed from 0, left to right.</p>
      get_pixel IMPORTING row TYPE i col TYPE i RETURNING VALUE(pixel) TYPE t_pixel,
      get_as_xstring RETURNING VALUE(bitmap) TYPE xstring.

  PRIVATE SECTION.
    TYPES:
      t_one_byte   TYPE x LENGTH 1,
      t_two_bytes  TYPE x LENGTH 2,
      t_four_bytes TYPE x LENGTH 4,
      "! https://en.wikipedia.org/wiki/BMP_file_format#DIB_header_(bitmap_information_header)
      "! Windows BITMAPINFOHEADER
      BEGIN OF t_xheader,
        "BITMAP FILE HEADER
        file_type             TYPE t_two_bytes, "Expected BM for Windows
        file_size             TYPE t_four_bytes,
        reserved_1            TYPE t_two_bytes,
        reserved_2            TYPE t_two_bytes,
        pixel_array_offset    TYPE t_four_bytes,
        "DIB HEADER
        header_size           TYPE t_four_bytes, "Should be 40 bytes
        width                 TYPE t_four_bytes, "Signed integer
        height                TYPE t_four_bytes, "Signed integer
        color_planes          TYPE t_two_bytes, "Should be 1
        bits_per_pixel        TYPE t_two_bytes, "Expected 24
        compression           TYPE t_four_bytes, "Expected 0 - uncompressed
        image_size            TYPE t_four_bytes, "Can be dummy 0
        horizontal_resolution TYPE t_four_bytes, "The horizontal resolution of the image. (pixel per metre, signed integer)
        vertical_resolution   TYPE t_four_bytes, "The vertical resolution of the image. (pixel per metre, signed integer)
        colors_palette_size   TYPE t_four_bytes, "The number of colors in the color palette, or 0 to default to 2n
        important_colors_used TYPE t_four_bytes, "The number of important colors used, or 0 when every color is important; generally ignored
      END OF t_xheader.

    METHODS:
      parse_header IMPORTING xheader TYPE xstring RAISING zcx_zabap_bitmap,
      validate_correct_bmp IMPORTING xheader TYPE t_xheader RAISING zcx_zabap_bitmap,
      parse_pixel_array IMPORTING pixels_xstring TYPE xstring,
      int_to_le4 IMPORTING int TYPE i RETURNING VALUE(le) TYPE t_four_bytes,
      le_to_int IMPORTING le TYPE xsequence RETURNING VALUE(int) TYPE i.

    DATA:
      width  TYPE i,
      height TYPE i,
      pixels TYPE STANDARD TABLE OF t_pixel WITH EMPTY KEY.
ENDCLASS.

CLASS zcl_zabap_bitmap IMPLEMENTATION.
  METHOD create_new.
    bitmap_obj = NEW #( ).

    bitmap_obj->width = width.
    bitmap_obj->height = height.

    DO width * height TIMES.
      APPEND VALUE #( red = 255 green = 255 blue = 255 ) TO bitmap_obj->pixels.
    ENDDO.
  ENDMETHOD.

  METHOD create_from_bitmap.
    bitmap_obj = NEW #( ).

    DATA(bitmap_header) = bitmap(54).
    bitmap_obj->parse_header( bitmap_header ).

    DATA(pixel_array_length) = xstrlen( bitmap ) - 54.
    DATA(bitmap_pixel_array) = bitmap+54(pixel_array_length).
    bitmap_obj->parse_pixel_array( bitmap_pixel_array ).
  ENDMETHOD.

  METHOD parse_header.
    "Cast xstring to struct
    DATA header_54_bytes_xstring TYPE x LENGTH 54.
    FIELD-SYMBOLS <xheader> TYPE t_xheader.

    header_54_bytes_xstring = xheader(54).
    ASSIGN header_54_bytes_xstring TO <xheader> CASTING.

    DATA(header_size) = le_to_int( <xheader>-header_size ).
    width = le_to_int( <xheader>-width ).
    height = le_to_int( <xheader>-height ).

    validate_correct_bmp( <xheader> ).
  ENDMETHOD.

  METHOD validate_correct_bmp.
    IF xheader-file_type <> '424D'.
      RAISE EXCEPTION TYPE zcx_zabap_bitmap EXPORTING custom_message = |Expected 'BM' file type (424D)|.
    ENDIF.
    IF le_to_int( xheader-bits_per_pixel ) <> 24.
      RAISE EXCEPTION TYPE zcx_zabap_bitmap EXPORTING custom_message = |Expected 24 bits per pixel|.
    ENDIF.
    IF le_to_int( xheader-compression ) <> 0.
      RAISE EXCEPTION TYPE zcx_zabap_bitmap EXPORTING custom_message = |Expected uncompressed file|.
    ENDIF.
  ENDMETHOD.

  METHOD parse_pixel_array.
    DATA x_3 TYPE x LENGTH 3.
    FIELD-SYMBOLS <pixel> TYPE t_pixel.

    DATA(offset) = 0.
    DATA(row) = 0.
    DATA(col) = 0.
    DATA(row_padding) =  ( 4 - ( ( width * 3 ) MOD 4 ) ) MOD 4. "Row must be multiple of four

    WHILE row < height. "rows are bottom to top
      WHILE col < width. "cols are left to right
        x_3 = pixels_xstring+offset(3). "pixel order is Blue, Green, Red
        ASSIGN x_3 TO <pixel> CASTING.
        APPEND <pixel> TO pixels.
        col = col + 1.
        offset = offset + 3.
      ENDWHILE.

      offset = offset + row_padding.
      row = row + 1.
      col = 0.
    ENDWHILE.
  ENDMETHOD.

  METHOD get_pixel.
    pixel = pixels[ row * width + col + 1 ].
  ENDMETHOD.

  METHOD set_pixel.
    pixels[ row * width + col + 1 ] = pixel.
  ENDMETHOD.

  METHOD set_pixel_row.
    DATA(row_index) = row * width + 1.
    DATA(col) = 0.
    WHILE col < width.
      pixels[ row_index + col ] = pixel_row[ col + 1 ].
      col = col + 1.
    ENDWHILE.
  ENDMETHOD.


  METHOD get_as_xstring.
    TYPES:  t_xpixel TYPE x LENGTH 3.
    DATA xheader TYPE x LENGTH 54.

    xheader = |424D| "File type, 'BM'
        && |{ int_to_le4( lines( pixels ) * 3 + 54 ) }| "Size in bytes, 54 for header + 3 * pixels
        && |00000000| "reserved - empty
        && |36000000| "Pixels array offset, constant 54 since that's full header size
        && |28000000| "DIB header size, constant 40
        && |{ int_to_le4( width ) }{ int_to_le4( height ) }|
        && |0100| "color planes = 1
        && |1800| "Bits per pixel = 24
        && |00000000| "compression mode = 0
        && |00000000| "Image size - dummy 0
        && |0000000000000000| "Resolution (px per m)
        && |0000000000000000|. "Rest of data
    bitmap = xheader.

    DATA(current_col) = 0.
    LOOP AT pixels REFERENCE INTO DATA(pixel).
      current_col = current_col + 1.
      FIELD-SYMBOLS <xpixel> TYPE t_xpixel.
      ASSIGN pixel->* TO <xpixel> CASTING.
      bitmap = |{ bitmap }{ <xpixel> }|.

      IF current_col = width.
        DO (  4 - ( ( width * 3 ) MOD 4 ) ) MOD 4 TIMES.
          bitmap = |{ bitmap }00|.
        ENDDO.
        current_col = 0.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD int_to_le4.
    le = zcl_zabap_bytes_conv=>system_to_le( zcl_zabap_bytes_conv=>int_to_system( int ) ).
  ENDMETHOD.

  METHOD le_to_int.
    int = zcl_zabap_bytes_conv=>system_to_int( zcl_zabap_bytes_conv=>le_to_system( le ) ).
  ENDMETHOD.

ENDCLASS.
