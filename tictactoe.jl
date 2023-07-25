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
    i = 0
    while who_won(A) == Ongoing::Result
        A = random_move(A)
        i += 1
    end
    return (who_won(A), i)
end

#evaluate the best move by playing a bunch of games
function eval_move(A; max_iterations=1000)
    best_position = fill(max_iterations, 3, 3)
    for (i, v) in enumerate(A)
        if v == 0
            a = copy(A)
            a[i] = -1
            best_position[i] = mapreduce(+, 1:max_iterations) do _
                #runs a trial game given the move a[i]=-1.
                #Converts the result to Int to find the move with the most O wins
                c = copy(a) |> game |> x -> (Int(x[1]), x[2])
                if c[1] == 1 && c[2] == 1
                    return 10000
                end
                # if c[1] == 1
                #     return 1
                # end
                if c[1] == -1
                    return -1
                end
                #if c == -1
                return 0
            end
        end
    end
    #display(best_position)
    return findmin(best_position)[2] |> Tuple
end

function minimax(A, depth, maximizing_player)
    if depth == 1 || who_won(A) != Ongoing::Result
        if who_won(A) == Ongoing::Result
            return 0
        end
        return who_won(A) |> Int
    end

    if maximizing_player
        max_eval = -Inf
        for i in 1:9
            if A[i] == 0
                a = copy(A)
                a[i] = 1
                eval = minimax(a, depth - 1, false)

                max_eval = max(max_eval, eval)
            end
        end
        return max_eval
    else
        min_eval = Inf
        for i in 1:9
            if A[i] == 0

                a = copy(A)
                a[i] = -1
                eval = minimax(a, depth - 1, true)

                min_eval = min(min_eval, eval)
            end
        end
        return min_eval
    end
end

function find_best_move(A)
    best_eval = Inf
    best_move = 1

    for i in 1:9
        if A[i] == 0
            a = copy(A)
            a[i] = -1
            eval = minimax(a, 9, true)

            if eval < best_eval
                best_eval = eval
                best_move = i
            end
        end
    end

    return best_move
end


