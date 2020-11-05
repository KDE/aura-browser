function updateTabName(){
    tabsListView.currentItem.tabName = "123"
}

function genRandomColor() {
    var color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
    console.log(color)
    return color
}

function navigateKeyRight(){
    if(navMode == "vMouse"){
       Cursor.move(3);
    }
    if(navMode == "vKey"){
        mItem.moveRight()
    }
}

function navigateKeyLeft(){
    if(navMode == "vMouse"){
       Cursor.move(2);
    }
    if(navMode == "vKey"){
        mItem.moveLeft()
    }
}

function navigateKeyUp(){
    if(navMode == "vMouse"){
       Cursor.move(0);
        var topH = flickable.height * (20/100)
        if(Cursor.pos.y < topH / 2 && flickable.height < flickable.contentHeight) {
            flickDown()
        }
    }
    if(navMode == "vKey"){
       mItem.moveUp()
    }
}

function navigateKeyDown(){
    if(navMode == "vMouse"){
        Cursor.move(1);
        var bottomH = flickable.height - (flickable.height * (20/100))
        if(Cursor.pos.y > bottomH  && flickable.height < flickable.contentHeight) {
            flickUp()
        }
    }
    if(navMode == "vKey"){
        mItem.moveDown()
    }
}

function navigateKeyClick(){
    console.log(navMode)
    if(navMode == "vMouse"){
       Cursor.click()
    }
    if(navMode == "vKey"){
        console.log("inClickNavClick")
        moveClick()
    }
}

function insertRecentToStorage(pUrl, pTitle){
    var date = new Date()
    var pColor = Utils.genRandomColor();
    RecentStorage.dbInsert(date, pUrl, pTitle, pColor)
}


function insertBookmarkToManager(rUrl, rTitle, rCategory){
    var date = new Date()
    var rColor = Utils.genRandomColor();
    BookmarkStorage.dbInsert(date, rUrl, rTitle, rColor, rCategory)
    genericModel.clear();
    delegateFilter.model.clear();
    BookmarkStorage.dbReadAll();
}


function checkURL(value) {
    var urlregex = new RegExp("^(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\?\'\\\+&amp;%\$#\=~_\-]+))*$");
    if (urlregex.test(value)) {
        return (true);
    }
    return (false);
}
