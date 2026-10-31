using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Data access layer for the table [TBL_SONG].
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// CREATE - Inserts a new song. [ID_SONG] is an identity column, so it is not sent.
        /// </summary>
        /// <returns>Number of affected rows.</returns>
        public int Save(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG] ([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                                      "VALUES (@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// READ - Returns every song of the table.
        /// </summary>
        public List<Entities.Song> Read()
        {
            List<Entities.Song> lstSongs = new List<Entities.Song>();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] " +
                                                       "FROM [TBL_SONG] ORDER BY [ID_SONG]", con))
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lstSongs.Add(MapSong(reader));
                        }
                    }
                }
            }
            return lstSongs;
        }

        /// <summary>
        /// READ - Returns a single song by its id, or null when it does not exist.
        /// </summary>
        public Entities.Song ReadById(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] " +
                                                       "FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return MapSong(reader);
                        }
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// UPDATE - Updates name, path and plays of an existing song.
        /// </summary>
        public int Update(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                                      "[SONG_NAME] = @SONG_NAME " +
                                      ", [SONG_PATH] = @SONG_PATH " +
                                      ", [PLAYS] = @PLAYS " +
                                      "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.Name);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.Path);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// DELETE - Removes a song by its id.
        /// </summary>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "DELETE [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Adds one reproduction to the song and returns the new [PLAYS] value.
        /// </summary>
        public int IncrementPlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 " +
                                      "OUTPUT INSERTED.[PLAYS] " +
                                      "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    object returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }

        private Entities.Song MapSong(SqlDataReader reader)
        {
            Entities.Song song = new Entities.Song();
            song.ID = Convert.ToInt32(reader["ID_SONG"]);
            song.Name = Convert.ToString(reader["SONG_NAME"]);
            song.Path = Convert.ToString(reader["SONG_PATH"]);
            song.Plays = reader.IsDBNull(reader.GetOrdinal("PLAYS")) ? 0 : Convert.ToInt32(reader["PLAYS"]);
            return song;
        }
    }

}
