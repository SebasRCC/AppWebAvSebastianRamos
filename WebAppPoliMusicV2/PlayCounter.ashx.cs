using System;
using System.Configuration;
using System.Web;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Increments the [PLAYS] counter of a song without reloading the page
    /// (the audio player must keep playing, so a postback is not an option).
    /// Returns: {"id": 3, "plays": 7}
    /// </summary>
    public class PlayCounter : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();

            int idSong = 0;
            int plays = 0;

            if (int.TryParse(context.Request.QueryString["id"], out idSong) && idSong > 0)
            {
                try
                {
                    string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
                    plays = new BLL.Song(strConnString).IncrementPlays(idSong);
                }
                catch (Exception)
                {
                    plays = 0;
                }
            }

            context.Response.Write("{\"id\":" + idSong + ",\"plays\":" + plays + "}");
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}
