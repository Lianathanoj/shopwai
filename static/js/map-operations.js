// var jsonData = {
//     "heatmap": {
//         "binSize": 1,
//         "units": "\u00B0C",
//         "map": [
//             {"x": 0, "y": 12, "value": 20.2},
//             {"x": 24, "y": 12, "value": 19.9},
//             {"x": 27, "y": 12, "value": 19.7},
//             {"x": 30, "y": 12, "value": 19.7},
//             {"x": 21, "y": 15, "value": 20.5},
//             {"x": 24, "y": 15, "value": 19.3},
//             {"x": 27, "y": 15, "value": 19.4},
//             {"x": 30, "y": 15, "value": 19.9}]
//     },
//     "overlays": {
//         "polygons": [
//             {"id": "p1", "name": "kitchen", "points": [{"x":2.513888888888882,"y":8.0},
//                 {"x":6.069444444444433,"y":8.0},
//                 {"x":6.069444444444434,"y":5.277535934291582},
//                 {"x":8.20833333333332,"y":2.208151950718685},
//                 {"x":13.958333333333323,"y":2.208151950718685},
//                 {"x":16.277777777777825,"y":5.277535934291582},
//                 {"x":16.277777777777803,"y":10.08151950718685},
//                 {"x":17.20833333333337,"y":10.012135523613962},
//                 {"x":17.27777777777782,"y":18.1387679671458},
//                 {"x":2.513888888888882,"y":18.0}]}
//         ]
//     },
//     "vectorfield": {
//         "binSize": 3,
//         "units": "ft/s",
//         "map": [
//             {"x": 18, "y": 21, "value": {"x": 1, "y": 1}},
//             {"x": 21, "y": 21, "value": {"x": 1, "y": 1}},
//             {"x": 18, "y": 24, "value": {"x": 1, "y": 1}},
//             {"x": 21, "y": 24, "value": {"x": 1, "y": 1}},
//             {"x": 24, "y": 24, "value": {"x": 1, "y": 1}}]
//     },
//     "pathplot": [{
//         "id": "flt-1",
//         "classes": "planned",
//         "points": [{"x": 23.8, "y": 30.6},{"x": 19.5, "y": 25.7},{"x": 14.5, "y": 25.7},{"x": 13.2, "y": 12.3}]
//     }]
// };

var xscale = d3.scale.linear()
        .domain([0,35.0])
        .range([0,700]),
    yscale = d3.scale.linear()
        .domain([0,30.0])
        .range([0,600]),
    map = d3.floorplan().xScale(xscale).yScale(yscale),
    imagelayer = d3.floorplan.imagelayer(),
    heatmap = d3.floorplan.heatmap(),
    vectorfield = d3.floorplan.vectorfield(),
    pathplot = d3.floorplan.pathplot(),
    overlays = d3.floorplan.overlays().editMode(true),
    mapdata = {};

// mapdata[imagelayer.id()] = [{
//     url: 'https://dciarletta.github.io/d3-floorplan/Sample_Floorplan.jpg',
//     x: 0,
//     y: 0,
//     height: 33.79,
//     width: 50.0
// }];

mapdata[imagelayer.id()] = [{
    url: 'https://i.imgur.com/OOSKum8.jpg',
    x: 0,
    y: 0,
    height: 30,
    width: 35
}];

map.addLayer(imagelayer)
    .addLayer(heatmap)
    // .addLayer(vectorfield)
    // .addLayer(pathplot)
    // .addLayer(overlays);

var loadData = function(data) {
    mapdata[heatmap.id()] = data.heatmap;
    mapdata[overlays.id()] = data.overlays;
    mapdata[vectorfield.id()] = data.vectorfield;
    mapdata[pathplot.id()] = data.pathplot;

    d3.select("#demo").append("svg")
        .attr("height", 600).attr("width",700)
        .datum(mapdata).call(map);
};

loadData(jsonData);