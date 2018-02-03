module Plotly

function newPlot(graphdiv,data,layout,options)
    Pages.broadcast("script","""Plotly.newPlot("$(id)",$(data),$(layout),$(options));""")
end

end