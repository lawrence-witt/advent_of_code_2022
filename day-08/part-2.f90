include 'tree.f90'

program part2
    use class_Tree
    implicit none

    integer io
    CHARACTER(128) :: buffer
    integer :: cols = 0, rows = 0

    type(Tree), dimension(:,:), allocatable :: trees
    integer :: col_idx = 0
    integer :: row_idx = 0
    integer :: height = 0
    integer :: score = 0
    integer :: max_score = 0
    integer sub_idx

    ! allocate array

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
    
    do
        read(1, *, iostat=io) buffer
        if (io/=0) exit

        ! read l2r

        do col_idx=0, cols - 1
            read(buffer(col_idx + 1:col_idx + 1), '(I1)') height
            trees(row_idx, col_idx) = Tree(height)
            sub_idx = col_idx - 1
            do while (sub_idx >= -1)
                if (sub_idx == -1) then
                    call set_scenic_score(trees(row_idx, col_idx), 1, col_idx)
                    exit
                end if
                if (trees(row_idx, sub_idx)%height >= height) then
                    call set_scenic_score(trees(row_idx, col_idx), 1, col_idx - sub_idx)
                    exit
                end if
                sub_idx = sub_idx - 1
            end do
        end do

        ! read r2l

        col_idx = cols - 1

        do while (col_idx >= 0)
            height = trees(row_idx, col_idx)%height
            do sub_idx = col_idx + 1, cols
                if (sub_idx == cols) then
                    call set_scenic_score(trees(row_idx, col_idx), 2, cols - col_idx - 1)
                    exit
                end if
                if (trees(row_idx, sub_idx)%height >= height) then
                    call set_scenic_score(trees(row_idx, col_idx), 2, sub_idx - col_idx)
                    exit
                end if
            end do
            col_idx = col_idx - 1
        end do

        row_idx = row_idx + 1
    end do

    do col_idx = 0, cols - 1
        ! read t2b
        
        do row_idx = 0, rows - 1
            height = trees(row_idx, col_idx)%height
            sub_idx = row_idx - 1
            do while(sub_idx >= -1)
                if (sub_idx == -1) then
                    call set_scenic_score(trees(row_idx, col_idx), 3, row_idx)
                    exit
                end if
                if (trees(sub_idx, col_idx)%height >= height) then
                    call set_scenic_score(trees(row_idx, col_idx), 3, row_idx - sub_idx)
                    exit
                end if
                sub_idx = sub_idx - 1
            end do
        end do

        ! read b2t

        row_idx = rows - 1

        do while (row_idx >= 0)
            height = trees(row_idx, col_idx)%height
            do sub_idx = row_idx + 1, rows
                if (sub_idx == rows) then
                    call set_scenic_score(trees(row_idx, col_idx), 4, rows - row_idx - 1)
                    exit
                end if
                if (trees(sub_idx, col_idx)%height >= height) then
                    call set_scenic_score(trees(row_idx, col_idx), 4, sub_idx - row_idx)
                    exit
                end if
            end do
            score = get_scenic_score(trees(row_idx, col_idx))
            if (score > max_score) then
                max_score = score
            end if
            row_idx = row_idx - 1
        end do
    end do

    print*, max_score
end program part2