function getUrlVars() {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
                vars[key] = value;
        });
        return vars;
}

function drawTag(t) {
        var width = 960,
height = 2200;

var cluster = d3.layout.cluster()
        .size([height, width - 160]);

var diagonal = d3.svg.diagonal()
        .projection(function(d) { return [d.y, d.x]; });

var vis = d3.select("#chart").append("svg")
        .attr("width", width)
        .attr("height", height)
        .append("g")
        .attr("transform", "translate(40, 0)");

d3.json("/tag_tree.json?t="+t, function(json) {
        var nodes = cluster.nodes(json);

        var link = vis.selectAll("path.link")
        .data(cluster.links(nodes))
        .enter().append("path")
        .attr("class", "link")
        .attr("d", diagonal);

var node = vis.selectAll("g.node")
        .data(nodes)
        .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })

        node.append("circle")
        .attr("r", 4.5);
node.append("foreignObject")
        .attr("dx", function(d) { return d.children ? -8 : 8; })
        .attr("dy", 3)
        .attr("x",5)
        .attr("y",-8)
        .attr("width",150)
        .attr("height",20)
        .attr("text-anchor", function(d) { return d.children ? "end" : "start"; })
        .append("xhtml:body")
        .html(function(d) { return '<a href="'+d.link+'">'+d.name+"</a>"; });
});
}

$(function() {
var tag = getUrlVars()['t'];
console.log(tag);
if (tag) {
  drawTag(tag);
}else{
 $("body").html("<a href=\"?t=classical\">Enter the tree</a>") 
}
});
