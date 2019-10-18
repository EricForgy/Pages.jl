function _randomping()

    ping = true
    
    function loop()
        count = 1
        t0 = time()
        while ping
            sleep(1)
            msg = "Ping $(count): $(round(time()-t0,digits=2)) seconds"
            e = Pages.Element(id = string(count),innerHTML = msg)
            e.style["color"] = rand(["red","green","blue"])
            rand() < .5 && Pages.append(e)

            count += 1
            tstart = time()
        end
    end

    function start()
        ping = true

        @async loop()
        return
    end

    function stop()
        ping = false
        return
    end

    return (start=start,stop=stop)
end

randomping = _randomping()