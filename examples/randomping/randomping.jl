function randomping()
    count = 1
    t0 = time()
    while true
        sleep(1)
        e = Element(string(count),innerHTML = "Ping $(count): $(round(time()-t0,digits=2)) seconds")
        e.style["color"] = rand(["red","green","blue"])
        rand() < .5 && Pages.appendChild(e)
        count += 1
        tstart = time()
    end
end