using HTTP
include("tictactoe.jl")

global A = zeros(3, 3)

function h(req)
    return HTTP.Response(200, read("index.html"))
end

function s(req)
    return HTTP.Response(200, read("tailwind/output.css"))
end

function reset(req)
    global A = zeros(3, 3)
    D = Dict(0 => "", 1 => "X", -1 => "O")
    board_update(A) = join(("""<div class="box" hx-put="/message" hx-target="#board" id="$(i)">$(D[A'[i]])</div>""" for i in 1:9), "\n")
    return HTTP.Response(
        200,
        board_update(A)
    )
end

function message(req)
    index = Dict(req.headers)["HX-Trigger"] |> x -> parse(Int64, x)
    D = Dict(0 => "", 1 => "X", -1 => "O")
    board_update(A) = join(("""<div class="box" hx-put="/message" hx-target="#board" id="$(i)">$(D[A'[i]])</div>""" for i in 1:9), "\n")

    if who_won(A) != Ongoing::Result
        return HTTP.Response(200, """<div id="youwin" hx-swap-oob="true">
        <span
          hx-put="/reset"
          hx-target="#board"
          class="p-2 text-white bg-purple-500 border-2 border-solid border-black rounded"
          >Reset?</span
        >
      </div>""" * board_update(A))
    end

    A'[index] = 1
    if A[eval_move(A)...] == 0
        A[eval_move(A)...] = -1
    end

    return HTTP.Response(
        200,
        board_update(A)
    )
end

router = HTTP.Router()
HTTP.register!(router, "GET", "/", h)
HTTP.register!(router, "GET", "/style.css", s)
HTTP.register!(router, "PUT", "/message", message)
HTTP.register!(router, "PUT", "/reset", reset)

close(server)
server = HTTP.serve!() do request::HTTP.Request
    return resp = router(request)
end

#close(server)