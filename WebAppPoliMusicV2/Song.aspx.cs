using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        private string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                if (!LoadAuthenticatedUser())
                {
                    return;
                }
                LoadSongs();
            }
        }

        /// <summary>
        /// Shows the name and the photo of the authenticated user in the top bar.
        /// Returns false when there is no session and the request has been redirected to the login page.
        /// </summary>
        private bool LoadAuthenticatedUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;

            if (user == null && Page.User != null && Page.User.Identity.IsAuthenticated)
            {
                user = new Entities.User();
                user.UserName = Page.User.Identity.Name;
                user.Photo = string.Empty;
            }

            if (user == null || string.IsNullOrEmpty(user.UserName))
            {
                Session.Clear();
                Response.Redirect("Login.aspx", true);
                return false;
            }

            lblUserName.Text = Server.HtmlEncode(user.UserName);
            lblUserInitials.Text = Server.HtmlEncode(GetInitials(user.UserName));

            if (!string.IsNullOrEmpty(user.Photo))
            {
                imgUserPhoto.ImageUrl = ResolveUrl(user.Photo);
            }
            else
            {
                imgUserPhoto.ImageUrl = ResolveUrl("~/UserImages/default.jpg");
            }
            imgUserPhoto.AlternateText = user.UserName;
            imgUserPhoto.ToolTip = user.UserName;
            // If the picture does not exist, the initials behind it stay visible.
            imgUserPhoto.Attributes["onerror"] = "this.onerror=null;this.style.display='none';";

            return true;
        }

        /// <summary>
        /// Binds the song list of the table [TBL_SONG] to the repeater.
        /// </summary>
        private void LoadSongs()
        {
            try
            {
                List<Entities.Song> lstSongs = new BLL.Song(strConnString).Read();

                rptSongs.DataSource = lstSongs;
                rptSongs.DataBind();
                lblSongCount.Text = lstSongs.Count.ToString();

                if (lstSongs.Count == 0)
                {
                    lblMessage.Text = "There are no songs in the archive yet.";
                    lblMessage.Visible = true;
                }
            }
            catch (Exception ex)
            {
                lblSongCount.Text = "0";
                lblMessage.Text = "The song list could not be loaded: " + Server.HtmlEncode(ex.Message);
                lblMessage.Visible = true;
            }
        }

        /// <summary>
        /// Resolves a virtual path stored in [SONG_PATH] (~/songFiles/song.mp3) for the audio element.
        /// </summary>
        protected string ResolveSongPath(object path)
        {
            string strPath = Convert.ToString(path);
            if (string.IsNullOrEmpty(strPath))
            {
                return string.Empty;
            }
            return ResolveUrl(strPath);
        }

        /// <summary>
        /// Builds up to two initials from the user name, used as avatar fallback.
        /// </summary>
        private static string GetInitials(string userName)
        {
            if (string.IsNullOrEmpty(userName))
            {
                return "?";
            }
            string[] parts = userName.Split(new char[] { '.', ' ', '_', '-' }, StringSplitOptions.RemoveEmptyEntries);
            string initials = parts[0].Substring(0, 1);
            if (parts.Length > 1 && parts[1].Length > 0)
            {
                initials += parts[1].Substring(0, 1);
            }
            return initials.ToUpperInvariant();
        }
    }
}
