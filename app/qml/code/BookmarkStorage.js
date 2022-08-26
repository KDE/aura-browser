/**
 * SPDX-FileCopyrightText: 2022 Aditya Mehra
 * SPDX-License-Identifier: GPL-2.0-or-later
 */


var prebookmarklist = [{ "url": "https://www.nytimes.com", "name": "NY Times", "color": "black", "category": "News" },
                       { "url": "https://www.bbc.com", "name": "BBC News", "color": "firebrick", "category": "News" },
                       { "url": "https://www.bloomberg.com", "name": "Bloomberg", "color": "dodgerblue", "category": "News" },
                       { "url": "https://www.youtube.com", "name": "Youtube", "color": "darkred", "category": "Entertainment" },
                       { "url": "https://www.vimeo.com", "name": "Vimeo", "color": "darkturquoise", "category": "Entertainment" },
                       { "url": "https://www.netflix.com", "name": "Netflix", "color": "black", "category": "Entertainment" },
                       { "url": "https://www.reddit.com", "name": "Reddit", "color": "orangered", "category": "Infotainment" },
                       { "url": "https://www.wikipedia.com", "name": "Wikipedia", "color": "slateblue", "category": "Infotainment" },
                       { "url": "https://www.google.com", "name": "Google", "color": "lightcoral", "category": "General" },
                       { "url": "https://www.duckduckgo.com", "name": "DuckDuckGo", "color": "orange", "category": "General" }]

function dbInit()
{
    var db = LocalStorage.openDatabaseSync("Bookmark_Tracker_DB", "1.0", "BookmarkStorage", 1000000)
    try {
        db.transaction(function (tx) {
            console.log("here in bookmarks init")
            tx.executeSql('CREATE TABLE IF NOT EXISTS bookmark_log (date text,recent_url text,recent_name text,rand_color text,category text)')
        })
    } catch (err) {
        console.log("Error creating table in database: " + err)
    };
}


function dbGetHandle()
{
    try {
        var db = LocalStorage.openDatabaseSync("Bookmark_Tracker_DB", "1.0",
                                               "BookmarkStorage", 1000000)
    } catch (err) {
        console.log("Error opening database: " + err)
    }
    return db
}

function prePopulateBookmarks(){
    for (var i = 0; i < prebookmarklist.length; i++){
        var date = new Date();
        var url = prebookmarklist[i].url;
        var name = prebookmarklist[i].name;
        var color = prebookmarklist[i].color;
        var category = prebookmarklist[i].category;
        dbInsert(date, url, name, color, category);
    }
}

function dbInsert(Rdate, Rurl, Rname, Rcolor, Rcategory)
{
    var db = dbGetHandle()
    var rowid = 0;
    try {
        db.transaction(function (tx) {
            tx.executeSql('INSERT INTO bookmark_log VALUES(?, ?, ?, ?, ?)',
                          [Rdate, Rurl, Rname, Rcolor, Rcategory])
            var result = tx.executeSql('SELECT last_insert_rowid()')
            rowid = result.insertId
        }) } catch (err) {
        console.log("Error Inserting In DB: " + err)
    }
    return rowid;
}

function dbReadAll()
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        var results = tx.executeSql(
                    'SELECT rowid,date,recent_url,recent_name,rand_color,category FROM bookmark_log order by rowid desc')
        for (var i = 0; i < results.rows.length; i++) {
            bookmarksModel.append({
                                      id: results.rows.item(i).rowid,
                                      checked: " ",
                                      date: results.rows.item(i).date,
                                      recent_url: results.rows.item(i).recent_url,
                                      recent_name: results.rows.item(i).recent_name,
                                      rand_color: results.rows.item(i).rand_color,
                                      category: results.rows.item(i).category
                                  })
        }
    })
}

function dbUpdate(Rdate, Rurl, Rname, Rrowid, Rcolor, Rcategory)
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql(
                    'update bookmark_log set date=?, recent_url=?, recent_name=?, rand_color=?, category=? where rowid = ?', [Rdate, Rurl, Rname, Rrowid, Rcolor, Rcategory])
    })
}

function dbDeleteRow(Rrowid)
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql('delete from bookmark_log where rowid = ?', [Rrowid])
    })
}

function dbClearTable()
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql('DELETE FROM bookmark_log')
    })
    bookmarksModel.clear()
}
