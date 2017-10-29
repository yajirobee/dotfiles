CC = gcc
CFLAGS =
LDFLAGS = -lm -lsqlite3
TARGET = libsqlitefunctions.so
SOURCES = sqlite-extension-functions.c

all: $(TARGET)

$(TARGET):
	$(CC) -fPIC -shared -o $@ $(SOURCES) $(LDFLAGS)

clean:
	/bin/rm -f $(TARGET)

.c.o:
	$(CC) $(CFLAGS) -c $<

.PHONY: check-syntax

check-syntax:
	$(CC) -Wall -fsyntax-only $(CHK_SOURCES)
