program test_mpi_environment

use IR_Precision, only : I4P, I8P, R4P, R8P, str

use mpi_environment
#ifdef MPI_MOD
  use mpi
#endif
#ifdef MPI_H
  include 'mpif.h'
#endif

implicit none

    type(mpi_env_t) :: env
    integer         :: mpierr
    integer(I4P), allocatable :: recv_int(:)
    integer(I8P), allocatable :: recv_double_int(:)

#if defined(MPI_MOD) || defined(MPI_H)
    call MPI_INIT(mpierr)
#endif

    call env%initialize()

    call env%mpi_allgather_single_int_value(env%get_rank(), recv_int)
    call env%mpi_allgather_single_int_value(int(env%get_rank(),I8P), recv_double_int)

    if(env%get_rank() == env%get_root()) then
        print*, 'The MPI communicator has '//trim(str(no_sign=.true.,n=env%get_comm_size()))//&
                ' tasks and I am task '//trim(str(no_sign=.true., n=env%get_rank())), ' (root)'
        print*, 'Allgather task IDs in single precision integers are: ', str(no_sign=.true., n=recv_int)
        print*, 'Allgather task IDs in double precision integers are: ', str(no_sign=.true., n=recv_double_int)
    else
        print*, 'The MPI communicator has '//trim(str(no_sign=.true., n=env%get_comm_size()))//&
                ' tasks and I am task '//trim(str(no_sign=.true., n=env%get_rank()))
    endif

#if defined(MPI_MOD) || defined(MPI_H)
    call MPI_FINALIZE(mpierr)
#endif

end program test_mpi_environment
