//Insert: A continuación voy a ingresar solamente 3 items nuevos a la base, debido a que la base ya es muy grande para agregar más, sin embargo, la logica se entiende.

var array_items= [
{ "ts": new Date().toISOString(), "username": "sebastiancalderonquintero", "platform": "android", "ms_played": 1, "conn_country": "ES","master_metadata_track_name": "Wildflower", "master_metadata_album_artist_name": "Billie Eilish", "master_metadata_album_album_name": "HIT ME HARD AND SOFT"} ,
{ "ts": new Date().toISOString(), "username": "sebastiancalderonquintero", "platform": "android", "ms_played": 1, "conn_country": "ES","master_metadata_track_name": "The Greatest", "master_metadata_album_artist_name": "Billie Eilish", "master_metadata_album_album_name": "HIT ME HARD AND SOFT"} ,
{ "ts": new Date().toISOString(), "username": "sebastiancalderonquintero", "platform": "android", "ms_played": 1, "conn_country": "ES","master_metadata_track_name": "Skinny", "master_metadata_album_artist_name": "Billie Eilish", "master_metadata_album_album_name": "HIT ME HARD AND SOFT"}]

db.spotify.insertMany( array_items )

//Update

var filtro= { "platform": "Android"}
var actualizacion= { $set:{"platform":"android"}}
db.spotify.updateMany(filtro,actualizacion)

db.spotify.find()

//Proyeccion

var filtro= { "master_metadata_album_artist_name": "Lana Del Rey"}
var proyeccion = {"_id":0, "master_metadata_album_album_name": 1 }
db.spotify.find(filtro, proyeccion)

//Group

var query1 = { "master_metadata_album_artist_name": "Lana Del Rey"}
var fase1 = { $match: query1 }
var query2 = { "_id": "$master_metadata_album_album_name" }
var fase2 = { $group: query2 }
var etapas = [fase1,fase2]
db.spotify.aggregate(etapas)

//Sort & Limit

var query1 = { _id: "$master_metadata_album_artist_name", "ms_played": { $sum: "$ms_played" } }
var fase1 = { $group: query1 }
var query2 = { "ms_played": -1 }
var fase2 = { $sort: query2 }
var fase3 = { $limit: 5 }
var etapas = [ fase1, fase2, fase3 ]
db.spotify.aggregate(etapas)

//Match & Project

var query0 = { "master_metadata_album_artist_name":"Ariana Grande"}
var fase0 = { $match: query0 }
var query1 = { _id: "$master_metadata_track_name", "ms_played": { $sum: "$ms_played" } }
var fase1 = { $group: query1 }
var query2 = { "ms_played": -1 }
var fase2 = { $sort: query2 }
var fase3 = { $limit: 5 }
var query4 = { "ms_played": false} 
var fase4 = { $project: query4 }
var etapas = [ fase0, fase1, fase2, fase3, fase4 ]
db.spotify.aggregate(etapas)

//Dates 

fase1={ $addFields: { ts_date: { $toDate: "$ts" } } }
fase2={ $group: { _id: { $month: "$ts_date" }, "ms_played": { $sum: "$ms_played" } } }
fase3={ $addFields: { "ms_played_in_days": { $divide: ["$ms_played", 86400000] } } } 
fase4={ $sort: {"ms_played_in_days": -1}}
pipeline=[ fase1, fase2, fase3,fase4 ]
db.spotify.aggregate( pipeline )

db.spotify.find()

//Concatenar

var concatenar = { $concat: [ "$master_metadata_track_name"," by ","$master_metadata_album_artist_name"] }
var song = { $toUpper: concatenar }
var query1 = { _id: song, "ms_played": { $sum: "$ms_played" } }
var fase1 = { $group: query1 }
var query2 = { "ms_played": -1 }
var fase2 = { $sort: query2 }
var fase3 = { $limit: 10 }
var fase4 = { $project: { "ms_played":0 } }
etapas = [ fase1,fase2,fase3,fase4 ]
db.spotify.aggregate( etapas )