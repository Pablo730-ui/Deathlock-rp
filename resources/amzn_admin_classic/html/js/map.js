AdminPanel.Map = AdminPanel.Map || {};

AdminPanel.Map.init = function() {
    AdminPanel.Map.setupMapConstants();
    AdminPanel.Map.initializeMap();
}

AdminPanel.Map.setupMapConstants = function() {
    AdminPanel.Map.centerX = 117.3;
    AdminPanel.Map.centerY = 172.8;
    AdminPanel.Map.scaleX = 0.02072;
    AdminPanel.Map.scaleY = 0.0205;

    AdminPanel.Map.CUSTOM_CRS = L.extend({}, L.CRS.Simple, {
        projection: L.Projection.LonLat,
        scale: function(zoom) {
            return Math.pow(2, zoom);
        },
        zoom: function(sc) {
            return Math.log(sc) / 0.6931471805599453;
        },
        distance: function(pos1, pos2) {
            var x_difference = pos2.lng - pos1.lng;
            var y_difference = pos2.lat - pos1.lat;
            return Math.sqrt(x_difference * x_difference + y_difference * y_difference);
        },
        transformation: new L.Transformation(AdminPanel.Map.scaleX, AdminPanel.Map.centerX, -AdminPanel.Map.scaleY, AdminPanel.Map.centerY),
        infinite: true
    });
}

AdminPanel.Map.initializeMap = function() {
    var AtlasStyle = L.tileLayer('mapStyles/styleAtlas/{z}/{x}/{y}.jpg', {
        minZoom: 0,
        maxZoom: 5,
        noWrap: true,
        continuousWorld: false,
        attribution: 'Online map GTA V',
        id: 'styleAtlas map',
    });

    var LayerGroup = L.layerGroup();

    var Icons = {
        "Players": LayerGroup,
    };

    var mymap = L.map('map', {
        crs: AdminPanel.Map.CUSTOM_CRS,
        minZoom: 1,
        maxZoom: 5,
        Zoom: 5,
        maxNativeZoom: 5,
        preferCanvas: true,
        layers: [AtlasStyle],
        center: [0, 0],
        zoom: 3,
    });

    AdminPanel.Map.instance = mymap;
    AdminPanel.MapIcons = Icons;
    AdminPanel.LayerGroup = LayerGroup;

    var layersControl = L.control.layers({ "Atlas": AtlasStyle }, Icons).addTo(mymap);
    LayerGroup.addTo(mymap);
}

AdminPanel.Map.customIcon = function(icon) {
    return L.icon({
        iconUrl: `blips/${icon}.png`,
        iconSize: [20, 20],
        iconAnchor: [10, 10], 
        popupAnchor: [0, -10]
    });
}

AdminPanel.Map.reset = function() {
    AdminPanel.LayerGroup.clearLayers();

    for (const [key, value] of Object.entries(AdminPanel.MapInfo)) {
        var X = value.coords.x;
        var Y = value.coords.y;
        L.marker([Y, X], { icon: AdminPanel.Map.customIcon(1) })
            .addTo(AdminPanel.MapIcons["Players"])
            .bindPopup("<strong>" + value.name + "</strong> (" + value.charname + ")<br/>ID: " + value.id);
    }

    $("#loading").hide();
    $("#playermappage").show();
    AdminPanel.EnableNav();
    AdminPanel.Map.instance.invalidateSize();
} 