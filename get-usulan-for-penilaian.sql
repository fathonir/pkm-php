select 
	uk.id_usulan_kegiatan, tks.kd_tahapan_kegiatan, u.judul, skim.nama_singkat_skim, b.bidang,
	pa.nama as nama_ketua, mhs.nomor_mahasiswa as nim_ketua, count(peran_anggota.*) as jumlah_anggota, 
	person_pendamping.nama as nama_dosen, i.nama_institusi as pt, psd.nama_program_studi as prodi_dosen, 
	skor_akhir, hr.komentar, hr.tempat, p.nama as nama_reviewer
from hibah.plotting_reviewer pr
join hibah.reviewer r	on r.id_reviewer = pr.id_reviewer
join pdpt.personal p	on p.id_personal = r.id_personal
-- hasil reviewer
left join hibah.hasil_review hr		on hr.id_plotting_reviewer = pr.id_plotting_reviewer
-- nilai penilaian
cross join (
	select sum(bobot * coalesce(hp.nilai,0)) as skor_akhir 
	from hibah.plotting_reviewer pr
	join hibah.transaksi_kegiatan tk on tk.id_transaksi_kegiatan = pr.id_transaksi_kegiatan
	join hibah.tahapan_kegiatan_skim tks on tks.id_tahapan_kegiatan_skim = tk.id_tahapan_kegiatan_skim
	join hibah.usulan_kegiatan uk on uk.id_usulan_kegiatan = tk.id_usulan_kegiatan
	join hibah.komponen_penilaian kp on kp.id_tahapan_kegiatan_skim = tks.id_tahapan_kegiatan_skim and kp.edisi = uk.thn_pelaksanaan_kegiatan
	left join hibah.hasil_penilaian hp on hp.id_plotting_reviewer = pr.id_plotting_reviewer and hp.id_komponen_penilaian = kp.id_komponen_penilaian
	where pr.id_plotting_reviewer = $1
) skor_akhir
-- proposal
join hibah.transaksi_kegiatan tk	on tk.id_transaksi_kegiatan = pr.id_transaksi_kegiatan
join hibah.usulan_kegiatan uk		on uk.id_usulan_kegiatan = tk.id_usulan_kegiatan
join hibah.usulan u					on u.id_usulan = uk.id_usulan
join hibah.bidang b					on b.id_bidang = u.id_bidang
-- skim proposal
join hibah.tahapan_kegiatan_skim tks	on tks.id_tahapan_kegiatan_skim = tk.id_tahapan_kegiatan_skim
join hibah.skim_kegiatan skim			on skim.id_skim = tks.id_skim
-- perguruan tinggi
join pdpt.perguruan_tinggi pt	on pt.kode_perguruan_tinggi = u.kode_perguruan_tinggi
join pdpt.institusi i			on i.id_institusi = pt.id_institusi
-- ketua
join hibah.personil a			on a.id_usulan_kegiatan = uk.id_usulan_kegiatan
join hibah.peran_personil pp	on pp.kd_peran_personil = a.kd_peran_personil and pp.peran_personil = 'Ketua Kelompok'
join pdpt.personal pa			on pa.id_personal = a.id_personal
join pdpt.mahasiswa mhs			on mhs.id_personal = pa.id_personal
-- anggota proposal
left join hibah.personil anggota				on anggota.id_usulan_kegiatan = uk.id_usulan_kegiatan
left join hibah.peran_personil peran_anggota	on peran_anggota.kd_peran_personil = anggota.kd_peran_personil and peran_anggota.peran_personil not in ('Ketua Kelompok', 'Dosen Pendamping')
-- dosen pendamping
left join hibah.personil pendamping				on pendamping.id_usulan_kegiatan = uk.id_usulan_kegiatan
left join hibah.peran_personil peran_pendamping	on peran_pendamping.kd_peran_personil = pendamping.kd_peran_personil and peran_pendamping.peran_personil = 'Dosen Pendamping'
left join pdpt.personal person_pendamping		on person_pendamping.id_personal = pendamping.id_personal
left join pdpt.dosen d							on d.id_personal = person_pendamping.id_personal
left join pdpt.program_studi psd				on psd.id_program_studi = d.id_program_studi
where 
	pr.id_plotting_reviewer = $1
group by 
	uk.id_usulan_kegiatan, tks.kd_tahapan_kegiatan, u.judul, skim.nama_singkat_skim, b.bidang,
	pa.nama, mhs.nomor_mahasiswa, 
	person_pendamping.nama, i.nama_institusi, psd.nama_program_studi, 
	skor_akhir, hr.komentar, hr.tempat, p.nama 