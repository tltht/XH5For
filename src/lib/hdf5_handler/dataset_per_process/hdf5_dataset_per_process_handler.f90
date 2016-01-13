module hdf5_dataset_per_process_handler

use IR_Precision, only : I4P, I8P, R4P, R8P
#ifdef ENABLE_HDF5
use HDF5
#endif
use hdf5_handler
use xh5for_utils

implicit none

private

    type, abstract, extends(hdf5_handler_t) :: hdf5_dataset_per_process_handler_t
    !-----------------------------------------------------------------
    !< HDF5 dataset per process handler
    !----------------------------------------------------------------- 
    contains
        procedure :: CalculateAttributeDimensions => hdf5_dataset_per_process_handler_CalculateAttributeDimensions
        procedure :: WriteMetadata_I4P  => hdf5_dataset_per_process_handler_WriteMetadata_I4P
        procedure :: WriteMetadata_I8P  => hdf5_dataset_per_process_handler_WriteMetadata_I8P
        procedure :: WriteMetadata_R4P  => hdf5_dataset_per_process_handler_WriteMetadata_R4P
        procedure :: WriteMetadata_R8P  => hdf5_dataset_per_process_handler_WriteMetadata_R8P
        procedure :: WriteData_I4P      => hdf5_dataset_per_process_handler_WriteData_I4P
        procedure :: WriteData_I8P      => hdf5_dataset_per_process_handler_WriteData_I8P
        procedure :: WriteData_R4P      => hdf5_dataset_per_process_handler_WriteData_R4P
        procedure :: WriteData_R8P      => hdf5_dataset_per_process_handler_WriteData_R8P
        procedure :: ReadDataset_I4P    => hdf5_dataset_per_process_handler_ReadDataset_I4P
        procedure :: ReadDataset_I8P    => hdf5_dataset_per_process_handler_ReadDataset_I8P
        procedure :: ReadDataset_R4P    => hdf5_dataset_per_process_handler_ReadDataset_R4P
        procedure :: ReadDataset_R8P    => hdf5_dataset_per_process_handler_ReadDataset_R8P
        procedure :: WriteAttribute_I4P => hdf5_dataset_per_process_handler_WriteAttribute_I4P
        procedure :: WriteAttribute_I8P => hdf5_dataset_per_process_handler_WriteAttribute_I8P
        procedure :: WriteAttribute_R4P => hdf5_dataset_per_process_handler_WriteAttribute_R4P
        procedure :: WriteAttribute_R8P => hdf5_dataset_per_process_handler_WriteAttribute_R8P
        procedure :: ReadAttribute_I4P  => hdf5_dataset_per_process_handler_ReadAttribute_I4P
        procedure :: ReadAttribute_I8P  => hdf5_dataset_per_process_handler_ReadAttribute_I8P
        procedure :: ReadAttribute_R4P  => hdf5_dataset_per_process_handler_ReadAttribute_R4P
        procedure :: ReadAttribute_R8P  => hdf5_dataset_per_process_handler_ReadAttribute_R8P
        generic   :: WriteMetadata      => WriteMetadata_I4P, &
                                           WriteMetadata_I8P, &
                                           WriteMetadata_R4P, &
                                           WriteMetadata_R8P
        generic   :: WriteData          => WriteData_I4P, &
                                           WriteData_I8P, &
                                           WriteData_R4P, &
                                           WriteData_R8P
        generic   :: ReadDataset        => ReadDataset_I4P, &
                                           ReadDataset_I8P, &
                                           ReadDataset_R4P, &
                                           ReadDataset_R8P

    end type hdf5_dataset_per_process_handler_t

public :: hdf5_dataset_per_process_handler_t

#ifndef ENABLE_HDF5
public :: HID_T
public :: HSIZE_T
#endif

contains


    subroutine hdf5_dataset_per_process_handler_CalculateAttributeDimensions(this, GridID, Center, LocalNumberOfData)
    !-----------------------------------------------------------------
    !< Calculate hyperslab dimensions for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN)  :: this                !< HDF5 dataset per process handler
        integer(I4P),                               intent(IN)  :: GridID              !< Index to loop on GridID's
        integer(I4P),                               intent(IN)  :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(HSIZE_T),                           intent(OUT) :: LocalNumberOfData   !< Local number of data
    !----------------------------------------------------------------- 
    !< @TODO: face and edge attributes
#ifdef ENABLE_HDF5
        select case(Center)
            case (XDMF_ATTRIBUTE_CENTER_NODE)
                LocalNumberOfData = int(this%SpatialGridDescriptor%GetNumberOfNodesPerGridID(ID=GridID),HSIZE_T)
            case (XDMF_ATTRIBUTE_CENTER_CELL)
                LocalNumberOfData = int(this%SpatialGridDescriptor%GetNumberOfElementsPerGridID(ID=GridID),HSIZE_T)
            case (XDMF_ATTRIBUTE_CENTER_GRID)
                LocalNumberOfData = 1_HSIZE_T
            case Default
                LocalNumberOfData = int(this%SpatialGridDescriptor%GetNumberOfNodesPerGridID(ID=GridID),HSIZE_T)
        end select
#endif
    end subroutine hdf5_dataset_per_process_handler_CalculateAttributeDimensions


    subroutine hdf5_dataset_per_process_handler_WriteMetaData_I4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes I4P Metadata to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I4P),                               intent(IN) :: Values(:)           !< I4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
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
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_INTEGER,              &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Close dataset and filespace
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteMetadata_I4P


    subroutine hdf5_dataset_per_process_handler_WriteData_I4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes I4P data to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I4P),                               intent(IN) :: Values(:)           !< I4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Open dataset
        call H5Dopen_f(loc_id = this%file_id,              &
                name    = '/'//trim(adjustl(DatasetName)), &
                dset_id = dset_id,                         &
                hdferr  = hdferror,                        &
                dapl_id = plist_id) 
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Write data
        call H5Dwrite_f(dset_id = dset_id,           &
                mem_type_id   = H5T_NATIVE_INTEGER,  &
                buf           = Values,              &
                dims          = HyperSlabSize,       &
                hdferr        = hdferror,            &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteData_I4P


    subroutine hdf5_dataset_per_process_handler_WriteMetaData_I8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes I8P metadata to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I8P),                               intent(IN) :: Values(:)           !< I8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
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
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_INTEGER,              &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Close dataset and filespace
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteMetaData_I8P


    subroutine hdf5_dataset_per_process_handler_WriteData_I8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes I8P metadata to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I8P),                               intent(IN) :: Values(:)           !< I8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Open dataset
        call H5Dopen_f(loc_id = this%file_id,              &
                name    = '/'//trim(adjustl(DatasetName)), &
                dset_id = dset_id,                         &
                hdferr  = hdferror,                        &
                dapl_id = plist_id) 
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
!        ! Write data
!        call H5Dwrite_f(dset_id = dset_id,           &
!                mem_type_id   = H5T_NATIVE_INTEGER,  &
!                buf           = Values,              &
!                dims          = HyperSlabSize,       &
!                hdferr        = hdferror,            &
!                xfer_prp      = plist_id)
!        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteData_I8P


    subroutine hdf5_dataset_per_process_handler_WriteMetaData_R4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes R4P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R4P),                                  intent(IN) :: Values(:)           !< R4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
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
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_REAL,                 &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Close dataset and filespace
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteMetaData_R4P


    subroutine hdf5_dataset_per_process_handler_WriteData_R4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes R4P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R4P),                                  intent(IN) :: Values(:)           !< R4P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Open dataset
        call H5Dopen_f(loc_id = this%file_id,              &
                name    = '/'//trim(adjustl(DatasetName)), &
                dset_id = dset_id,                         &
                hdferr  = hdferror,                        &
                dapl_id = plist_id) 
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Write data
        call H5Dwrite_f(dset_id = dset_id,           &
                mem_type_id   = H5T_NATIVE_REAL,     &
                buf           = Values,              &
                dims          = HyperSlabSize,       &
                hdferr        = hdferror,            &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteData_R4P


    subroutine hdf5_dataset_per_process_handler_WriteMetadata_R8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes R4P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R8P),                                  intent(IN) :: Values(:)           !< R8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
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
        ! Create dataset 
        call H5Dcreate_f(loc_id = this%file_id,             &
                name     = '/'//trim(adjustl(DatasetName)), &
                type_id  = H5T_NATIVE_DOUBLE,               &
                space_id = filespace,                       &
                dset_id  = dset_id,                         & 
                hdferr   = hdferror)
        ! Close dataset and filespace
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteMetadata_R8P


    subroutine hdf5_dataset_per_process_handler_WriteData_R8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Writes R4P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R8P),                                  intent(IN) :: Values(:)           !< R8P Dataset values
        integer(HID_T)                                         :: filespace           !< HDF5 file Dataspace identifier
        integer(HID_T)                                         :: plist_id            !< HDF5 Property list identifier 
        integer(HID_T)                                         :: dset_id             !< HDF5 Dataset identifier 
        integer                                                :: hdferror            !< HDF5 error code
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        ! Open dataset
        call H5Dopen_f(loc_id = this%file_id,              &
                name    = '/'//trim(adjustl(DatasetName)), &
                dset_id = dset_id,                         &
                hdferr  = hdferror,                        &
                dapl_id = plist_id) 
        ! Create the dataset with default properties.
        call H5Pcreate_f(H5P_DATASET_XFER_F, prp_id = plist_id, hdferr=hdferror) 
        ! Set MPIO data transfer mode to COLLECTIVE
        call H5Pset_dxpl_mpio_f(prp_id = plist_id, data_xfer_mode = H5FD_MPIO_COLLECTIVE_F, hdferr = hdferror)
        ! Write data
        call H5Dwrite_f(dset_id = dset_id,           &
                mem_type_id   = H5T_NATIVE_DOUBLE,   &
                buf           = Values,              &
                dims          = HyperSlabSize,       &
                hdferr        = hdferror,            &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteData_R8P


    subroutine hdf5_dataset_per_process_handler_ReadDataset_I4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Read I4P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        integer(I4P), allocatable,                  intent(OUT):: Values(:)          !< I4P Dataset values
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
        ! Read data
        call H5Dread_f(dset_id = dset_id,            &
                mem_type_id   = H5T_NATIVE_INTEGER,  &
                buf           = Values,              &
                dims          = DatasetDims,         &
                hdferr        = hdferror,            &
                file_space_id = filespace,           &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadDataset_I4P


    subroutine hdf5_dataset_per_process_handler_ReadDataset_I8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Read I8P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
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
!        call H5Dread_f(dset_id = dset_id,            &
!                mem_type_id   = H5T_NATIVE_INTEGER,  &
!                buf           = Values,              &
!                dims          = HyperSlabSize,       &
!                hdferr        = hdferror,            &
!                file_space_id = filespace,           &
!                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadDataset_I8P


    subroutine hdf5_dataset_per_process_handler_ReadDataset_R4P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< Read R4P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R4P), allocatable,                     intent(OUT):: Values(:)           !< R4P Dataset values
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
        ! Read data
        call H5Dread_f(dset_id = dset_id,         &
                mem_type_id   = H5T_NATIVE_REAL,  &
                buf           = Values,           &
                dims          = HyperSlabSize,    &
                hdferr        = hdferror,         &
                file_space_id = filespace,        &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadDataset_R4P


    subroutine hdf5_dataset_per_process_handler_ReadDataset_R8P(this, DatasetName, DatasetDims, HyperSlabOffset, HyperSlabSize, Values)
    !-----------------------------------------------------------------
    !< read R8P dataset to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler
        character(len=*),                           intent(IN) :: DatasetName         !< Dataset name
        integer(HSIZE_T),                           intent(IN) :: DatasetDims(:)      !< Dataset dimensions
        integer(HSIZE_T),                           intent(IN) :: HyperSlabOffset(:)  !< Hyperslab offset
        integer(HSIZE_T),                           intent(IN) :: HyperSlabSize(:)    !< Hyperslab size
        real(R8P), allocatable,                     intent(OUT):: Values(:)          !< R8P Dataset values
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
        ! Read data
        call H5Dread_f(dset_id = dset_id,           &
                mem_type_id   = H5T_NATIVE_DOUBLE,  &
                buf           = Values,             &
                dims          = HyperSlabSize,      &
                hdferr        = hdferror,           &
                file_space_id = filespace,          &
                xfer_prp      = plist_id)
        ! Close data space, dataset, property list .
        call H5Dclose_f(dset_id  = dset_id,   hdferr = hdferror)
        call H5Pclose_f(prp_id   = plist_id,  hdferr = hdferror)
        call H5Sclose_f(space_id = filespace, hdferr = hdferror)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadDataset_R8P


    subroutine hdf5_dataset_per_process_handler_WriteAttribute_I4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler for structured grids
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(I4P),                               intent(IN) :: Values(:)           !< I4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
        integer(I4P)                                           :: GridID              !< Index to loop on GridID's
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        do GridID=0, this%MPIEnvironment%get_comm_size()-1
            call this%CalculateAttributeDimensions(GridID=GridID, Center=Center, LocalNumberOfData=LocalNumberOfData)
            call this%WriteMetaData(                                                           &
                    DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=GridID))),  &
                    DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                &
                    HyperSlabOffset = (/0_HSIZE_T/),                                           &
                    HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                &
                    Values          = Values)
        enddo
        call this%CalculateAttributeDimensions(GridID=this%MPIEnvironment%get_rank(), Center=Center, LocalNumberOfData=LocalNumberOfData)
        call this%WriteData(                                                                                   &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteAttribute_I4P


    subroutine hdf5_dataset_per_process_handler_WriteAttribute_I8P(this, Name, type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I8P attriburte values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler for structured grids
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        integer(I8P),                               intent(IN) :: Values(:)           !< I8P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
        integer(I4P)                                           :: GridID              !< Index to loop on GridID's
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        do GridID=0, this%MPIEnvironment%get_comm_size()-1
            call this%CalculateAttributeDimensions( GridID=GridID, Center=Center, LocalNumberOfData=LocalNumberOfData)
            call this%WriteMetaData(                                                           &
                    DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=GridID))),  &
                    DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                &
                    HyperSlabOffset = (/0_HSIZE_T/),                                           &
                    HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                &
                    Values          = Values)
        enddo
        call this%CalculateAttributeDimensions(GridID=this%MPIEnvironment%get_rank(), Center=Center, LocalNumberOfData=LocalNumberOfData)
        call this%WriteData(                                                                                   &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteAttribute_I8P


    subroutine hdf5_dataset_per_process_handler_WriteAttribute_R4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes R4P attribute values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler for structured grids
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        real(R4P),                                  intent(IN) :: Values(:)           !< R4P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
        integer(I4P)                                           :: GridID              !< Index to loop on GridID's
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        do GridID=0, this%MPIEnvironment%get_comm_size()-1
            call this%CalculateAttributeDimensions(GridID=GridID, Center=Center, LocalNumberOfData=LocalNumberOfData)
            call this%WriteMetaData(                                                           &
                    DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=GridID))),  &
                    DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                &
                    HyperSlabOffset = (/0_HSIZE_T/),                                           &
                    HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                &
                    Values          = Values)
        enddo
        call this%CalculateAttributeDimensions(GridID=this%MPIEnvironment%get_rank(), Center=Center, LocalNumberOfData=LocalNumberOfData)
        call this%WriteData(                                                                                   &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteAttribute_R4P


    subroutine hdf5_dataset_per_process_handler_WriteAttribute_R8P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes R8P attriburte values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this                !< HDF5 dataset per process handler for structured grids
        character(len=*),                           intent(IN) :: Name                !< Attribute name
        integer(I4P),                               intent(IN) :: Type                !< Attribute type (Scalar, Vector, etc.)
        integer(I4P),                               intent(IN) :: Center              !< Attribute center at (Node, Cell, etc.)
        real(R8P),                                  intent(IN) :: Values(:)           !< R8P Attribute values
        integer(HSIZE_T)                                       :: GlobalNumberOfData  !< Global number of data
        integer(HSIZE_T)                                       :: LocalNumberOfData   !< Local number of data
        integer(HSIZE_T)                                       :: NumberOfComponents  !< Global number of nodes
        integer(HSIZE_T)                                       :: DataOffset          !< Node offset for a particular grid
        integer(I4P)                                           :: GridID              !< Index to loop on GridID's
    !-----------------------------------------------------------------
        !< @Note: Fixed rank 1?
        !< @Note: Fixed dataset name?
        !< @Note: Fixed rank 1?
#ifdef ENABLE_HDF5
        NumberOfComponents = int(GetNumberOfComponentsFromAttributeType(Type), HSIZE_T)
        do GridID=0, this%MPIEnvironment%get_comm_size()-1
            call this%CalculateAttributeDimensions(GridID=GridID, Center=Center, LocalNumberOfData=LocalNumberOfData)
            call this%WriteMetaData(                                                           &
                    DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=GridID))),  &
                    DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                &
                    HyperSlabOffset = (/0_HSIZE_T/),                                           &
                    HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                &
                    Values          = Values)
        enddo
        call this%CalculateAttributeDimensions(GridID=this%MPIEnvironment%get_rank(), Center=Center, LocalNumberOfData=LocalNumberOfData)
        call this%WriteData(                                                                                   &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_WriteAttribute_R8P


    subroutine hdf5_dataset_per_process_handler_ReadAttribute_I4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this     !< HDF5 dataset per process handler for structured grids
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
        call this%CalculateAttributeDimensions(                      &
                GridID             = this%MPIEnvironment%get_rank(), &
                Center             = Center,                         &
                LocalNumberOfData  = LocalNumberOfData)
        call this%ReadDataset(                                                                                     &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadAttribute_I4P


    subroutine hdf5_dataset_per_process_handler_ReadAttribute_I8P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this     !< HDF5 dataset per process handler for structured grids
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
        call this%CalculateAttributeDimensions(                      &
                GridID             = this%MPIEnvironment%get_rank(), &
                Center             = Center,                         &
                LocalNumberOfData  = LocalNumberOfData)
        call this%ReadDataset(                                                                                     &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadAttribute_I8P


    subroutine hdf5_dataset_per_process_handler_ReadAttribute_R4P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this     !< HDF5 dataset per process handler for structured grids
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
        call this%CalculateAttributeDimensions(                      &
                GridID             = this%MPIEnvironment%get_rank(), &
                Center             = Center,                         &
                LocalNumberOfData  = LocalNumberOfData)
        call this%ReadDataset(                                                                                     &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadAttribute_R4P


    subroutine hdf5_dataset_per_process_handler_ReadAttribute_R8P(this, Name, Type, Center, Values)
    !-----------------------------------------------------------------
    !< Writes I4P attriburte values to a HDF5 file for the dataset per process strategy
    !----------------------------------------------------------------- 
        class(hdf5_dataset_per_process_handler_t),  intent(IN) :: this     !< HDF5 dataset per process handler for structured grids
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
        call this%CalculateAttributeDimensions(                      &
                GridID             = this%MPIEnvironment%get_rank(), &
                Center             = Center,                         &
                LocalNumberOfData  = LocalNumberOfData)
        call this%ReadDataset(                                                                                     &
                DatasetName     = Name//'_'//trim(adjustl(str(no_sign=.true.,n=this%MPIEnvironment%get_rank()))),  &
                DatasetDims     = (/LocalNumberOfData*NumberOfComponents/),                                        &
                HyperSlabOffset = (/0_HSIZE_T/),                                                                   &
                HyperSlabSize   = (/LocalNumberOfData*NumberOfComponents/),                                        &
                Values          = Values)
#endif
    end subroutine hdf5_dataset_per_process_handler_ReadAttribute_R8P


end module hdf5_dataset_per_process_handler