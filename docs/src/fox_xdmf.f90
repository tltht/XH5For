module fox_xdmf
!--------------------------------------------------------------------- -----------------------------------------------------------
!< XdmfHdf5Fortran: XDMF parallel partitioned mesh I/O on top of HDF5
!< XDMF interface module for the XML writing later on top of FoX_wxml
!--------------------------------------------------------------------- -----------------------------------------------------------

use xdmf_file
use xdmf_domain
use xdmf_grid
use xdmf_geometry
use xdmf_topology
use xdmf_dataitem
use xdmf_attribute
use xdmf_time
use xdmf_information
use xdmf_character_data
use xdmf_xinclude

implicit none
private

public:: xmlf_t
public:: xdmf_file_t
public:: xdmf_domain_t
public:: xdmf_grid_t
public:: xdmf_geometry_t
public:: xdmf_topology_t
public:: xdmf_dataitem_t
public:: xdmf_attribute_t
public:: xdmf_time_t
public:: xdmf_information_t
public:: xdmf_character_data_t
public:: xdmf_xinclude_t

end module fox_xdmf
