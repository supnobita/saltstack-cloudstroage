#upgrade.sls

update:
	pkg:
		- refresh_db
		- upgrade 