#ifndef NODERED_H
#define NODERED_H

//payload of the msg
typedef nx_struct my_msg {
	nx_uint8_t topic;
	nx_uint8_t value;
} my_msg_t;

enum{
	AM_MY_MSG = 6,
};

#endif
