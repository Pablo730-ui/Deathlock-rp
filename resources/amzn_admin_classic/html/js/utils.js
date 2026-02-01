AdminPanel.Utils = AdminPanel.Utils || {};

AdminPanel.Utils.numberWithCommas = function(x){
    if (x === undefined || x === null) {
        return "0";
    }
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

AdminPanel.Utils.getReadableTime = function(t) {
    var dt = new Date(0);
    dt.setUTCSeconds(t);
    return dt.toLocaleString("en-US", {timeZone: "America/New_York"});
}

AdminPanel.Utils.timeSince = function(time) {
    var timeStamp = new Date(parseInt(time) * 1000);
    var now = new Date(),
    secondsPast = ((now.getTime() - timeStamp) / 1000);
    if (secondsPast < 60) {
        return parseInt(secondsPast) + 's ago';
    }
    if (secondsPast < 3600) {
        return parseInt(secondsPast / 60) + 'm ago';
    }
    if (secondsPast <= 86400) {
        return parseInt(secondsPast / 3600) + 'h ago';
    }
    if (secondsPast > 86400) {
        day = timeStamp.getDate();
        month = timeStamp.toDateString().match(/ [a-zA-Z]*/)[0].replace(" ", "");
        year = timeStamp.getFullYear() == now.getFullYear() ? "" : " " + timeStamp.getFullYear();
        return day + " " + month + year;
    }
}

AdminPanel.Utils.truncateLongString = function(str, n, useWordBoundary){
    if (!str) { return ''; }
    if (str.length <= n) { return str; }
    const subString = str.substr(0, n-1);
    return (useWordBoundary 
      ? subString.substr(0, subString.lastIndexOf(" ")) 
      : subString) + "&hellip;";
};

AdminPanel.Utils.mdToHtml = function(text) {
    var bold = /\*\*(.*?)\*\*/gm;
    var html = text.replace(bold, '<strong>$1</strong>');            
    return html;
}

var entityMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '/': '&#x2F;',
    '`': '&#x60;',
    '=': '&#x3D;'
};
  
AdminPanel.Utils.escapeHtml = function(string) {
    return String(string).replace(/[&<>"'`=\/]/g, function (s) {
        return entityMap[s];
    });
}

AdminPanel.Utils.clipboard = function(string) {
    AdminPanel.Utils.fallbackCopyTextToClipboard(string);
    AdminPanel.UI.showAlert("success", "<strong>SUCCESS:</strong> "+AdminPanel.Language.copiedTranslation);
}

AdminPanel.Utils.fallbackCopyTextToClipboard = function(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;
    
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";
  
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
  
    try {
      var successful = document.execCommand('copy');
      var msg = successful ? AdminPanel.Language.successfulTranslation : AdminPanel.Language.unsuccessfulTranslation;
    } catch (err) {
      console.error('Fallback: Oops, unable to copy', err);
    }
  
    document.body.removeChild(textArea);
}

AdminPanel.Utils.doFancyTableSearchClear = function() {
    setTimeout(function () {
        $(".clear-search").remove();
        $(".search-container").contents().unwrap();

        let $searchInput = $(".fancySearchRow input");

        let $searchTh = $(".fancySearchRow th");
        $searchTh.prop("colspan", 10);
        
        $searchInput.wrap('<div class="search-container" style="position: relative; display: block;"></div>');

        $(".search-container").append('<button class="clear-search">✖</button>');

        $(".clear-search").css({
            position: "absolute",
            right: "10px",
            top: "50%",
            transform: "translateY(-50%)",
            background: "transparent",
            border: "none",
            cursor: "pointer",
            fontSize: "16px",
            color: "#ff0000",
            display: "none" // Initially hidden
        });

        $searchInput.on("input", function () {
            if ($(this).val().length > 0) {
                $(".clear-search").show();
             } else {
                 $(".clear-search").hide();
             }
         });

        $(".clear-search").on("click", function () {
            $searchInput.val("").trigger("input").trigger("keyup");
            $(".clear-search").hide();
        });

        $(".fancySearchRow th div input").addClass("form-control");
    }, 10);
}

AdminPanel.Utils.numberFormat = function(e,n,r,o){
    var $,l,t,_=isFinite(+(e=(e+"").replace(",","").replace(" ","")))?+e:0,a=isFinite(+n)?Math.abs(n):0,d="";
    return(d=(a?($=_,""+Math.round($*(t=Math.pow(10,l=a)))/t):""+Math.round(_)).split("."))[0].length>3&&(d[0]=d[0].replace(/\B(?=(?:\d{3})+(?!\d))/g,void 0===o?",":o)),(d[1]||"").length<a&&(d[1]=d[1]||"",d[1]+=Array(a-d[1].length+1).join("0")),d.join(void 0===r?".":r)
} 