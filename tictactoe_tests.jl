using Test
include("tictactoe.jl")

@testset verbose = true "who_won" begin
    @testset "vertical" begin
        A = zeros(3, 3)
        A[1:3, 1] .= 1
        @test who_won(A) == X::Result
    end

    @testset "horizontal" begin
        A = zeros(3, 3)
        A[1, 1:3] .= 1
        @test who_won(A) == X::Result
    end

    @testset "diagonal" begin
        A = zeros(3, 3)
        [A[i, i] = 1 for i in 1:size(A)[1]]
        @test who_won(A) == X::Result
    end

    @testset "cross-diagonal" begin
        A = zeros(3, 3)
        [A[i, end-i+1] = 1 for i in 1:size(A)[1]]
        @test who_won(A) == X::Result
    end

    @testset "negative values can win" begin
        A = zeros(3, 3)
        [A[i, end-i+1] = -1 for i in 1:size(A)[1]]
        @test who_won(A) == O::Result
    end

    @testset "draws can happen" begin
        A = [-1 1 -1
            -1 1 -1
            1 -1 1]
        @test who_won(A) == Tie::Result
    end

    @testset "unresolved games return a 0" begin
        A = zeros(3, 3)
        @test who_won(A) == Ongoing::Result
    end
end

@testset verbose = true "random_move" begin
    @testset "has actually moved" begin
        A = zeros(3, 3)
        A[1] = 1
        @test -1 in random_move(A)
    end

    @testset "does not reassign to a value ever" begin
        A = zeros(3, 3)
        A[1] = 1
        @test all(A[1] == random_move(A)[1] for i in 1:100)
    end
end

@testset verbose = true "game" begin
    @testset "game never results in Ongoing::Result" begin
        @test all(game(zeros(3, 3)) != Ongoing::Result for i in 1:1000)
    end

    @testset "X should have a slight first move advantage in a random game" begin
        @test 100 < sum(Int(game(zeros(3, 3))) for i in 1:1000) < 500
    end
end

@testset "eval_move" begin
    @testset "center move if X goes to the upper left" begin
        A = zeros(3, 3)
        A[1] = 1
        @test eval_move(A) == (2, 2)
    end

    @testset "corner move if X goes to the center" begin
        A = zeros(3, 3)
        A[2, 2] = 1
        @test all(2 ∉ eval_move(A) for i in 1:10)
    end

    @testset "move to block X from winning next turn" begin
        A = [0 0 0
            0 1 0
            0 0 1]
        eval_move(A)
        @test all(eval_move(A) == (1, 1) for i in 1:10)
    end

    @testset "should attempt to win" begin
        A = [0 0 0
            0 -1 -1
            0 0 0]
        eval_move(A)
        @test all(eval_move(A) == (2, 1) for i in 1:10)
    end

    @testset "defaults to upperleft corner if all spaces blocked" begin
        A = ones(3, 3)
        eval_move(A)
        @test all(eval_move(A) == (1, 1) for i in 1:10)
    end
end