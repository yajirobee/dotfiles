CC = gcc
CFLAGS =
LDFLAGS =
TARGET =
OBJS =

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	/bin/rm -f $(OBJS)

clean:
	/bin/rm -f $(TARGET)

.c.o:
	$(CC) $(CFLAGS) -c $<
