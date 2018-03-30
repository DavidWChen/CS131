

run: 
	python3 server.py Goloman &
	python3 server.py Hands &
	python3 server.py Holiday &
	python3 server.py Wilkes &
	python3 server.py Welsh

goloman:
	python3 server.py Goloman

hands:
	python3 server.py Hands

holiday:
	python3 server.py Holiday

wilkes:
	python3 server.py Wilkes

welsh:
	python3 server.py Welsh

clean:
	rm -rf *.log

dist: clean tarball

tarball: 
	tar -cvzf project.tgz server.py client.py Makefile
