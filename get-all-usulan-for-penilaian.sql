select 
	pr.id_plotting_reviewer, 
	uk.id_usulan_kegiatan, tks.kd_tahapan_kegiatan, u.judul, skim.nama_singkat_skim, b.bidang,
	pa.nama as nama_ketua, mhs.nomor_mahasiswa as nim_ketua, jumlah_anggota,
	pendamping.nama_dosen, i.nama_institusi as pt, pendamping.prodi_dosen, 
	skor_akhir, hr.komentar, hr.tempat, p.nama as nama_reviewer
from hibah.plotting_reviewer pr
join hibah.reviewer r	on r.id_reviewer = pr.id_reviewer
join pdpt.personal p	on p.id_personal = r.id_personal
-- hasil reviewer
left join hibah.hasil_review hr		on hr.id_plotting_reviewer = pr.id_plotting_reviewer
-- nilai penilaian
left join (
	select pr.id_plotting_reviewer, sum(bobot * coalesce(hp.nilai,0)) as skor_akhir 
	from hibah.plotting_reviewer pr
	join hibah.transaksi_kegiatan tk on tk.id_transaksi_kegiatan = pr.id_transaksi_kegiatan
	join hibah.tahapan_kegiatan_skim tks on tks.id_tahapan_kegiatan_skim = tk.id_tahapan_kegiatan_skim
	join hibah.usulan_kegiatan uk on uk.id_usulan_kegiatan = tk.id_usulan_kegiatan
	join hibah.usulan_pimnas up on up.id_usulan_kegiatan = uk.id_usulan_kegiatan
	join hibah.komponen_penilaian kp on kp.id_tahapan_kegiatan_skim = tks.id_tahapan_kegiatan_skim and kp.edisi = uk.thn_pelaksanaan_kegiatan
	left join hibah.hasil_penilaian hp on hp.id_plotting_reviewer = pr.id_plotting_reviewer and hp.id_komponen_penilaian = kp.id_komponen_penilaian
	where uk.thn_pelaksanaan_kegiatan = $1
	group by pr.id_plotting_reviewer
) skor_akhir on skor_akhir.id_plotting_reviewer = pr.id_plotting_reviewer
-- proposal
join hibah.transaksi_kegiatan tk	on tk.id_transaksi_kegiatan = pr.id_transaksi_kegiatan
join hibah.usulan_kegiatan uk		on uk.id_usulan_kegiatan = tk.id_usulan_kegiatan
join hibah.usulan_pimnas up			on up.id_usulan_kegiatan = uk.id_usulan_kegiatan
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
left join (
	select uk.id_usulan_kegiatan, count(a.*) as jumlah_anggota
	from hibah.usulan_kegiatan uk
	join hibah.usulan_pimnas up		on up.id_usulan_kegiatan = uk.id_usulan_kegiatan
	join hibah.personil a			on a.id_usulan_kegiatan = uk.id_usulan_kegiatan
	join hibah.peran_personil pp	on pp.kd_peran_personil = a.kd_peran_personil and pp.peran_personil not in ('Ketua Kelompok', 'Dosen Pendamping')
	where uk.thn_pelaksanaan_kegiatan = $1
	group by uk.id_usulan_kegiatan
) jumlah_anggota on jumlah_anggota.id_usulan_kegiatan = uk.id_usulan_kegiatan
-- dosen pendamping
left join (
	select uk.id_usulan_kegiatan, person_pendamping.nama as nama_dosen, psd.nama_program_studi as prodi_dosen
	from hibah.usulan_kegiatan uk
	join hibah.usulan_pimnas up					on up.id_usulan_kegiatan = uk.id_usulan_kegiatan
	join hibah.personil pendamping				on pendamping.id_usulan_kegiatan = uk.id_usulan_kegiatan
	join hibah.peran_personil peran_pendamping	on peran_pendamping.kd_peran_personil = pendamping.kd_peran_personil and peran_pendamping.peran_personil = 'Dosen Pendamping'
	join pdpt.personal person_pendamping		on person_pendamping.id_personal = pendamping.id_personal
	join pdpt.dosen d							on d.id_personal = person_pendamping.id_personal
	join pdpt.program_studi psd					on psd.id_program_studi = d.id_program_studi
	where uk.thn_pelaksanaan_kegiatan = $1
) pendamping on pendamping.id_usulan_kegiatan = uk.id_usulan_kegiatan
where 
	uk.thn_pelaksanaan_kegiatan = $1 and tks.kd_tahapan_kegiatan = $2