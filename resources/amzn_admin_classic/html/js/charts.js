AdminPanel.Charts = AdminPanel.Charts || {};

AdminPanel.Charts.init = function() {
    Chart.defaults.global.defaultFontFamily = 'sans-serif', '-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';
    Chart.defaults.global.defaultFontColor = '#858796';
}

AdminPanel.Charts.LineChart = null;

AdminPanel.Charts.refreshPlayerChart = function() {
    var data = [];
    var times = [];

    for (const [key, value] of Object.entries(AdminPanel.ServerInformation.PlayerCountHistory)) {
        data.push(value);
        var date = new Date(key * 1000);
        times.push(date.toLocaleTimeString('en-US', {
            hour: '2-digit',
            minute: '2-digit'
        }));
    }

    $("#playerCountChart").empty();

    if (AdminPanel.Charts.LineChart != null) {
        AdminPanel.Charts.LineChart.destroy();
    }

    var ctx = document.getElementById("playerCountChart");
    AdminPanel.Charts.LineChart = new Chart(ctx, {
        type: "line",
        data: {
            labels: times,
            datasets: [{
                label: "Player Count",
                lineTension: .3,
                backgroundColor: "rgba(78, 115, 223, 0.05)",
                borderColor: "rgba(78, 115, 223, 1)",
                pointRadius: 3,
                pointBackgroundColor: "rgba(78, 115, 223, 1)",
                pointBorderColor: "rgba(78, 115, 223, 1)",
                pointHoverRadius: 3,
                pointHoverBackgroundColor: "rgba(78, 115, 223, 1)",
                pointHoverBorderColor: "rgba(78, 115, 223, 1)",
                pointHitRadius: 10,
                pointBorderWidth: 2,
                data: data
            }]
        },
        options: {
            maintainAspectRatio: !1,
            layout: {
                padding: {
                    left: 10,
                    right: 25,
                    top: 25,
                    bottom: 0
                }
            },
            scales: {
                xAxes: [{
                    time: {
                        unit: "date"
                    },
                    gridLines: {
                        display: !1,
                        drawBorder: !1
                    },
                    ticks: {
                        maxTicksLimit: 7
                    }
                }],
                yAxes: [{
                    ticks: {
                        maxTicksLimit: 5,
                        padding: 10
                    },
                    gridLines: {
                        color: "rgb(234, 236, 244)",
                        zeroLineColor: "rgb(234, 236, 244)",
                        drawBorder: !1,
                        borderDash: [2],
                        zeroLineBorderDash: [2]
                    }
                }]
            },
            legend: {
                display: !1
            },
            tooltips: {
                backgroundColor: "rgb(255,255,255)",
                bodyFontColor: "#858796",
                titleMarginBottom: 10,
                titleFontColor: "#6e707e",
                titleFontSize: 14,
                borderColor: "#dddfeb",
                borderWidth: 1,
                xPadding: 15,
                yPadding: 15,
                displayColors: !1,
                intersect: !1,
                mode: "index",
                caretPadding: 10
            }
        }
    });
}

AdminPanel.Charts.init(); 