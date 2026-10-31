using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Business layer for the songs: it validates the data and delegates to the DAL.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            string strError = Validate(song);
            if (strError != string.Empty)
            {
                throw new ArgumentException(strError);
            }
            return new DAL.Song(strConnectionString).Save(song);
        }

        public List<Entities.Song> Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public Entities.Song ReadById(int idSong)
        {
            if (idSong <= 0)
            {
                return null;
            }
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        public int Update(Entities.Song song)
        {
            if (song.ID <= 0)
            {
                throw new ArgumentException("The song id is required to update a song.");
            }
            string strError = Validate(song);
            if (strError != string.Empty)
            {
                throw new ArgumentException(strError);
            }
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            if (idSong <= 0)
            {
                throw new ArgumentException("The song id is required to delete a song.");
            }
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int IncrementPlays(int idSong)
        {
            if (idSong <= 0)
            {
                return 0;
            }
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }

        /// <summary>
        /// Returns an empty string when the song is valid, otherwise the error message.
        /// </summary>
        public string Validate(Entities.Song song)
        {
            if (song == null)
            {
                return "The song is required.";
            }
            if (string.IsNullOrEmpty(song.Name) || song.Name.Trim().Length == 0)
            {
                return "The song name is required.";
            }
            if (song.Name.Trim().Length > 50)
            {
                return "The song name cannot be longer than 50 characters.";
            }
            if (string.IsNullOrEmpty(song.Path) || song.Path.Trim().Length == 0)
            {
                return "The song path is required.";
            }
            if (song.Path.Trim().Length > 255)
            {
                return "The song path cannot be longer than 255 characters.";
            }
            if (song.Plays < 0)
            {
                return "The number of plays cannot be negative.";
            }
            return string.Empty;
        }
    }

}
