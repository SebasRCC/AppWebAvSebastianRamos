using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Reglas de negocio de las canciones. Es la unica capa que las paginas .aspx
    /// deberian invocar; por dentro delega en DAL.Song.
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
            return new DAL.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public DataTable ReadById(int idSong)
        {
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName);
        }

        /// <summary>
        /// Valida los campos obligatorios de la entidad antes de guardar.
        /// Devuelve string.Empty cuando la entidad es valida.
        /// </summary>
        public string ValidateFieldsRequired(Entities.Song song)
        {
            if (song.Name == null || song.Name.Trim() == string.Empty)
            {
                return "Song name is required!";
            }
            if (song.Name.Trim().Length > 50)
            {
                return "Song name can not exceed 50 characters!";
            }
            if (song.Path == null || song.Path.Trim() == string.Empty)
            {
                return "Song path is required!";
            }
            if (song.Path.Trim().Length > 255)
            {
                return "Song path can not exceed 255 characters!";
            }
            if (song.Plays < 0)
            {
                return "Plays can not be a negative number!";
            }
            return string.Empty;
        }

        /// <summary>
        /// Valida duplicados por nombre (solo al crear).
        /// </summary>
        public string ValidateDuplicated(Entities.Song song)
        {
            if (CheckExistSong(song.Name) != 0)
            {
                return "Song name already registered!";
            }
            return string.Empty;
        }
    }

}
