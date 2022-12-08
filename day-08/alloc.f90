module utils_Alloc
    use class_Tree
    implicit none

    integer io
    CHARACTER(128) :: buffer
    integer :: cols = 0, rows = 0
    type(Tree), dimension(:,:), allocatable :: trees
contains
    subroutine allocate_array()
        open (1, file = 'input.txt', status = 'old')

        read(1, '(a)') buffer
        rewind 1
    
        cols = len(buffer)
        do while (buffer(cols:cols) == " ")
            cols = cols - 1
        enddo
    
        do
            read(1, *, iostat=io)
            if (io/=0) exit
            rows = rows + 1
        enddo
    
        rewind 1
    
        allocate(trees(cols + 1, rows + 1))
    end subroutine allocate_array
end module utils_Alloc