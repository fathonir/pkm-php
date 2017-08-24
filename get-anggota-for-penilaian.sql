select peran.peran_personil, nama, nomor_mahasiswa as nim 
from hibah.personil
join pdpt.personal on personal.id_personal = personil.id_personal
join pdpt.mahasiswa mhs on mhs.id_personal = personal.id_personal
join hibah.peran_personil peran on peran.kd_peran_personil = personil.kd_peran_personil and peran.peran_personil not in ('Ketua Kelompok', 'Dosen Pendamping')
join hibah.usulan_kegiatan uk on uk.id_usulan_kegiatan = personil.id_usulan_kegiatan
join hibah.transaksi_kegiatan tk on tk.id_usulan_kegiatan = uk.id_usulan_kegiatan
join hibah.plotting_reviewer pr on pr.id_transaksi_kegiatan = tk.id_transaksi_kegiatan
where pr.id_plotting_reviewer = $1
order by peran.peran_personil