/**
 * SPDX-FileCopyrightText: 2022 Aditya Mehra
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

var insertedRowID

function dbInit()
{
    var db = LocalStorage.openDatabaseSync("RecentPages_Tracker_DB", "1.0", "RecentPageStorage", 1000000)
    try {
        db.transaction(function (tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS recent_log (date text,recent_url text,recent_name text,rand_color text)')
        })
    } catch (err) {
        console.log("Error creating table in database: " + err)
    };
}

function dbGetHandle()
{
    try {
        var db = LocalStorage.openDatabaseSync("RecentPages_Tracker_DB", "1.0",
                                               "RecentPageStorage", 1000000)
    } catch (err) {
        console.log("Error opening database: " + err)
    }
    return db
}

function dbInsert(Rdate, Rurl, Rname, Rcolor)
{
    var db = dbGetHandle()
    var rowid = 0;
    try {
    db.transaction(function (tx) {
        tx.executeSql('INSERT INTO recent_log VALUES(?, ?, ?, ?)',
                      [Rdate, Rurl, Rname, Rcolor])
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
                    'SELECT rowid,date,recent_url,recent_name,rand_color FROM recent_log order by rowid desc')
        for (var i = 0; i < results.rows.length; i++) {
            recentPagesModel.append({
                                 id: results.rows.item(i).rowid,
                                 checked: " ",
                                 date: results.rows.item(i).date,
                                 recent_url: results.rows.item(i).recent_url,
                                 recent_name: results.rows.item(i).recent_name,
                                 rand_color: results.rows.item(i).rand_color
                             })
        }
            recentPagesView.view.forceLayout()
    })
}

function dbUpdate(Rdate, Rurl, Rname, Rrowid, Rcolor)
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql(
                    'update recent_log set date=?, recent_url=?, recent_name=?, rand_color=? where rowid = ?', [Rdate, Rurl, Rname, Rrowid, Rcolor])
    })
}

function dbDeleteRow(Rrowid)
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql('delete from recent_log where rowid = ?', [Rrowid])
    })
}

function dbClearTable()
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql('DELETE FROM recent_log')
    })
    recentPagesModel.clear()
}
