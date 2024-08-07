CLASS zcl_zabap_bitmap_file DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      "! @parameter full_file_path | <p class="shorttext synchronized" lang="en">Should be valid BMP file with 24bit color and Windows format</p>
      open_bitmap IMPORTING full_file_path TYPE string RETURNING VALUE(bitmap) TYPE REF TO zcl_zabap_bitmap RAISING zcx_zabap_bitmap,
      create_bitmap_from_file IMPORTING full_file_path TYPE string RETURNING VALUE(bitmap) TYPE REF TO zcl_zabap_bitmap RAISING zcx_zabap_bitmap.

    METHODS:
      constructor IMPORTING bitmap_obj TYPE REF TO zcl_zabap_bitmap,
      display_in_container IMPORTING container TYPE REF TO cl_gui_container display_mode TYPE i DEFAULT cl_gui_picture=>display_mode_fit_center
                           RETURNING VALUE(picture_container) TYPE REF TO cl_gui_picture,
      "! @parameter lifetime | <p class="shorttext synchronized" lang="en">T - transaction</p>
      get_image_url IMPORTING lifetime TYPE c DEFAULT 'T' RETURNING VALUE(url) TYPE char255,
      export_to_file IMPORTING full_file_path TYPE string RAISING zcx_zabap_bitmap.

  PRIVATE SECTION.
    DATA:
         bitmap TYPE REF TO zcl_zabap_bitmap.
ENDCLASS.

CLASS zcl_zabap_bitmap_file IMPLEMENTATION.
  METHOD constructor.
    bitmap = bitmap_obj.
  ENDMETHOD.

  METHOD display_in_container.
    picture_container = NEW cl_gui_picture( container ).
    picture_container->set_display_mode( display_mode ).
    picture_container->load_picture_from_url_async( get_image_url( ) ).
  ENDMETHOD.

  METHOD get_image_url.
    DATA(solix) = cl_bcs_convert=>xstring_to_solix( bitmap->get_as_xstring( ) ).

    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type     = 'IMAGE'                 " MIME Type
        subtype  = space                " MIME Subtype
        lifetime = lifetime
      TABLES
        data     = solix
      CHANGING
        url      = url.
  ENDMETHOD.

  METHOD open_bitmap.
    "Load picture as binary
    DATA: it_binary_tab TYPE soli_tab.
    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = full_file_path            " Name of file
        filetype                = 'BIN'            " File Type (ASCII, Binary)
      CHANGING
        data_tab                = it_binary_tab                  " Transfer table for file contents
      EXCEPTIONS
        file_open_error         = 1                " File does not exist and cannot be opened
        file_read_error         = 2                " Error when reading file
        no_batch                = 3                " Cannot execute front-end function in background
        gui_refuse_filetransfer = 4                " Incorrect front end or error on front end
        invalid_type            = 5                " Incorrect parameter FILETYPE
        no_authority            = 6                " No upload authorization
        unknown_error           = 7                " Unknown error
        bad_data_format         = 8                " Cannot Interpret Data in File
        header_not_allowed      = 9                " Invalid header
        separator_not_allowed   = 10               " Invalid separator
        header_too_long         = 11               " Header information currently restricted to 1023 bytes
        unknown_dp_error        = 12               " Error when calling data provider
        access_denied           = 13               " Access to File Denied
        dp_out_of_memory        = 14               " Not enough memory in data provider
        disk_full               = 15               " Storage medium is full.
        dp_timeout              = 16               " Data provider timeout
        not_supported_by_gui    = 17               " GUI does not support this
        error_no_gui            = 18               " GUI not available
        OTHERS                  = 19
    ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_zabap_bitmap EXPORTING custom_message = |gui_upload error { sy-subrc }|.
    ENDIF.

    cl_bcs_convert=>bin_to_solix( EXPORTING it_soli = it_binary_tab IMPORTING et_solix = DATA(solix) ).
    bitmap = zcl_zabap_bitmap=>create_from_bitmap( cl_bcs_convert=>solix_to_xstring( solix ) ).
  ENDMETHOD.

  METHOD export_to_file.
    DATA(xstring) = bitmap->get_as_xstring( ).
    DATA(solix) = cl_bcs_convert=>xstring_to_solix( xstring ).

    cl_gui_frontend_services=>gui_download(
      EXPORTING
        bin_filesize              = xstrlen( xstring )                    " File length for binary files
        filename                  = full_file_path                     " Name of file
        filetype                  = 'BIN'                " File type (ASCII, binary ...)
      CHANGING
        data_tab                  = solix                     " Transfer table
      EXCEPTIONS
        file_write_error          = 1                    " Cannot write to file
        no_batch                  = 2                    " Cannot execute front-end function in background
        gui_refuse_filetransfer   = 3                    " Incorrect Front End
        invalid_type              = 4                    " Invalid value for parameter FILETYPE
        no_authority              = 5                    " No Download Authorization
        unknown_error             = 6                    " Unknown error
        header_not_allowed        = 7                    " Invalid header
        separator_not_allowed     = 8                    " Invalid separator
        filesize_not_allowed      = 9                    " Invalid file size
        header_too_long           = 10                   " Header information currently restricted to 1023 bytes
        dp_error_create           = 11                   " Cannot create DataProvider
        dp_error_send             = 12                   " Error Sending Data with DataProvider
        dp_error_write            = 13                   " Error Writing Data with DataProvider
        unknown_dp_error          = 14                   " Error when calling data provider
        access_denied             = 15                   " Access to File Denied
        dp_out_of_memory          = 16                   " Not enough memory in data provider
        disk_full                 = 17                   " Storage medium is full.
        dp_timeout                = 18                   " Data provider timeout
        file_not_found            = 19                   " Could not find file
        dataprovider_exception    = 20                   " General Exception Error in DataProvider
        control_flush_error       = 21                   " Error in Control Framework
        not_supported_by_gui      = 22                   " GUI does not support this
        error_no_gui              = 23                   " GUI not available
        OTHERS                    = 24 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_zabap_bitmap EXPORTING custom_message = |gui_download error { sy-subrc }|.
    ENDIF.
  ENDMETHOD.

  METHOD create_bitmap_from_file.
    "Load picture as binary
    DATA: it_binary_tab TYPE soli_tab.

    cl_gui_frontend_services=>gui_upload( EXPORTING filename = full_file_path filetype = 'BIN' CHANGING data_tab = it_binary_tab ).
    cl_bcs_convert=>bin_to_solix( EXPORTING it_soli = it_binary_tab IMPORTING et_solix = DATA(solix) ).

    "Conversion to BMP - requires IGS service. Call transaction SIGS with IGS_RFC_DEST to test
    DATA(converter) = NEW cl_fxs_image_processor( ).
    DATA(handle) = converter->add_image( cl_bcs_convert=>solix_to_xstring( solix ) ).
    converter->get_info( EXPORTING iv_handle = handle IMPORTING ev_mimetype = DATA(mime_type) ).
    IF mime_type <> cl_fxs_mime_types=>co_image_bitmap.
      converter->convert( iv_handle = handle iv_format = cl_fxs_mime_types=>co_image_bitmap ).
    ENDIF.
    bitmap = zcl_zabap_bitmap=>create_from_bitmap( converter->get_image( iv_handle = handle ) ).
  ENDMETHOD.
ENDCLASS.
