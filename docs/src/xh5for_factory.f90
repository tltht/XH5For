module xh5for_factory

use PENF, only: I4P
use xh5for_parameters
use xh5for_abstract_factory
use structured_contiguous_hyperslab_factory
use unstructured_contiguous_hyperslab_factory
use structured_dataset_per_process_factory
use unstructured_dataset_per_process_factory

implicit none
private

    type :: xh5for_factory_t
    contains
        procedure :: CreateFactory => xh5for_factory_CreateFactory
    end type xh5for_factory_t

type(xh5for_factory_t), public :: TheXH5ForFactoryCreator

contains

    subroutine xh5for_factory_CreateFactory(this, GridType, Strategy, AbstractFactory)
    !-----------------------------------------------------------------
    !< Return a concrete factory given Strategy and GridType
    !----------------------------------------------------------------- 
        class(xh5for_factory_t),                       intent(IN)  :: this
        integer(I4P),                                  intent(IN)  :: GridType
        integer(I4P),                                  intent(IN)  :: Strategy
        class(xh5for_abstract_factory_t), allocatable, intent(OUT) :: AbstractFactory
    !----------------------------------------------------------------- 
        select case (GridType)
            case (XDMF_GRID_TYPE_UNSTRUCTURED)
                select case (Strategy)
                    case (XDMF_STRATEGY_CONTIGUOUS_HYPERSLAB)
                        allocate(unstructured_contiguous_hyperslab_factory_t :: AbstractFactory)
                    case (XDMF_STRATEGY_DATASET_PER_PROCESS)
                        allocate(unstructured_dataset_per_process_factory_t :: AbstractFactory)
                    case DEFAULT
                        print*, 'Strategy not Implemented yet!', Strategy
                end select
            case (XDMF_GRID_TYPE_RECTILINEAR)
                select case (Strategy)
                    case (XDMF_STRATEGY_CONTIGUOUS_HYPERSLAB)
                        allocate(structured_contiguous_hyperslab_factory_t :: AbstractFactory)
                    case (XDMF_STRATEGY_DATASET_PER_PROCESS)
                        allocate(structured_dataset_per_process_factory_t :: AbstractFactory)
                    case DEFAULT
                        print*, 'Strategy not Implemented yet!', Strategy
                end select
            case (XDMF_GRID_TYPE_REGULAR)
                select case (Strategy)
                    case (XDMF_STRATEGY_CONTIGUOUS_HYPERSLAB)
                        allocate(structured_contiguous_hyperslab_factory_t :: AbstractFactory)
                    case (XDMF_STRATEGY_DATASET_PER_PROCESS)
                        allocate(structured_dataset_per_process_factory_t :: AbstractFactory)
                    case DEFAULT
                        print*, 'Strategy not Implemented yet!', Strategy
                end select

            case DEFAULT
                print*, 'GridType not Implemented yet!', GridType            
        end select
    end subroutine xh5for_factory_CreateFactory

end module xh5for_factory
