<?php
include 'db.php';

$connection = pg_connect($connection_string);

$id_plotting_reviewer = isset($_GET['id']) ? $_GET['id'] : '';

$sql1 = file_get_contents('get-usulan-for-penilaian.sql');
$result = pg_query_params($connection, $sql1, array($id_plotting_reviewer));
$usulan = pg_fetch_all($result);

$sql2 = file_get_contents('get-anggota-for-penilaian.sql');
$result = pg_query_params($connection, $sql2, array($id_plotting_reviewer));
$anggota_set = pg_fetch_all($result);

$sql3 = file_get_contents('get-hasil-penilaian.sql');
$result = pg_query_params($connection, $sql3, array($id_plotting_reviewer));
$penilaian_set = pg_fetch_all($result);


// konstanta tahapan
if ($usulan[0]['kd_tahapan_kegiatan'] == 43) { $tahapan = 'Laporan Akhir'; }
if ($usulan[0]['kd_tahapan_kegiatan'] == 45) { $tahapan = 'Poster'; }
if ($usulan[0]['kd_tahapan_kegiatan'] == 46) { $tahapan = 'Presentasi'; }
if ($usulan[0]['kd_tahapan_kegiatan'] == 48) { $tahapan = 'Artikel'; }

// Data Usulan
$skim		= $usulan[0]['nama_singkat_skim'];
$judul		= $usulan[0]['judul'];
$bidang		= $usulan[0]['bidang'];
$ketua		= $usulan[0]['nama_ketua'];
$nim_ketua	= $usulan[0]['nim_ketua'];
$jml_anggota= $usulan[0]['jumlah_anggota'];
$dosen		= $usulan[0]['nama_dosen'];
$pt			= $usulan[0]['pt'];
$prodi_dosen= $usulan[0]['prodi_dosen'];
$skor_akhir	= $usulan[0]['skor_akhir'];
$komentar	= $usulan[0]['komentar'];
$lokasi		= $usulan[0]['tempat'];
$reviewer	= $usulan[0]['nama_reviewer'];

/*
echo '<pre>'.print_r($usulan[0],true).'</pre><br/>';
echo '<pre>'.print_r($anggota_set,true).'</pre><br/>';
echo '<pre>'.print_r($penilaian_set,true).'</pre><br/>';
exit();
*/

// TCPDF
include 'vendor/tecnickcom/tcpdf/tcpdf.php';

class CustomTCPDF extends TCPDF
{
	// Page footer
	public function Footer()
	{
		$tanggal_cetak = "Generated at " . strftime('%d-%b-%Y %H:%M:%S');
		
		// Position at 15 mm from bottom
		$this->SetY(-15);
		// Set font
		$this->SetFont('freeserif', 'I', 8);
		// Page number
		$this->Cell(0, 10, $tanggal_cetak, 0, false, 'C', 0, '', 0, false, 'T', 'M');
	}
}

// create new PDF document
$pdf = new CustomTCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, 'UTF-8', false);

// set document information
$pdf->SetCreator('Simbelmawa');
$pdf->SetAuthor('Ristekdikti');
$pdf->SetKeywords('simbelmawa, ristekdikti, pimnas, form penilaian');

$title = 'Form Penilaian Laporan Akhir PKM-P';

$pdf->SetTitle($title);
$pdf->SetSubject($title);

// disable header
$pdf->setPrintHeader(false);

// set footer fonts
$pdf->setFooterFont(Array(PDF_FONT_NAME_DATA, '', PDF_FONT_SIZE_DATA));

// set margins
$pdf->SetMargins(PDF_MARGIN_LEFT, 15, PDF_MARGIN_RIGHT);
$pdf->SetFooterMargin(PDF_MARGIN_FOOTER);

// set auto page breaks
$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

// ---------------------------------------------------------

// set default font subsetting mode
$pdf->setFontSubsetting(true);

// Set font
$pdf->SetFont('times', '', 12, '', true);

// Add a page
$pdf->AddPage();

$judul_form = '<h3>Formulir Penilaian '.$tahapan.' '.$skim.'</h3>';
$pdf->writeHTMLCell(0, 0, '', '', $judul_form, 0, 1, false, true, 'C');

$pdf->Ln();

$judul = TCPDF_STATIC::_escapeXML($judul);

$html_anggota = "";

foreach ($anggota_set as $anggota)
{
	$html_anggota .= 
		"<tr>
			<td>{$anggota['peran_personil']}</td>
			<td>:</td>
			<td>{$anggota['nama']} ({$anggota['nim']})</td>
		</tr>";
}

$html_header = <<<EOD
	<style>
		table.debug > tr > td { border: 0.1px dashed red; }
	</style>
	<table cellspacing="1" cellpadding="0" class="">
		<tr>
			<td width="100">Judul</td>
			<td width="10">:</td>
			<td width="390">{$judul}</td>
		</tr>
		<tr>
			<td>Bidang Kegiatan</td>
			<td>:</td>
			<td>{$skim}</td>
		</tr>
		<tr>
			<td>Bidang Ilmu</td>
			<td>:</td>
			<td>{$bidang}</td>
		</tr>
		<tr>
			<td>Penulis Utama</td>
			<td>:</td>
			<td>{$ketua}</td>
		</tr>
		<tr>
			<td>NIM</td>
			<td>:</td>
			<td>{$nim_ketua}</td>
		</tr>
		<tr>
			<td>Jumlah Anggota</td>
			<td>:</td>
			<td>{$jml_anggota} orang</td>
		</tr>
		{$html_anggota}
		<tr>
			<td>Dosen Pendamping</td>
			<td>:</td>
			<td>{$dosen}</td>
		</tr>
		<tr>
			<td>Perguruan Tinggi</td>
			<td>:</td>
			<td>{$pt}</td>
		</tr>
		<tr>
			<td>Program Studi</td>
			<td>:</td>
			<td>{$prodi_dosen}</td>
		</tr>
	</table>
EOD;
			
$pdf->writeHTMLCell(0, 0, '', '', $html_header, 0, 1, false, true);
$pdf->Ln(5);

$data_set = [
	['no_urut' => '1', 'kriteria' => 'Judul <i>Kesesuaian isi dan judul artikel</i>', 'bobot' => 15, 'nilai' => 3, 'nilai_komponen' => 45],
	['no_urut' => '2', 'kriteria' => 'Abstrak <i>Latar belakang, Tujuan, Metode, Hasil, Kesimpulan, Kata kunci</i>', 'bobot' => 15, 'nilai' => 3, 'nilai_komponen' => 45],
	['no_urut' => '3', 'kriteria' => 'Pendahuluan <i>Persoalan yang mendasari pelaksanaan Uraian dasar2 keilmuan yang mendukung Kemutakhiran substansi pekerjaan</i>', 'bobot' => 15, 'nilai' => 3, 'nilai_komponen' => 45],
	['no_urut' => '4', 'kriteria' => 'Bahan/Subyek dan Metode <i>Kesesuaian dengan persoalan yang akan diselesaikan, Pengembangan metode baru, Penggunaan metode yang sudah ada</i>', 'bobot' => 15, 'nilai' => 3, 'nilai_komponen' => 45],
	['no_urut' => '5', 'kriteria' => 'Hasil dan Pembahasan <i>Kumpulan dan kejelasan penampilan data Proses/teknik pengolahan data, Ketajaman analisis dan sintesis data,Perbandingan hasil dengan hipotesis atau hasil sejenis sebelumnya</i>', 'bobot' => 15, 'nilai' => 3, 'nilai_komponen' => 45],
	['no_urut' => '6', 'kriteria' => 'Kesimpulan <i>Tingkat ketercapaian hasil dengan tujuan</i>', 'bobot' => 15, 'nilai' => 3, 'nilai_komponen' => 45],
	['no_urut' => '7', 'kriteria' => 'Daftar Pustaka <i>Ditulis sesuai dengan peraturan model HarvardSesuai dengan uraian sitasi, Kemutakhiran pustaka</i>', 'bobot' => 15, 'nilai' => 3, 'nilai_komponen' => 45],
];

$html_detail_penilaian = "";

foreach ($penilaian_set as $data)
{
	$html_detail_penilaian .= 
		"<tr>"
		. "<td align=\"center\">{$data['no_urut']}</td>"
		. "<td>{$data['kriteria_penilaian']}</td>"
		. "<td align=\"center\">{$data['bobot']}</td>"
		. "<td align=\"center\">{$data['nilai']}</td>"
		. "<td align=\"center\">{$data['nilai_komponen']}</td>"
		. "</tr>";
}

$html_penilaian = <<<EOD
	<table border="0.5" cellpadding="2">
		<tr>
			<th width="25" align="center">No</th>
			<th width="325">Kriteria</th>
			<th width="55" align="center">Bobot (%)</th>
			<th width="45" align="center">Skor</th>
			<th width="50" align="center">Nilai</th>
		</tr>
		{$html_detail_penilaian}
		<tr>
			<td></td>
			<td align="center">Jumlah</td>
			<td align="center">100</td>
			<td></td>
			<td align="center">{$skor_akhir}</td>
		</tr>
	</table>
EOD;

// reduce font
$pdf->SetFont('times', 0, 11);
			
$pdf->writeHTMLCell(0, 0, '', '', $html_penilaian, 0, 1);

// reduce font
$pdf->SetFont('times', 0, 10);
$pdf->writeHTMLCell(0, 0, '', '', "Skor : 1, 2, 3, 5, 6, 7 (1 = Buruk; 2 = Sangat kurang; 3 = Kurang; 5 = Cukup; 6 = Baik; 7 = Sangat baik);  Nilai = Bobot x Skor", 0, 1);

// Komentar
$pdf->SetFont('times', 0, 11);
$komentar = TCPDF_STATIC::_escapeXML($komentar);
$pdf->writeHTMLCell(0, 0, '', '', "Komentar penilai : {$komentar}", 0, 1);
$pdf->Ln();

setlocale(LC_TIME, 'id');
$lokasi = ucfirst($lokasi);
$tanggal = strftime('%d %B %Y');

// Tanda tangan
$html_ttd = 
	"<table>
		<tr>
			<td width=\"300\"></td>
			<td width=\"200\" align=\"center\">
				Makassar, {$tanggal}<br/>Penilai<br/><br/><br/><br/>({$reviewer})
			</td>
		</tr>
	</table>";

$pdf->SetFont('times', 0, 12);
$pdf->writeHTMLCell(0, 0, '', '', $html_ttd, 0, 1);

// ---------------------------------------------------------

// Close and output PDF document
// This method has several options, check the source code documentation for more information.
$pdf->Output("Form Penilaian {$tahapan} {$skim} {$usulan[0]['nama_ketua']}.pdf", 'I');