using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.PoliMusicV3
{
    /// <summary>
    /// Reglas de negocio de la tabla [TBL_SONG].
    /// Actua como intermediario entre la capa web y la capa de acceso a datos (DAL).
    /// </summary>
    public class Song
    {
        private string strConnectionString;
        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Read();
        }

        public DataTable ReadById(int id)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).ReadById(id);
        }

        public int Update(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Update(song);
        }

        public int Delete(int id)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Delete(id);
        }

        public int IncrementPlays(int id)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).IncrementPlays(id);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).CheckExistSong(songName);
        }

        /// <summary>
        /// Validaciones de negocio antes de guardar una cancion nueva.
        /// Devuelve string.Empty cuando la cancion es valida.
        /// </summary>
        public string ValidationsDuplicated(EntityLayer.PoliMusicV3.Song song)
        {
            if (song == null)
            {
                return "Song is empty!";
            }
            if (string.IsNullOrWhiteSpace(song.Name))
            {
                return "Song name is required!";
            }
            if (string.IsNullOrWhiteSpace(song.Path))
            {
                return "Song path is required!";
            }
            int returnValue = CheckExistSong(song.Name);
            if (returnValue != 0)
            {
                return "Song name already registered!";
            }
            return string.Empty;
        }
    }

}
