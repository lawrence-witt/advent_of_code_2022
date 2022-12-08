include "tree.f90"
include "alloc.f90"

program part1
    use class_Tree
    use utils_Alloc
    implicit none

    integer :: col_idx = 0
    integer :: row_idx = 0
    integer :: height = 0
    integer :: max_height = -1
    integer :: visible = 0

    call allocate_array()
    
    do
        read(1, *, iostat=io) buffer
        if (io/=0) exit

        ! read l2r

        do col_idx=0, cols - 1
            read(buffer(col_idx + 1:col_idx + 1), '(I1)') height
            trees(row_idx, col_idx) = Tree(height)
            if (height > max_height) then
                call set_visibility(trees(row_idx, col_idx), 1)
                max_height = height
            end if
        enddo

        col_idx = cols - 1
        max_height = -1

        ! read r2l

        do while (col_idx >= 0)
            height = trees(row_idx, col_idx)%height
            if (height > max_height) then
                call set_visibility(trees(row_idx, col_idx), 2)
                max_height = height
            end if
            col_idx = col_idx - 1
        end do

        row_idx = row_idx + 1
        max_height = -1
    end do

    do col_idx = 0, cols - 1
        max_height = -1

        ! read t2b
        
        do row_idx = 0, rows - 1
            height = trees(row_idx, col_idx)%height
            if (height > max_height) then
                call set_visibility(trees(row_idx, col_idx), 3)
                max_height = height
            end if
        end do

        ! read b2t

        row_idx = rows - 1
        max_height = -1

        do while (row_idx >= 0)
            height = trees(row_idx, col_idx)%height
            if (height > max_height) then
                call set_visibility(trees(row_idx, col_idx), 4)
                max_height = height
            end if
            if (get_visibility(trees(row_idx, col_idx))) then
                visible = visible + 1
            end if
            row_idx = row_idx - 1
        end do
    end do

    print*, visible
end program part1