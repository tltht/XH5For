module spatial_grid_descriptor
!--------------------------------------------------------------------- -----------------------------------------------------------
!< XdmfHdf5Fortran: XDMF parallel partitioned mesh I/O on top of HDF5
!< XDMF Time handling module
!--------------------------------------------------------------------- -----------------------------------------------------------

use IR_Precision, only : I4P, I8P, R4P, R8P
use mpi_environment
use xdmf_utils
use XH5For_metadata

implicit none

private

    type spatial_grid_attribute_t
        integer(I4P)                          :: NumberOfAttributes = 0
        type(xh5for_metadata_t),  allocatable :: attributes_info(:)
    end type spatial_grid_attribute_t

    type :: spatial_grid_descriptor_t
    !-----------------------------------------------------------------
    !< XDMF contiguous HyperSlab handler implementation
    !----------------------------------------------------------------- 
    private
        integer(I4P)                                :: NumberOfGrids               !< Number of uniform grids of the spatial grid
        integer(I8P)                                :: GlobalNumberOfNodes = 0     !< Total number of nodes of the spatial grid
        integer(I8P)                                :: GlobalNumberOfElements = 0  !< Total number of elements of the spatial grid
        integer(I8P)                                :: GlobalConnectivitySize = 0  !< Total size of the connectivities of the spatial grid
        integer(I8P),                   allocatable :: NumberOfNodesPerGrid(:)     !< Array of number of nodes per grid
        integer(I8P),                   allocatable :: NumberOfElementsPerGrid(:)  !< Array of number of elements per grid
        integer(I8P),                   allocatable :: ConnectivitySizePerGrid(:)  !< Array of sizes of array connectivities per grid
        integer(I4P),                   allocatable :: GeometryTypePerGrid(:)      !< Array of geometry type per grid
        integer(I4P),                   allocatable :: TopologyTypePerGrid(:)      !< Array of topology type per grid
        type(mpi_env_t), pointer                    :: MPIEnvironment => null()    !< MPI environment 

    contains
    private
        procedure         :: Initialize_Writer                  => spatial_grid_descriptor_Initialize_Writer
        procedure         :: Initialize_Reader                  => spatial_grid_descriptor_Initialize_Reader
        procedure         :: SetGlobalNumberOfNodes             => spatial_grid_descriptor_SetGlobalNumberOfNodes
        procedure         :: SetGlobalNumberOfElements          => spatial_grid_descriptor_SetGlobalNumberOfElements
        procedure         :: SetGlobalConnectivitySize          => spatial_grid_descriptor_SetGlobalConnectivitySize
        procedure, public :: GetGlobalNumberOfNodes             => spatial_grid_descriptor_GetGlobalNumberOfNodes
        procedure, public :: GetGlobalNumberOfElements          => spatial_grid_descriptor_GetGlobalNumberOfElements
        procedure, public :: GetGlobalConnectivitySize          => spatial_grid_descriptor_GetGlobalConnectivitySize
        procedure, public :: AllgatherConnectivitySize          => spatial_grid_descriptor_AllgatherConnectivitySize
        procedure, public :: BroadcastMetadata                  => spatial_grid_descriptor_BroadcastMetadata
        procedure, public :: SetNumberOfNodesPerGridID          => spatial_grid_descriptor_SetNumberOfNodesPerGridID
        procedure, public :: SetNumberOfElementsPerGridID       => spatial_grid_descriptor_SetNumberOfElementsPerGridID
        procedure, public :: SetTopologyTypePerGridID           => spatial_grid_descriptor_SetTopologyTypePerGridID
        procedure, public :: SetGeometryTypePerGridID           => spatial_grid_descriptor_SetGeometryTypePerGridID
        procedure, public :: GetNumberOfNodesPerGridID          => spatial_grid_descriptor_GetNumberOfNodesPerGridID
        procedure, public :: GetNumberOfElementsPerGridID       => spatial_grid_descriptor_GetNumberOfElementsPerGridID
        procedure, public :: GetConnectivitySizePerGridID       => spatial_grid_descriptor_GetConnectivitySizePerGridID
        procedure, public :: GetTopologyTypePerGridID           => spatial_grid_descriptor_GetTopologyTypePerGridID
        procedure, public :: GetGeometryTypePerGridID           => spatial_grid_descriptor_GetGeometryTypePerGridID
        procedure, public :: GetNodeOffsetPerGridID             => spatial_grid_descriptor_GetNodeOffsetPerGridID
        procedure, public :: GetElementOffsetPerGridID          => spatial_grid_descriptor_GetElementOffsetPerGridID
        procedure, public :: GetConnectivitySizeOffsetPerGridID => spatial_grid_descriptor_GetConnectivitySizeOffsetPerGridID
        generic,   public :: Initialize                         => Initialize_Writer, &
                                                                   Initialize_Reader
        procedure, public :: Allocate                           => spatial_grid_descriptor_Allocate
        procedure, public :: Free                               => spatial_grid_descriptor_Free
    end type spatial_grid_descriptor_t

public :: spatial_grid_descriptor_t

contains

    subroutine spatial_grid_descriptor_Allocate(this, NumberOfGrids)
    !-----------------------------------------------------------------
    !< Set the total number of nodes of the spatial grid
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                 !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: NumberOfGrids        !< Total number of grids of the spatial grid
    !----------------------------------------------------------------- 
        this%NumberOfGrids = NumberOfGrids
        allocate(this%NumberOfNodesPerGrid(NumberOfGrids))
        allocate(this%NumberOfElementsPerGrid(NumberOfGrids))
        allocate(this%TopologyTypePerGrid(NumberOfGrids))
        allocate(this%GeometryTypePerGrid(NumberOfGrids))
    end subroutine spatial_grid_descriptor_Allocate

    subroutine spatial_grid_descriptor_SetGlobalNumberOfNodes(this, GlobalNumberOfNodes)
    !-----------------------------------------------------------------
    !< Set the total number of nodes of the spatial grid
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                 !< Spatial grid descriptor type
        integer(I8P),                     intent(IN)    :: GlobalNumberOfNodes  !< Total number of nodes of the spatial grid
    !----------------------------------------------------------------- 
        this%GlobalNumberOfNodes = GlobalNumberOfNodes
    end subroutine spatial_grid_descriptor_SetGlobalNumberOfNodes


    function spatial_grid_descriptor_GetGlobalNumberOfNodes(this)
    !-----------------------------------------------------------------
    !< Return the total number of nodes of the spatial grid
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this        !< Spatial grid descriptor type
        integer(I8P) :: spatial_grid_descriptor_GetGlobalNumberOfNodes !< Total number of nodes of the spatial grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetGlobalNumberOfNodes = this%GlobalNumberOfNodes
    end function spatial_grid_descriptor_GetGlobalNumberOfNodes


    subroutine spatial_grid_descriptor_SetGlobalNumberOfElements(this, GlobalNumberOfElements)
    !-----------------------------------------------------------------
    !< Set the total number of elements of the spatial grid
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                   !< Spatial grid descriptor type
        integer(I8P),                     intent(IN)    :: GlobalNumberOfElements !< Total number of elements of the spatial grid
    !-----------------------------------------------------------------
        this%GlobalNumberOfElements = GlobalNumberOfelements
    end subroutine spatial_grid_descriptor_SetGlobalNumberOfElements


    function spatial_grid_descriptor_GetGlobalNumberOfElements(this)
    !-----------------------------------------------------------------
    !< Return the total number of elements of the spatial grid
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this           !< Spatial grid descriptor type
        integer(I8P) :: spatial_grid_descriptor_GetGlobalNumberOfElements !< Total number of elements of the spatial grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetGlobalNumberOfelements = this%GlobalNumberOfElements
    end function spatial_grid_descriptor_GetGlobalNumberOfElements


    subroutine spatial_grid_descriptor_SetGlobalConnectivitySize(this, GlobalConnectivitySize)
    !-----------------------------------------------------------------
    !< Set the total connectivity size of the spatial grid
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                    !< Spatial grid descriptor type
        integer(I8P),                     intent(IN)    :: GlobalConnectivitySize  !< Total size of connectivities of the spatial grid
    !----------------------------------------------------------------- 
        this%GlobalConnectivitySize = GlobalConnectivitySize
    end subroutine spatial_grid_descriptor_SetGlobalConnectivitySize


    function spatial_grid_descriptor_GetGlobalConnectivitySize(this) result(GlobalConnectivitySize)
    !-----------------------------------------------------------------
    !< Get the total connectivity size of the spatial grid
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                    !< Spatial grid descriptor type
        integer(I8P)                                    :: GlobalConnectivitySize  !< Total size of connectivities of the spatial grid
    !----------------------------------------------------------------- 
        GlobalConnectivitySize = this%GlobalConnectivitySize
    end function spatial_grid_descriptor_GetGlobalConnectivitySize


    subroutine spatial_grid_descriptor_SetNumberOfNodesPerGridID(this, NumberOfNodes, ID)
    !-----------------------------------------------------------------
    !< Set the number of nodes of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this            !< Spatial grid descriptor type
        integer(I8P),                     intent(IN)    :: NumberOfNodes   !< Number of nodes of the grid ID
        integer(I4P),                     intent(IN)    :: ID              !< Grid identifier
    !-----------------------------------------------------------------
        this%NumberOfNodesPerGrid(ID+1) = NumberOfNodes
    end subroutine spatial_grid_descriptor_SetNumberOfNodesPerGridID


    function spatial_grid_descriptor_GetNumberOfNodesPerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the number of nodes of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this            !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID              !< Grid identifier
        integer(I8P) :: spatial_grid_descriptor_GetNumberOfNodesPerGridID !< Number of nodes of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetNumberOfNodesPerGridID = this%NumberOfNodesPerGrid(ID+1)
    end function spatial_grid_descriptor_GetNumberOfNodesPerGridID


    subroutine spatial_grid_descriptor_SetNumberOfElementsPerGridID(this, NumberOfElements, ID)
    !-----------------------------------------------------------------
    !< Set the number of nodes of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this            !< Spatial grid descriptor type
        integer(I8P),                     intent(IN)    :: NumberOfElements!< Number of elements of the grid ID
        integer(I4P),                     intent(IN)    :: ID              !< Grid identifier
    !-----------------------------------------------------------------
        this%NumberOfElementsPerGrid(ID+1) = NumberOfElements
    end subroutine spatial_grid_descriptor_SetNumberOfElementsPerGridID


    function spatial_grid_descriptor_GetNumberOfElementsPerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the number of elements of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this               !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID                 !< Grid identifier
        integer(I8P) :: spatial_grid_descriptor_GetNumberOfElementsPerGridID !< Number of elements of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetNumberOfElementsPerGridID = this%NumberOfElementsPerGrid(ID+1)
    end function spatial_grid_descriptor_GetNumberOfElementsPerGridID


    subroutine spatial_grid_descriptor_SetConnectivitySizePerGridID(this, ConnectivitySize, ID)
    !-----------------------------------------------------------------
    !< Set the connectivity size of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this            !< Spatial grid descriptor type
        integer(I8P),                     intent(IN)    :: ConnectivitySize!< Connectivity size of the grid ID
        integer(I4P),                     intent(IN)    :: ID              !< Grid identifier
    !-----------------------------------------------------------------
        this%ConnectivitySizePerGrid(ID+1) = ConnectivitySize
    end subroutine spatial_grid_descriptor_SetConnectivitySizePerGridID


    function spatial_grid_descriptor_GetConnectivitySizePerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the number of elements of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this               !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID                 !< Grid identifier
        integer(I8P) :: spatial_grid_descriptor_GetConnectivitySizePerGridID !< Connectivity Size of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetConnectivitySizePerGridID = this%ConnectivitySizePerGrid(ID+1)
    end function spatial_grid_descriptor_GetConnectivitySizePerGridID


    subroutine spatial_grid_descriptor_SetTopologyTypePerGridID(this, TopologyType, ID)
    !-----------------------------------------------------------------
    !< Set the topology type of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this            !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: TopologyType    !< Topology type of the grid ID
        integer(I4P),                     intent(IN)    :: ID              !< Grid identifier
    !-----------------------------------------------------------------
        this%TopologyTypePerGrid(ID+1) = TopologyType
    end subroutine spatial_grid_descriptor_SetTopologyTypePerGridID


    function spatial_grid_descriptor_GetTopologyTypePerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the topology type of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this           !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID             !< Grid identifier
        integer(I4P) :: spatial_grid_descriptor_GetTopologyTypePerGridID !< Topology type of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetTopologyTypePerGridID = this%TopologyTypePerGrid(ID+1)
    end function spatial_grid_descriptor_GetTopologyTypePerGridID


    subroutine spatial_grid_descriptor_SetGeometryTypePerGridID(this, GeometryType, ID)
    !-----------------------------------------------------------------
    !< Set the topology type of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this            !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: GeometryType    !< Geometry type of the grid ID
        integer(I4P),                     intent(IN)    :: ID              !< Grid identifier
    !-----------------------------------------------------------------
        this%GeometryTypePerGrid(ID+1) = GeometryType
    end subroutine spatial_grid_descriptor_SetGeometryTypePerGridID


    function spatial_grid_descriptor_GetGeometryTypePerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the geometry type of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this           !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID             !< Grid identifier
        integer(I4P) :: spatial_grid_descriptor_GetGeometryTypePerGridID !< Geometry type of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetGeometryTypePerGridID = this%GeometryTypePerGrid(ID+1)
    end function spatial_grid_descriptor_GetGeometryTypePerGridID


    function spatial_grid_descriptor_GetNodeOffsetPerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the node offset of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this         !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID           !< Grid identifier
        integer(I8P) :: spatial_grid_descriptor_GetNodeOffsetPerGridID !< Node offset of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetNodeOffsetPerGridID = sum(this%NumberOfNodesPerGrid(:ID))
    end function spatial_grid_descriptor_GetNodeOffsetPerGridID


    function spatial_grid_descriptor_GetElementOffsetPerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the element offset of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this            !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID              !< Grid identifier
        integer(I8P) :: spatial_grid_descriptor_GetElementOffsetPerGridID !< Element offset of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetElementOffsetPerGridID = sum(this%NumberOfElementsPerGrid(:ID))
    end function spatial_grid_descriptor_GetElementOffsetPerGridID


    function spatial_grid_descriptor_GetConnectivitySizeOffsetPerGridID(this, ID)
    !-----------------------------------------------------------------
    !< Return the connectivity size offset of a particular grid given its ID
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                     !< Spatial grid descriptor type
        integer(I4P),                     intent(IN)    :: ID                       !< Grid identifier
        integer(I8P) :: spatial_grid_descriptor_GetConnectivitySizeOffsetPerGridID !< Connectivity size offset of a grid
    !-----------------------------------------------------------------
        spatial_grid_descriptor_GetConnectivitySizeOffsetPerGridID = sum(this%ConnectivitySizePerGrid(:ID))
    end function spatial_grid_descriptor_GetConnectivitySizeOffsetPerGridID


    subroutine spatial_grid_descriptor_Initialize_Writer(this, MPIEnvironment, NumberOfNodes, NumberOfElements, TopologyType, GeometryType)
    !-----------------------------------------------------------------
    !< Initilized the spatial grid descriptor type
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                   !< Spatial grid descriptor type
        type(mpi_env_t), target,          intent(IN)    :: MPIEnvironment         !< MPI environment type
        integer(I8P),                     intent(IN)    :: NumberOfNodes          !< Number of nodes of the current grid
        integer(I8P),                     intent(IN)    :: NumberOfElements       !< Number of elements of the current grid
        integer(I4P),                     intent(IN)    :: TopologyType           !< Topology type of the current grid
        integer(I4P),                     intent(IN)    :: GeometryType           !< Geometry type of the current grid
        integer(I4P)                                    :: i                      !< Loop index in NumberOfGrids
    !-----------------------------------------------------------------
        call this%Free()
        this%MPIEnvironment => MPIEnvironment
        call this%MPIEnvironment%mpi_allgather(NumberOfNodes, this%NumberOfNodesPerGrid)
        call this%MPIEnvironment%mpi_allgather(NumberOfElements, this%NumberOfElementsPerGrid)
        call this%MPIEnvironment%mpi_allgather(TopologyType, this%TopologyTypePerGrid)
        call this%MPIEnvironment%mpi_allgather(GeometryType, this%GeometryTypePerGrid)
        call this%SetGlobalNumberOfElements(sum(this%NumberOfElementsPerGrid))
        call this%SetGlobalNumberOfNodes(sum(this%NumberOfNodesPerGrid))
        this%NumberOfGrids = size(this%NumberOfNodesPerGrid, dim=1)
    end subroutine spatial_grid_descriptor_Initialize_Writer


    subroutine spatial_grid_descriptor_Initialize_Reader(this, MPIEnvironment)
    !-----------------------------------------------------------------
    !< Initilized the spatial grid descriptor type
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                   !< Spatial grid descriptor type
        type(mpi_env_t), target,          intent(IN)    :: MPIEnvironment         !< MPI environment type
    !-----------------------------------------------------------------
        call this%Free()
        this%MPIEnvironment => MPIEnvironment
    end subroutine spatial_grid_descriptor_Initialize_Reader


    subroutine spatial_grid_descriptor_AllgatherConnectivitySize(this, ConnectivitySize)
    !-----------------------------------------------------------------
    !< Allgather the connectivity size and sets the global connectivity seize
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                   !< Spatial grid descriptor type
        integer(I8P), optional,           intent(IN)    :: ConnectivitySize       !< Size of the array of connectivities
        integer(I4P)                                    :: i                      !< Loop index in NumberOfGrids
    !-----------------------------------------------------------------
        call this%MPIEnvironment%mpi_allgather(ConnectivitySize, this%ConnectivitySizePerGrid)
        call this%SetGlobalConnectivitySize(sum(this%ConnectivitySizePerGrid))
    end subroutine spatial_grid_descriptor_AllgatherConnectivitySize


    subroutine spatial_grid_descriptor_BroadcastMetadata(this)
    !-----------------------------------------------------------------
    !< Broadcast metadata after XDMF parsing
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this                   !< Spatial grid descriptor type
    !-----------------------------------------------------------------
        call this%MPIEnvironment%mpi_broadcast(this%NumberOfNodesPerGrid)
        call this%MPIEnvironment%mpi_broadcast(this%NumberOfElementsPerGrid)
        call this%SetGlobalNumberOfElements(sum(this%NumberOfElementsPerGrid))
        call this%SetGlobalNumberOfNodes(sum(this%NumberOfNodesPerGrid))
        call this%MPIEnvironment%mpi_broadcast(this%TopologyTypePerGrid)
        call this%MPIEnvironment%mpi_broadcast(this%GeometryTypePerGrid)
		this%NumberOfGrids = size(this%NumberOfNodesPerGrid, dim=1)
    end subroutine spatial_grid_descriptor_BroadcastMetadata


    subroutine spatial_grid_descriptor_Free(this)
    !-----------------------------------------------------------------
    !< Free the spatial grid descriptor type
    !----------------------------------------------------------------- 
        class(spatial_grid_descriptor_t), intent(INOUT) :: this       !< Spatial grid descriptor type
        integer(I4P)                                    :: i          !< Loop index in NumberOfGrids
        integer(I4P)                                    :: j          !< Loop index in NumberOfAttributes
    !----------------------------------------------------------------- 

        This%GlobalNumberOfNodes = 0
        This%GlobalNumberOfElements = 0
        if(allocated(this%NumberOfNodesPerGrid))    deallocate(this%NumberOfNodesPerGrid)
        if(allocated(this%NumberOfElementsPerGrid)) deallocate(this%NumberOfElementsPerGrid)
        if(allocated(this%TopologyTypePerGrid)) deallocate(this%TopologyTypePerGrid)
        if(allocated(this%GeometryTypePerGrid)) deallocate(this%GeometryTypePerGrid)
        nullify(this%MPIEnvironment)

    end subroutine spatial_grid_descriptor_Free


end module spatial_grid_descriptor