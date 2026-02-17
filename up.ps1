Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$file = Get-Item "C:\path\to\image.jpg"
$img = [System.Drawing.Image]::FromFile($file)

$pictureBox = New-Object Windows.Forms.PictureBox
$pictureBox.Width = $img.Size.Width
$pictureBox.Height = $img.Size.Height
$pictureBox.Image = $img

$form = New-Object Windows.Forms.Form
$form.Text = "Image Viewer"
$form.Width = $img.Size.Width
$form.Height = $img.Size.Height
$form.Controls.Add($pictureBox)
$form.ShowDialog()
