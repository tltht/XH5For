module hdf5_contiguous_hyperslab_handler

use IR_Precision, only : I4P, I8P, R4P, R8P
#ifdef ENABLE_HDF5
use HDF5
#endif
use hdf5_handler
use xh5for_utils

implicit none

private

    type, extends(hdf5_handler_t) :: hdf5_contiguous_hyperslab_handler_t
    !-----------------------------------------------------------------
    !< HDF5 contiguous hyperslab handler
    !----------------------------------------------------------------- 
    contains
        procedure :: CalculateHyperSlabDimensions => hdf5_contiguous_hyperslab_handler_CalculateHyperSlabDimensions
        procedure :: WriteHyperSlab_I4P => hdf5_contiguous_hyperslab_handler_WriteHyperSlab_I4P
        procedure :: WriteHyperSlab_I8P => hdf5_contiguous_hyperslab_handler_WriteHyperSlab_I8P
        procedure :: WriteHyperSlab_R4P => hdf5_contiguous_hyperslab_handler_WriteHyperSlab_R4P
        procedure :: WriteHyperSlab_R8P => hdf5_contiguous_hyperslab_handler_WriteHyperSlab_R8P
        procedure :: ReadHyperSlab_I4P  => hdf5_contiguous_hyperslab_handler_ReadHyperSlab_I4P
        procedure :: ReadHyperSlab_I8P  => hdf5_contiguous_hyperslab_handler_ReadHyperSlab_I8P
        procedure :: ReadHyperSlab_R4P  => hdf5_contiguous_hyperslab_handler_ReadHyperSlab_R4P
        procedure :: ReadHyperSlab_R8P  => hdf5_contiguous_hyperslab_handler_ReadHyperSlab_R8P
        procedure :: WriteGeometry_R4P  => hdf5_contiguous_hyperslab_handler_WriteGeometry_R4P
        procedure :: WriteGeometry_R8P  => hdf5_contiguous_hyperslab_handler_WriteGeometry_R8P
        procedure :: ReadGeometry_R4P   => hdf5_contiguous_hyperslab_handler_ReadGeometry_R4P
        procedure :: ReadGeometry_R8P   => hdf5_contiguous_hyperslab_handler_ReadGeometry_R8P
        procedure :: WriteTopology_I4P  => hdf5_contiguous_hyperslab_handler_WriteTopology_I4P
        procedure :: WriteTopology_I8P  => hdf5_contiguous_hyperslab_handler_WriteTopology_I8P
        procedure :: ReadTopology_I4P   => hdf5_contiguous_hyperslab_handler_ReadTopology_I4P
        procedure :: ReadTopology_I8P   => hdf5_contiguous_hyperslab_handler_ReadTopology_I8P
        procedure :: WriteAttribute_I4P => hdf5_contiguous_hyperslab_handler_WriteAttribute_I4P
        procedure :: WriteAttribute_I8P => hdf5_contiguous_hyperslab_handler_WriteAttribute_I8P
        procedure :: WriteAttribute_R4P => hdf5_contiguous_hyperslab_handler_WriteAttribute_R4P
        procedure :: WriteAttribute_R8P => hdf5_contiguous_hyperslab_handler_WriteAttribute_R8P
        procedure :: ReadAttribute_I4P  => hdf5_contiguous_hyperslab_handler_ReadAttribute_I4P
        procedure :: ReadAttribute_I8P  => hdf5_contiguous_hyperslab_handler_ReadAttribute_I8P
        procedure :: ReadAttribute_R4P  => hdf5_contiguous_hyperslab_handler_ReadAttribute_R4P
        procedure :: ReadAttribute_R8P  => hdf5_contiguous_hyperslab_handler_ReadAttribute_R8P
        generic   :: WriteHyperSlab     => WriteHyperSlab_I4P, &
                                           WriteHyperSlab_I8P, &
                                           WriteHyperSlab_R4P, &
                                           WriteHyperSlab_R8P
        generic   :: ReadHyperSlab      => ReadHyperSlab_I4P, &
                                           ReadHyperSlab_I8P, &
                                           ReadHyperSlab_R4P, &
                                           ReadHyperSlab_R8P

    end type hdf5_contiguous_hyperslab_handler_t

public :: hdf5_contiguous_hyperslab_handler_t

contains


    subroutine hdf5_contiguous_hyperslab_handler_CalculateHyperSlabDimensions(this, Center, GlobalNumberOfData, LocalNumberOfData, DataOffset)
    !-----------------------------------------------------------------
    !< Calculate hyperslab dimensions for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN)  :: this                !< HDF5 contiguous hyperslab handler
        integer(I4P),                               intent(IN)  :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(HSIZE_T),                           intent(OUT) :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T),                           intent(OUT) :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T),                           intent(OUT) :: DataOffset          !< Data offset for current grid
    !----------------------------------------------------------------- 
    !< @TODO: face and edge attributes
#ifdef ENABLE_HDF5
        select case(Center)
            case (XDMF_ATTRIBUTE_CENTER_NODE)
                GlobalNumberOfData = int(this%SpatialGridDescriptor%GetGlobalNumberOfNodes(),HSIZE_T)
                LocalNumberOfData = int(this%SpatialGridDescriptor%GetNumberOfNodesFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
                DataOffset = int(this%SpatialGridDescriptor%GetNodeOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
            case (XDMF_ATTRIBUTE_CENTER_CELL)
                GlobalNumberOfData = int(this%SpatialGridDescriptor%GetGlobalNumberOfElements(),HSIZE_T)
                LocalNumberOfData = int(this%SpatialGridDescriptor%GetNumberOfElementsFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
                DataOffset = int(this%SpatialGridDescriptor%GetElementOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
            case (XDMF_ATTRIBUTE_CENTER_GRID)
                GlobalNumberOfData = int(this%MPIEnvironment%get_comm_size(),HSIZE_T)
                LocalNumberOfData = 1_HSIZE_T
                DataOffset = this%MPIEnvironment%get_rank()
            case Default
                GlobalNumberOfData = int(this%SpatialGridDescriptor%GetGlobalNumberOfNodes(),HSIZE_T)
                LocalNumberOfData = int(this%SpatialGridDescriptor%GetNumberOfNodesFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
                DataOffset = int(this%SpatialGridDescriptor%GetNodeOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        end select
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_CalculateHyperSlabDimensions


    subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_I4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes I4P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I4P),                               intent(IN) :: Values(:)           !< I4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Create filespace
        call H5Screate_simple_f(rank = 1,                     &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_INTEGER,              &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Write data
        call H5Dwrite_f(dset_id = dset_id,           &
                mem_type_id   = H5T_NATIVE_INTEGER,  &
                buf           = Values,              &
                dims          = HyperSlabSize,       &
                hdferr        = hdferror,            &
                file_space_id = filespace,           &
                mem_space_id  = memspace,            &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_I4P


    subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_I8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes I8P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I8P),                               intent(IN) :: Values(:)           !< I8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Create filespace
        call H5Screate_simple_f(rank = 1,                     &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_INTEGER,              &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Write data
        ! I8P does not have native type in Fortran HDF5
!        call H5Dwrite_f(dset_id = dset_id,           &
!                mem_type_id   = H5T_NATIVE_INTEGER,  &
!                buf           = Values,              &
!                dims          = HyperSlabSize,       &
!                hdferr        = hdferror,            &
!                file_space_id = filespace,           &
!                mem_space_id  = memspace,            &
!                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_I8P


    subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_R4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes R4P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R4P),                                  intent(IN) :: Values(:)           !< R4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Create filespace
        call H5Screate_simple_f(rank = 1,                     &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_REAL,                 &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Write data
        call H5Dwrite_f(dset_id = dset_id,        &
                mem_type_id   = H5T_NATIVE_REAL,  &
                buf           = Values,           &
                dims          = HyperSlabSize,    &
                hdferr        = hdferror,         &
                file_space_id = filespace,        &
                mem_space_id  = memspace,         &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_R4P


    subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_R8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes R4P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R8P),                                  intent(IN) :: Values(:)           !< R8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Create filespace
        call H5Screate_simple_f(rank = 1,                     &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_DOUBLE,               &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Write data
        call H5Dwrite_f(dset_id = dset_id,          &
                mem_type_id   = H5T_NATIVE_DOUBLE,  &
                buf           = Values,             &
                dims          = HyperSlabSize,      &
                hdferr        = hdferror,           &
                file_space_id = filespace,          &
                mem_space_id  = memspace,           &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteHyperSlab_R8P


    subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_I4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Read I4P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I4P), allocatable,                  intent(OUT) :: Values(:)          !< I4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
        integer                                                :: rank                !< Hyperslab rank 
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        rank = 1
        allocate(Values(HyperSlabSize(rank)))
        ! Create filespace
        call H5Screate_simple_f(rank = rank,                  &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Open dataset 
        call H5Dopen_f(loc_id = this%file_id,               &
                name     = '/'//trim(adjustl(DatasetName)), &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Read data
        call H5Dread_f(dset_id = dset_id,            &
                mem_type_id   = H5T_NATIVE_INTEGER,  &
                buf           = Values,              &
                dims          = HyperSlabSize,       &
                hdferr        = hdferror,            &
                file_space_id = filespace,           &
                mem_space_id  = memspace,            &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_I4P


    subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_I8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Read I8P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I8P), allocatable,                  intent(OUT) :: Values(:)          !< I8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
        integer                                                :: rank                !< Hyperslab rank 
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        rank = 1
        allocate(Values(HyperSlabSize(rank)))
        ! Create filespace
        call H5Screate_simple_f(rank = rank,                  &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Open dataset 
        call H5Dopen_f(loc_id = this%file_id,               &
                name     = '/'//trim(adjustl(DatasetName)), &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Read data
!        call H5Dread_f(dset_id = dset_id,            &
!                mem_type_id   = H5T_NATIVE_INTEGER,  &
!                buf           = Values,              &
!                dims          = HyperSlabSize,       &
!                hdferr        = hdferror,            &
!                file_space_id = filespace,           &
!                mem_space_id  = memspace,            &
!                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_I8P


    subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_R4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Read R4P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R4P), allocatable,                     intent(OUT) :: Values(:)          !< R4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
        integer                                                :: rank                !< Hyperslab rank 
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        rank = 1
        allocate(Values(HyperSlabSize(rank)))
        ! Create filespace
        call H5Screate_simple_f(rank = rank,                  &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Open dataset 
        call H5Dopen_f(loc_id = this%file_id,               &
                name     = '/'//trim(adjustl(DatasetName)), &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Read data
        call H5Dread_f(dset_id = dset_id,         &
                mem_type_id   = H5T_NATIVE_REAL,  &
                buf           = Values,           &
                dims          = HyperSlabSize,    &
                hdferr        = hdferror,         &
                file_space_id = filespace,        &
                mem_space_id  = memspace,         &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_R4P


    subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_R8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< read R8P dataset to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R8P), allocatable,                     intent(OUT) :: Values(:)          !< R8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
        integer                                                :: rank                !< Hyperslab rank 
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        rank = 1
        allocate(Values(HyperSlabSize(rank)))
        ! Create filespace
        call H5Screate_simple_f(rank = rank,                  &
                dims     = DatasetDims,                       &
                space_id = filespace,                         &
                hdferr   = hdferror)
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Open dataset 
        call H5Dopen_f(loc_id = this%file_id,               &
                name     = '/'//trim(adjustl(DatasetName)), &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Select hyperslab
        call H5Sselect_hyperslab_f (space_id = filespace,   &
                operator = H5S_SELECT_SET_F,                &
                start    = HyperSlabOffset,                 &
                count    = HyperSlabSize,                   &
                hdferr   = hdferror)
        ! Create memspace
        call H5Screate_simple_f(rank = 1,                   &
                dims     = HyperSlabSize,                   &
                space_id = memspace,                        &
                hdferr   = hdferror) 
        ! Read data
        call H5Dread_f(dset_id = dset_id,           &
                mem_type_id   = H5T_NATIVE_DOUBLE,  &
                buf           = Values,             &
                dims          = HyperSlabSize,      &
                hdferr        = hdferror,           &
                file_space_id = filespace,          &
                mem_space_id  = memspace,           &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Sclose_f(space_id = memspace,  hdferr = hdferror) 
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadHyperSlab_R8P


    subroutine hdf5_contiguous_hyperslab_handler_WriteGeometry_R4P(this, Coordinates, Name)
    !-----------------------------------------------------------------
    !< Writes R4P coordinates to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        real(R4P),                                  intent(IN) :: Coordinates(:)      !< Grid coordinates
        character(len=*),                           intent(IN) :: Name                !< Geometry dataset name
        integer(HSIZE_T)                                       :: spacedim            !< Space dimension
        integer(HSIZE_T)                                       :: globalnumberofnodes !< Global number of nodes
        integer(HSIZE_T)                                       :: localnumberofnodes  !< Local number of nodes
        integer(HSIZE_T)                                       :: nodeoffset          !< Node offset for a particular grid
        integer(HID_T)                                         :: filespace           !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        spacedim = int(GetSpaceDimension(this%SpatialGridDescriptor%GetGeometryTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofnodes = int(this%SpatialGridDescriptor%GetGlobalNumberOfNodes(),HSIZE_T)
        localnumberofnodes = int(this%UniformGridDescriptor%GetNumberOfNodes(),HSIZE_T)
        nodeoffset = int(this%SpatialGridDescriptor%GetNodeOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%WriteHyperSlab(DatasetName=Name,                  &
                DatasetDims     = (/spacedim*globalnumberofnodes/), &
                HyperSlabOffset = (/spacedim*nodeoffset/),          &
                HyperSlabSize   = (/spacedim*localnumberofnodes/),  &
                Values          = Coordinates)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteGeometry_R4P



    subroutine hdf5_contiguous_hyperslab_handler_WriteGeometry_R8P(this, Coordinates, Name)
    !-----------------------------------------------------------------
    !< Writes R8P coordinates to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        real(R8P),                                  intent(IN) :: Coordinates(:)      !< Grid coordinates
        character(len=*),                           intent(IN) :: Name                !< Geometry dataset name
        integer(HSIZE_T)                                       :: spacedim            !< Space dimension
        integer(HSIZE_T)                                       :: globalnumberofnodes !< Global number of nodes
        integer(HSIZE_T)                                       :: localnumberofnodes  !< Local number of nodes
        integer(HSIZE_T)                                       :: nodeoffset          !< Node offset for a particular grid
        integer(HID_T)                                         :: filespace           !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        spacedim = int(GetSpaceDimension(this%SpatialGridDescriptor%GetGeometryTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofnodes = int(this%SpatialGridDescriptor%GetGlobalNumberOfNodes(),HSIZE_T)
        localnumberofnodes = int(this%UniformGridDescriptor%GetNumberOfNodes(),HSIZE_T)
        nodeoffset = int(this%SpatialGridDescriptor%GetNodeOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%WriteHyperSlab(DatasetName=Name,                  &
                DatasetDims     = (/spacedim*globalnumberofnodes/), &
                HyperSlabOffset = (/spacedim*nodeoffset/),          &
                HyperSlabSize   = (/spacedim*localnumberofnodes/),  &
                Values          = Coordinates)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteGeometry_R8P


    subroutine hdf5_contiguous_hyperslab_handler_WriteTopology_I4P(this, Connectivities, Name)
    !-----------------------------------------------------------------
    !< Writes I4P connectivities to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                   !< HDF5 contiguous hyperslab handler
        integer(I4P),                               intent(IN) :: Connectivities(:)      !< I4P Grid connectivities
        character(len=*),                           intent(IN) :: Name                   !< Topology dataset name
        integer(HSIZE_T)                                       :: nodesperelement        !< Nodes per element
        integer(HSIZE_T)                                       :: globalnumberofelements !< Global number of elements
        integer(HSIZE_T)                                       :: localnumberofelements  !< Local number of elements
        integer(HSIZE_T)                                       :: elementoffset          !< Elements offset for a particular grid
        integer(HID_T)                                         :: filespace              !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id               !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id                !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace               !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror               !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        nodesperelement = int(GetNumberOfNodesPerElement(this%SpatialGridDescriptor%GetTopologyTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofelements = int(this%SpatialGridDescriptor%GetGlobalNumberOfElements(),HSIZE_T)
        localnumberofelements = int(this%UniformGridDescriptor%GetNumberOfElements(),HSIZE_T)
        elementoffset = int(this%SpatialGridDescriptor%GetElementOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%WriteHyperSlab(DatasetName=Name,                            &
                DatasetDims     = (/nodesperelement*globalnumberofelements/), &
                HyperSlabOffset = (/nodesperelement*elementoffset/),          &
                HyperSlabSize   = (/nodesperelement*localnumberofelements/),  &
                Values          = Connectivities)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteTopology_I4P


    subroutine hdf5_contiguous_hyperslab_handler_WriteTopology_I8P(this, Connectivities, Name)
    !-----------------------------------------------------------------
    !< Writes I8P connectivities to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                   !< HDF5 contiguous hyperslab handler
        integer(I8P),                               intent(IN) :: Connectivities(:)      !< I8P Grid connectivities
        character(len=*),                           intent(IN) :: Name                   !< Topology dataset name
        integer(HSIZE_T)                                       :: nodesperelement        !< Nodes per element
        integer(HSIZE_T)                                       :: globalnumberofelements !< Global number of elements
        integer(HSIZE_T)                                       :: localnumberofelements  !< Local number of elements
        integer(HSIZE_T)                                       :: elementoffset          !< Elements offset for a particular grid
        integer(HID_T)                                         :: filespace              !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id               !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id                !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace               !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror               !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        nodesperelement = int(GetNumberOfNodesPerElement(this%SpatialGridDescriptor%GetTopologyTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofelements = int(this%SpatialGridDescriptor%GetGlobalNumberOfElements(),HSIZE_T)
        localnumberofelements = int(this%UniformGridDescriptor%GetNumberOfElements(),HSIZE_T)
        elementoffset = int(this%SpatialGridDescriptor%GetElementOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%WriteHyperSlab(DatasetName=Name,                            &
                DatasetDims     = (/nodesperelement*globalnumberofelements/), &
                HyperSlabOffset = (/nodesperelement*elementoffset/),          &
                HyperSlabSize   = (/nodesperelement*localnumberofelements/),  &
                Values          = Connectivities)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteTopology_I8P


    subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_I4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(I4P),                               intent(IN) :: Values(:)           !< I4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%WriteHyperSlab(                                             &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_I4P


    subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_I8P(this, Name, type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I8P attriburte values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(I8P),                               intent(IN) :: Values(:)           !< I8P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%WriteHyperSlab(                                             &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_I8P


    subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_R4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes R4P attribute values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        real(R4P),                                  intent(IN) :: Values(:)           !< R4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%WriteHyperSlab(                                             &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_R4P


    subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_R8P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes R8P attriburte values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        real(R8P),                                  intent(IN) :: Values(:)           !< R8P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%WriteHyperSlab(                                             &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_WriteAttribute_R8P


    subroutine hdf5_contiguous_hyperslab_handler_ReadGeometry_R4P(this, Coordinates, Name)
    !-----------------------------------------------------------------
    !< Read R4P coordinates to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        real(R4P), allocatable,                     intent(OUT):: Coordinates(:)      !< Grid coordinates
        character(len=*),                           intent(IN) :: Name                !< Geometry dataset name
        integer(HSIZE_T)                                       :: spacedim            !< Space dimension
        integer(HSIZE_T)                                       :: globalnumberofnodes !< Global number of nodes
        integer(HSIZE_T)                                       :: localnumberofnodes  !< Local number of nodes
        integer(HSIZE_T)                                       :: nodeoffset          !< Node offset for a particular grid
        integer(HID_T)                                         :: filespace           !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        spacedim = int(GetSpaceDimension(this%SpatialGridDescriptor%GetGeometryTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofnodes = int(this%SpatialGridDescriptor%GetGlobalNumberOfNodes(),HSIZE_T)
        localnumberofnodes = int(this%SpatialGridDescriptor%GetNumberOfNodesFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        nodeoffset = int(this%SpatialGridDescriptor%GetNodeOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%ReadHyperSlab(DatasetName = Name,                 &
                DatasetDims     = (/spacedim*globalnumberofnodes/), &
                HyperSlabOffset = (/spacedim*nodeoffset/),          &
                HyperSlabSize   = (/spacedim*localnumberofnodes/),  &
                Values          = Coordinates)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadGeometry_R4P


    subroutine hdf5_contiguous_hyperslab_handler_ReadGeometry_R8P(this, Coordinates, Name)
    !-----------------------------------------------------------------
    !< Read R4P coordinates to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        real(R8P), allocatable,                     intent(OUT):: Coordinates(:)      !< Grid coordinates
        character(len=*),                           intent(IN) :: Name                !< Geometry dataset name
        integer(HSIZE_T)                                       :: spacedim            !< Space dimension
        integer(HSIZE_T)                                       :: globalnumberofnodes !< Global number of nodes
        integer(HSIZE_T)                                       :: localnumberofnodes  !< Local number of nodes
        integer(HSIZE_T)                                       :: nodeoffset          !< Node offset for a particular grid
        integer(HID_T)                                         :: filespace           !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace            !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        spacedim = int(GetSpaceDimension(this%SpatialGridDescriptor%GetGeometryTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofnodes = int(this%SpatialGridDescriptor%GetGlobalNumberOfNodes(),HSIZE_T)
        localnumberofnodes = int(this%SpatialGridDescriptor%GetNumberOfNodesFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        nodeoffset = int(this%SpatialGridDescriptor%GetNodeOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%ReadHyperSlab(DatasetName = Name,                 &
                DatasetDims     = (/spacedim*globalnumberofnodes/), &
                HyperSlabOffset = (/spacedim*nodeoffset/),          &
                HyperSlabSize   = (/spacedim*localnumberofnodes/),  &
                Values          = Coordinates)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadGeometry_R8P


    subroutine hdf5_contiguous_hyperslab_handler_ReadTopology_I4P(this, Connectivities, Name)
    !-----------------------------------------------------------------
    !< Read I4P connectivities to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                   !< HDF5 contiguous hyperslab handler
        integer(I4P), allocatable,                  intent(OUT):: Connectivities(:)      !< I4P Grid connectivities
        character(len=*),                           intent(IN) :: Name                   !< Topology dataset name
        integer(HSIZE_T)                                       :: nodesperelement        !< Nodes per element
        integer(HSIZE_T)                                       :: globalnumberofelements !< Global number of elements
        integer(HSIZE_T)                                       :: localnumberofelements  !< Local number of elements
        integer(HSIZE_T)                                       :: elementoffset          !< Elements offset for a particular grid
        integer(HID_T)                                         :: filespace              !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id               !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id                !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace               !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror               !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        nodesperelement = int(GetNumberOfNodesPerElement(this%SpatialGridDescriptor%GetTopologyTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofelements = int(this%SpatialGridDescriptor%GetGlobalNumberOfElements(),HSIZE_T)
        localnumberofelements = int(this%SpatialGridDescriptor%GetNumberOfElementsFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        elementoffset = int(this%SpatialGridDescriptor%GetElementOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%ReadHyperSlab(DatasetName = Name,                           &
                DatasetDims     = (/nodesperelement*globalnumberofelements/), &
                HyperSlabOffset = (/nodesperelement*elementoffset/),          &
                HyperSlabSize   = (/nodesperelement*localnumberofelements/),  &
                Values          = Connectivities)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadTopology_I4P


    subroutine hdf5_contiguous_hyperslab_handler_ReadTopology_I8P(this, Connectivities, Name)
    !-----------------------------------------------------------------
    !< Read I8P connectivities to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                   !< HDF5 contiguous hyperslab handler
        integer(I8P), allocatable,                  intent(OUT):: Connectivities(:)      !< I8P Grid connectivities
        character(len=*),                           intent(IN) :: Name                   !< Topology dataset name
        integer(HSIZE_T)                                       :: nodesperelement        !< Nodes per element
        integer(HSIZE_T)                                       :: globalnumberofelements !< Global number of elements
        integer(HSIZE_T)                                       :: localnumberofelements  !< Local number of elements
        integer(HSIZE_T)                                       :: elementoffset          !< Elements offset for a particular grid
        integer(HID_T)                                         :: filespace              !< HDF5 fiel Dataspace identifier
        integer(HID_T)                                         :: plist_id               !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id                !< HDF5 Dataset identifier 
        integer(HID_T)                                         :: memspace               !< HDF5 memory Dataspace identifier
        integer                                                :: hdferror               !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        nodesperelement = int(GetNumberOfNodesPerElement(this%SpatialGridDescriptor%GetTopologyTypeFromGridID(ID=this%MPIEnvironment%get_rank())),HSIZE_T)
        globalnumberofelements = int(this%SpatialGridDescriptor%GetGlobalNumberOfElements(),HSIZE_T)
        localnumberofelements = int(this%SpatialGridDescriptor%GetNumberOfElementsFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        elementoffset = int(this%SpatialGridDescriptor%GetElementOffsetFromGridID(ID=this%MPIEnvironment%get_rank()),HSIZE_T)
        call this%WriteHyperSlab(DatasetName = Name,                          &
                DatasetDims     = (/nodesperelement*globalnumberofelements/), &
                HyperSlabOffset = (/nodesperelement*elementoffset/),          &
                HyperSlabSize   = (/nodesperelement*localnumberofelements/),  &
                Values          = Connectivities)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadTopology_I8P


    subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_I4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(I4P), allocatable,                  intent(OUT):: Values(:)           !< I4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%ReadHyperSlab(                                              &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_I4P


    subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_I8P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(I8P), allocatable,                  intent(OUT):: Values(:)           !< I4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%ReadHyperSlab(                                              &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_I8P


    subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_R4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        real(R4P), allocatable,                     intent(OUT):: Values(:)           !< I4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%ReadHyperSlab(                                              &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_R4P


    subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_R8P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the contiguous HyperSlab strategy
    !----------------------------------------------------------------- 
        class(hdf5_contiguous_hyperslab_handler_t), intent(IN) :: this                !< HDF5 contiguous hyperslab handler
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        real(R8P), allocatable,                     intent(OUT):: Values(:)           !< I4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        call this%CalculateHyperSlabDimensions(          &
                Center             = Center,             &
                GlobalNumberOfData = GlobalNumberOfData, &
                LocalNumberOfData  = LocalNumberOfData,  &
                DataOffset         = DataOffset)
        call this%ReadHyperSlab(                                              &
                DatasetName     = Name,                                       &
                DatasetDims     = (/GlobalNumberOfData*NumberOfComponents/),  &
                HyperSlabOffset = (/DataOffset*NumberOfComponents/),          &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),   &
                Values          = Values)
#endif
    end subroutine hdf5_contiguous_hyperslab_handler_ReadAttribute_R8P


end module hdf5_contiguous_hyperslab_handler
