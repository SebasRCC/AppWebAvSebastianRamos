using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV3
{
    /// <summary>
    /// Pantalla "Song list": muestra el catalogo de [TBL_SONG] y permite
    /// reproducir cada cancion desde el navegador.
    /// El acceso a datos se hace siempre a traves de la capa BLL.
    /// </summary>
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                LoadAgent();
                LoadSongs();
            }
        }

        /// <summary>
        /// Nombre del usuario autenticado que se muestra en la cabecera.
        /// </summary>
        private void LoadAgent()
        {
            EntityLayer.PoliMusicV3.User user =
                Session[EntityLayer.PoliMusicV3.Util.Constants.USER] as EntityLayer.PoliMusicV3.User;

            if (user != null && !string.IsNullOrEmpty(user.UserName))
            {
                lblUserName.Text = user.UserName;
            }
            else
            {
                lblUserName.Text = Page.User.Identity.Name;
            }
        }

        /// <summary>
        /// Lee las canciones desde la capa de negocio y las enlaza al Repeater.
        /// </summary>
        private void LoadSongs()
        {
            DataTable dtSong = new BLL.PoliMusicV3.Song(strConnString).Read();

            rptSongs.DataSource = dtSong;
            rptSongs.DataBind();

            lblSongCount.Text = dtSong.Rows.Count.ToString();
            pnlEmpty.Visible = (dtSong.Rows.Count == 0);
        }

        /// <summary>
        /// Codifica un valor para mostrarlo de forma segura dentro del HTML.
        /// </summary>
        protected string H(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return string.Empty;
            }
            return HttpUtility.HtmlEncode(value.ToString());
        }

        /// <summary>
        /// Resuelve la ruta almacenada en [SONG_PATH] (por ejemplo "~/songFiles/x.mp3")
        /// a una URL utilizable por el reproductor HTML5.
        /// </summary>
        protected string SongUrl(object path)
        {
            if (path == null || path == DBNull.Value)
            {
                return string.Empty;
            }
            string strPath = path.ToString();
            if (string.IsNullOrWhiteSpace(strPath))
            {
                return string.Empty;
            }
            return ResolveUrl(strPath);
        }

        /// <summary>
        /// Invocado por el reproductor (AJAX) al iniciar la reproduccion de una cancion.
        /// Incrementa [PLAYS] y devuelve el nuevo contador.
        /// </summary>
        [WebMethod]
        public static int RegisterPlay(int idSong)
        {
            if (idSong <= 0)
            {
                return 0;
            }
            string conn = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
            return new BLL.PoliMusicV3.Song(conn).IncrementPlays(idSong);
        }
    }
}
