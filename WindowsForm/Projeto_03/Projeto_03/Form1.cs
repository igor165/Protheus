namespace Projeto_03
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            string cUserName = textBox1.Text.Trim().ToLower();
            string cPassWord = textBox2.Text;

            if (cUserName == ""){
                MessageBox.Show("Usuário inválido");
            }
            else if (cPassWord == "") {
                MessageBox.Show("Senha inválida");
            }
            else {
                MessageBox.Show("Passou!");
            }

        }
    }
}
