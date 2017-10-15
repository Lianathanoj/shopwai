var xscale = d3.scale.linear()
        .domain([0,700.0])
        .range([0,700]),
    yscale = d3.scale.linear()
        .domain([0,600.0])
        .range([0,600]),
    map = d3.floorplan().xScale(xscale).yScale(yscale),
    imagelayer = d3.floorplan.imagelayer(),
    heatmap = d3.floorplan.heatmap(),
    vectorfield = d3.floorplan.vectorfield(),
    pathplot = d3.floorplan.pathplot(),
    overlays = d3.floorplan.overlays().editMode(true),
    mapdata = {};

mapdata[imagelayer.id()] = [{
    url: 'https://i.imgur.com/OOSKum8.jpg',
    x: 0,
    y: 0,
    height: 600,
    width: 700
}];

map.addLayer(imagelayer)
    .addLayer(heatmap)
    // .addLayer(vectorfield)
    .addLayer(pathplot)
    // .addLayer(overlays);

var loadData = function(data) {
    mapdata[heatmap.id()] = data.heatmap;
    mapdata[overlays.id()] = data.overlays;
    mapdata[vectorfield.id()] = data.vectorfield;
    mapdata[pathplot.id()] = data.pathplot;

    h = 600;
    w = $('#demo').parent().width();

    mapdata[imagelayer.id()][0].width = w;

    d3.select("#demo").append("svg").attr("viewBox", "0 0 700 600")
        .attr("height", h).attr("width",w)
        .datum(mapdata).call(map);
};

loadData(jsonData);