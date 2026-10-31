using System;
using System.Collections.Generic;
using System.Web;

namespace WebAppPoliMusicV2.Entities
{
    /// <summary>
    /// Entity that matches the table [TBL_SONG] of the database BDD_PoliMusic.
    /// Columns: ID_SONG (identity), SONG_NAME, SONG_PATH, PLAYS.
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

        /// <summary>Column [ID_SONG] - identity primary key.</summary>
        public int ID { get; set; }

        /// <summary>Column [SONG_NAME] - display name of the song.</summary>
        public string Name { get; set; }

        /// <summary>Column [SONG_PATH] - virtual path of the mp3 file (e.g. ~/songFiles/song.mp3).</summary>
        public string Path { get; set; }

        /// <summary>Column [PLAYS] - number of times the song has been played.</summary>
        public int Plays { get; set; }
    }

}
