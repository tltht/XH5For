!-----------------------------------------------------------------
! XH5For (XDMF parallel partitioned mesh I/O on top of HDF5)
! Copyright (c) 2015 Santiago Badia, Alberto F. Martín, 
! Javier Principe and Víctor Sande.
! All rights reserved.
!
! This library is free software; you can redistribute it and/or
! modify it under the terms of the GNU Lesser General Public
! License as published by the Free Software Foundation; either
! version 3.0 of the License, or (at your option) any later version.
!
! This library is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
! Lesser General Public License for more details.
!
! You should have received a copy of the GNU Lesser General Public
! License along with this library.
!-----------------------------------------------------------------
module structured_dataset_per_process_factory

use xh5for_abstract_factory
use xdmf_handler
use hdf5_handler
use uniform_grid_descriptor
use spatial_grid_descriptor
use structured_uniform_grid_descriptor
use structured_spatial_grid_descriptor
use xdmf_structured_dataset_per_process_handler
use hdf5_structured_dataset_per_process_handler

implicit none
private

    type, extends(xh5for_abstract_factory_t) :: structured_dataset_per_process_factory_t
    contains
        procedure :: CreateUniformGridDescriptor => structured_dataset_per_process_CreateUniformGridDescriptor
        procedure :: CreateSpatialGridDescriptor => structured_dataset_per_process_CreateSpatialGridDescriptor
        procedure :: CreateXDMFHandler           => structured_dataset_per_process_CreateXDMFHandler
        procedure :: CreateHDF5Handler           => structured_dataset_per_process_CreateHDF5Handler
    end type structured_dataset_per_process_factory_t

public :: structured_dataset_per_process_factory_t

contains

    subroutine structured_dataset_per_process_CreateUniformGridDescriptor(this, UniformGridDescriptor)
    !-----------------------------------------------------------------
    !< Return an structured uniform grid descriptor
    !----------------------------------------------------------------- 
        class(structured_dataset_per_process_factory_t), intent(IN)  :: this                  !< structured grid descriptor factory
        class(uniform_grid_descriptor_t), allocatable,   intent(OUT) :: UniformGridDescriptor !< Uniform grid descriptor
    !----------------------------------------------------------------- 
        allocate(structured_uniform_grid_descriptor_t :: UniformGridDescriptor)
    end subroutine structured_dataset_per_process_CreateUniformGridDescriptor


    subroutine structured_dataset_per_process_CreateSpatialGridDescriptor(this, SpatialGridDescriptor)
    !-----------------------------------------------------------------
    !< Return an structured spatial grid descriptor
    !----------------------------------------------------------------- 
        class(structured_dataset_per_process_factory_t), intent(IN)  :: this                  !< structured grid descriptor factory
        class(spatial_grid_descriptor_t), allocatable,   intent(OUT) :: SpatialGridDescriptor !< Spatial grid descriptor
    !----------------------------------------------------------------- 
        allocate(structured_spatial_grid_descriptor_t :: SpatialGridDescriptor)
    end subroutine structured_dataset_per_process_CreateSpatialGridDescriptor


    subroutine structured_dataset_per_process_CreateXDMFHandler(this, XDMFHandler)
    !-----------------------------------------------------------------
    !< Return an structured contiguous hyperslab XDMF handler
    !----------------------------------------------------------------- 
        class(structured_dataset_per_process_factory_t), intent(IN)  :: this        !< structured contiguous hyperslab factory
        class(xdmf_handler_t), allocatable,              intent(OUT) :: XDMFHandler !< XDMF handler
    !----------------------------------------------------------------- 
        allocate(xdmf_structured_dataset_per_process_handler_t :: XDMFHandler)
    end subroutine structured_dataset_per_process_CreateXDMFHandler


    subroutine structured_dataset_per_process_CreateHDF5Handler(this, HDF5Handler)
    !-----------------------------------------------------------------
    !< Return an structured contiguous hyperslab HDF5 handler
    !----------------------------------------------------------------- 
        class(structured_dataset_per_process_factory_t), intent(IN)  :: this        !< structured contiguous hyperslab factory
        class(hdf5_handler_t), allocatable,              intent(OUT) :: HDF5Handler !< HDF5 handler
    !----------------------------------------------------------------- 
        allocate(hdf5_structured_dataset_per_process_handler_t :: HDF5Handler)
    end subroutine structured_dataset_per_process_CreateHDF5Handler

end module structured_dataset_per_process_factory
