function sum() {
	perl -lne '$sum += $1 if /(\d+)/; END{print $sum}'
}
