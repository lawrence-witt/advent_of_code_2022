module class_Tree
    implicit none
    private
    public :: Tree, get_scenic_score, set_scenic_score, get_visibility, set_visibility

    type Tree
        integer :: height
        logical, dimension(4) :: visibility = [.false., .false., .false., .false.]
        integer, dimension(4) :: scenic_score = [0, 0, 0, 0]
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

    function get_scenic_score(this) result(score)
        class(Tree), intent(inout) :: this
        integer :: score
        score = this%scenic_score(1) * this%scenic_score(2) * this%scenic_score(3) * this%scenic_score(4)
    end function get_scenic_score
    
    subroutine set_scenic_score(this, dir, score)
        class(Tree), intent(inout) :: this
        integer, intent(in) :: dir
        integer, intent(in) :: score
        if (dir > 0 .and. dir < 5) then
            this%scenic_score(dir) = score
        end if
    end subroutine set_scenic_score
endmodule class_Tree