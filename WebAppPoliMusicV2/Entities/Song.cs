using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    /// <summary>
    /// Entidad que representa una fila de la tabla [TBL_SONG].
    /// Columnas: ID_SONG (identity), SONG_NAME, SONG_PATH, PLAYS.
    /// </summary>
    public class Song
    {
        public Song()
        {
        }
        public Song(int id, string name, string path, int plays)
        {
            ID = id;
            Name = name;
            Path = path;
            Plays = plays;
        }
        public int ID { get; set; }
        public string Name { get; set; }
        public string Path { get; set; }
        public int Plays { get; set; }
    }

}
