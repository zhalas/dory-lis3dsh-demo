#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>


#define EV_MSC 0x04
#define MSC_GESTURE 0x02

#define WAKE_TIME 3

#define INPUT_DEVICE "/dev/input/by-path/platform-f9924000.i2c-event"


struct input_event {
        struct timeval time;
        unsigned short type;
        unsigned short code;
        unsigned int value;
};

void err_log(char *str) {
	fprintf(stderr, "%s\n", str);
}


int poll_fd(int fd, int timeout) {
	struct timeval tv;
	fd_set set;
	FD_ZERO(&set);
	FD_SET(fd, &set);
	tv.tv_sec = timeout;
	tv.tv_usec = 0;
	return select(fd + 1, &set, NULL, NULL,  &tv);

}

void turn_display_on() {
	system("mcetool -D on");
}

void turn_display_off() {
	system("mcetool -D off");
}

int event_loop(char *device_name) {
	struct input_event event;
	int result, poll_result;
	time_t now, wake_lock_till = 0;
	int fd = open(device_name, O_RDONLY);
	if (fd == -1) {
		err_log("opening input device failed");
		return -1;
	}
	while(1) {
		if (wake_lock_till) {
			now = time(NULL);
			if (now > wake_lock_till) {
				turn_display_off();
				wake_lock_till = 0;
			}
		}
		poll_result = poll_fd(fd, 1);
		if (poll_result == -1) {
			err_log("poll failed");
			return -1;
		}
		if (poll_result == 1) {
			result = read(fd, &event, sizeof(struct input_event));
			if (result != sizeof(struct input_event)) {
				err_log("failed to read input event");
				return -1;
			}	
			if (event.type == EV_MSC && event.code == MSC_GESTURE) {
				if (!wake_lock_till) {
					turn_display_on();
				}
				wake_lock_till = time(NULL) + WAKE_TIME;
			}
		}
	}
}


int main() {
	event_loop(INPUT_DEVICE);
}
