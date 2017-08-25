select 
	pr.id_plotting_reviewer,
	kp.id_komponen_penilaian, kp.no_urut, kp.kriteria_penilaian,
	kp.bobot, hp.id_hasil_penilaian, coalesce(hp.nilai,0) as nilai, bobot * coalesce(hp.nilai,0) as nilai_komponen 
from hibah.plotting_reviewer pr
join hibah.transaksi_kegiatan tk on tk.id_transaksi_kegiatan = pr.id_transaksi_kegiatan
join hibah.tahapan_kegiatan_skim tks on tks.id_tahapan_kegiatan_skim = tk.id_tahapan_kegiatan_skim
join hibah.usulan_kegiatan uk on uk.id_usulan_kegiatan = tk.id_usulan_kegiatan
join hibah.usulan_pimnas up on up.id_usulan_kegiatan = uk.id_usulan_kegiatan
join hibah.komponen_penilaian kp on kp.id_tahapan_kegiatan_skim = tks.id_tahapan_kegiatan_skim and kp.edisi = uk.thn_pelaksanaan_kegiatan
left join hibah.hasil_penilaian hp on hp.id_plotting_reviewer = pr.id_plotting_reviewer and hp.id_komponen_penilaian = kp.id_komponen_penilaian
where uk.thn_pelaksanaan_kegiatan = $1 and tks.kd_tahapan_kegiatan = $2
group by pr.id_plotting_reviewer, kp.id_komponen_penilaian, kp.no_urut, kp.kriteria_penilaian, kp.bobot, hp.id_hasil_penilaian
order by pr.id_plotting_reviewer, kp.no_urut