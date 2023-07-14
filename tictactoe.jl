@enum Result begin
    X = 1
    O = -1
    Ongoing = 2
    Tie = 0
end

#check for win
function who_won(A)::Result
    diag(A) = [A[i, i] for i in 1:size(A)[1]]
    crossdiag(A) = [A[i, end-i+1] for i in 1:size(A)[1]]

    n = 1
    X_wins = any(sum(row) == 3 * n for row in eachrow(A)) ||
             any(sum(col) == 3 * n for col in eachcol(A)) ||
             sum(diag(A)) == 3 * n ||
             sum(crossdiag(A)) == 3 * n

    n = -1
    O_wins = any(sum(row) == 3 * n for row in eachrow(A)) ||
             any(sum(col) == 3 * n for col in eachcol(A)) ||
             sum(diag(A)) == 3 * n ||
             sum(crossdiag(A)) == 3 * n

    if X_wins
        return X::Result
    end
    if O_wins
        return O::Result
    end
    if all(!iszero, A)
        return Tie::Result
    end
    return Ongoing::Result
end

#make a random move in an unoccupied square
function random_move(A)
    A = copy(A)
    available_indices = findall(iszero, A)
    if isempty(available_indices)
        return A
    end
    r = rand(available_indices)

    A[r] = sum(A) == 1 ? -1 : 1

    return A
end

#play a game using random moves
function game(A)
    while who_won(A) == Ongoing::Result
        A = random_move(A)
    end
    return who_won(A)
end

#evaluate the best move by playing a bunch of games
function eval_move(A; max_iterations=100)
    best_position = fill(max_iterations, 3, 3)
    for (i, v) in enumerate(A)
        if v == 0
            a = copy(A)
            a[i] = -1
            best_position[i] = mapreduce(+, 1:max_iterations) do _
                #runs a trial game given the move a[i]=-1.
                #Converts the result to Int to find the move with the most O wins
                copy(a) |> game |> Int
            end
        end
    end
    return findmin(best_position)[2] |> Tuple
end




