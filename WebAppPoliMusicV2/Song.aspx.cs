using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    /// <summary>
    /// Pantalla "Song list": muestra el catalogo de TBL_SONG y permite
    /// reproducir cada pista desde el navegador.
    /// La pagina solo habla con la capa BLL; BLL delega en DAL.
    /// </summary>
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsAuthenticatedUser())
            {
                RedirectToLogin();
                return;
            }

            // Llamada asincrona del reproductor para sumar una reproduccion.
            if (!string.IsNullOrEmpty(Request.QueryString["play"]))
            {
                WritePlayCounter();
                return;
            }

            if (!Page.IsPostBack)
            {
                ShowCurrentUser();
                BindSongs();
            }
        }

        #region Seguridad / sesion

        private bool IsAuthenticatedUser()
        {
            if (Session[Util.Constants.USER] != null)
            {
                return true;
            }
            return User != null && User.Identity != null && User.Identity.IsAuthenticated;
        }

        private void RedirectToLogin()
        {
            string returnUrl = Request.RawUrl;
            Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(returnUrl), true);
        }

        /// <summary>
        /// Recupera el usuario autenticado desde la Session. Si la Session se
        /// perdio pero la cookie de Forms sigue viva, se reconstruye desde TBL_USER.
        /// </summary>
        private Entities.User GetCurrentUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            if (user != null)
            {
                return user;
            }
            if (User == null || User.Identity == null || !User.Identity.IsAuthenticated)
            {
                return null;
            }

            string userName = User.Identity.Name;
            user = new Entities.User();
            user.UserName = userName;
            user.Photo = "~/UserImages/default.jpg";

            DataTable dtUser = new BLL.User(strConnString).Read();
            if (dtUser != null && dtUser.Rows.Count > 0)
            {
                DataRow[] rows = dtUser.Select("USERNAME = '" + userName.Replace("'", "''") + "'");
                if (rows.Length > 0)
                {
                    user.ID = Convert.ToInt32(rows[0]["ID_USER"]);
                    user.UserName = rows[0]["USERNAME"].ToString();
                    user.Email = rows[0]["EMAIL"].ToString();
                    user.UserType = Convert.ToInt32(rows[0]["USER_TYPE"]);
                    if (rows[0]["USER_PHOTO"] != DBNull.Value && rows[0]["USER_PHOTO"].ToString() != string.Empty)
                    {
                        user.Photo = rows[0]["USER_PHOTO"].ToString();
                    }
                    Session[Util.Constants.USER] = user;
                }
            }
            return user;
        }

        private void ShowCurrentUser()
        {
            Entities.User user = GetCurrentUser();
            if (user == null)
            {
                RedirectToLogin();
                return;
            }

            lblUserName.Text = H(user.UserName);

            string photo = user.Photo;
            if (string.IsNullOrEmpty(photo))
            {
                photo = "~/UserImages/default.jpg";
            }
            imgUserPhoto.ImageUrl = ResolveUrl(photo);
            imgUserPhoto.AlternateText = "Foto de " + user.UserName;
        }

        #endregion

        #region Canciones

        private void BindSongs()
        {
            DataTable dtSongs = new BLL.Song(strConnString).Read();

            rptSongs.DataSource = dtSongs;
            rptSongs.DataBind();

            int total = (dtSongs == null) ? 0 : dtSongs.Rows.Count;
            pnlList.Visible = total > 0;
            pnlEmpty.Visible = total == 0;
            lblSongCount.Text = total + ((total == 1) ? " pista" : " pistas");
        }

        /// <summary>
        /// Suma una reproduccion en TBL_SONG y responde en JSON al reproductor.
        /// La llama el fetch() del navegador: Song.aspx?play=ID
        /// </summary>
        private void WritePlayCounter()
        {
            int idSong;
            if (!int.TryParse(Request.QueryString["play"], out idSong) || idSong <= 0)
            {
                Response.StatusCode = 400;
                Response.End();
                return;
            }

            int plays = new BLL.Song(strConnString).IncrementPlays(idSong);

            Response.Clear();
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Write("{\"id\":" + idSong + ",\"plays\":" + plays + "}");
            Response.End();
        }

        /// <summary>
        /// Codifica el texto antes de escribirlo en el HTML.
        /// </summary>
        protected string H(object value)
        {
            return HttpUtility.HtmlEncode(value == null ? string.Empty : value.ToString());
        }

        #endregion
    }
}
