t_cov:
	./meta_cov_cmp -m test/cov_cmp.pk -f test/cov_cmp_flat.pk; evince meta_cov_cmp.pdf

t_pb:
	./meta_pb_cmp -a test/pb_plot_aln.pk -s test/pb_plot_sim.pk

tc:
	./feat_corr -f test/ref.fas -i test/cov_cmp_flat.pk -o test/feat_corr.pk
