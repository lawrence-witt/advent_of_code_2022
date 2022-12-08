module class_Tree
    implicit none
    private
    public :: Tree, get_visibility, set_visibility

    type Tree
        integer :: height
        logical, dimension(4) :: visibility = [.false., .false., .false., .false.]
    end type Tree
contains
    function get_visibility(this) result(is_visible)
        class(Tree), intent(inout) :: this
        logical :: is_visible
        is_visible = this%visibility(1) .or. this%visibility(2) .or. this%visibility(3) .or. this%visibility(4)
    end function get_visibility
    subroutine set_visibility(this, dir)
        class(Tree), intent(inout) :: this
        integer, intent(in) :: dir
        if (dir > 0 .and. dir < 5) then
            this%visibility(dir) = .true.
        end if
    end subroutine set_visibility
endmodule class_Tree

program part1
    use class_Tree
    implicit none

    CHARACTER(128) :: buffer
    type(Tree), dimension(:,:), allocatable :: trees
    integer col_idx
    integer row_idx
    integer height
    integer max_height
    integer cols, rows
    integer io
    integer visible

    ! allocate array

    cols = 0
    rows = 0

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

    ! begin calculation

    visible = 0
    row_idx = 0
    max_height = -1
    
    do
        read(1, *, iostat=io) buffer
        if (io/=0) exit

        ! read l2r

        do col_idx=1, cols
            read(buffer(col_idx:col_idx), '(I1)') height
            trees(row_idx, col_idx - 1) = Tree(height)
            if (height > max_height) then
                call set_visibility(trees(row_idx, col_idx - 1), 1)
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
    enddo

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