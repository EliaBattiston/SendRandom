#include "Timer.h"
#include "sendRandom.h"
#include "printf.h"

module sendRandomC
{
	uses
	{
		/****** INTERFACES *****/
		interface Boot;

		interface Receive;
		interface AMSend;
		interface SplitControl;
		interface Packet;
		interface Timer<TMilli> as MilliTimer;
		interface Random;
	}
}
implementation
{
	message_t packet;

	bool transmitting = FALSE;

	event void Boot.booted()
	{
		dbg("boot", "Application booted\n");
		
		if(TOS_NODE_ID != 1) //Node 2 and 3 start the timer
		{
			call MilliTimer.startPeriodic(5000);
		}

		//Start the radio
		call SplitControl.start();
	}

	event void SplitControl.startDone(error_t err)
	{
		if(err == SUCCESS)
		{
			dbg("radio", "Radio started\n");
		}
		else
		{
			dbg("radio", "ERR: Radio failed to start, trying again...\n");
			call SplitControl.start();
		}
	}

	event void SplitControl.stopDone(error_t err)
	{
		//Debug statements even if this event will never fire, just in case
		if(err == SUCCESS)
		{
			dbg("radio", "Radio stopped\n");
		}
		else
		{
			dbg("radio", "ERR: Radio failed to stop\n");
		}
	}

	event void MilliTimer.fired()
	{
		if(transmitting)
		{
			return;
		}
		else
		{
			//Create packet
			my_msg_t* message = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
			if(message == NULL)
			{
				dbg("radio", "ERR: Unable to create request packet\n");
				return;
			}

			message->topic = TOS_NODE_ID;
			message->value = call Random.rand16() % 101;
			
			//Send the message to mote 1
			if( call AMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS )
			{
				dbg("radio", "Sending packet");
				//Lock transmission until it ends
				transmitting = TRUE;
			}
		}
	}

	event void AMSend.sendDone(message_t* buf, error_t err)
	{
		if(&packet == buf)
		{
			//Remove transmission lock when our packet finished being sent
			transmitting = FALSE;

			dbg("radio_ack", "RESP correctly sent\n");
		}
	}

	event message_t *Receive.receive(message_t* buf, void *payload, uint8_t len)
	{
		if(len != sizeof(my_msg_t))
		{
			dbg("radio_rec", "ERR: Received a packet of wrong size\n");
		}
		else
		{
			my_msg_t* message = (my_msg_t*)payload;

			if(TOS_NODE_ID == 1)
			{
				dbg("radio_rec", "Received packet\n");
				printf("%d:%d\n", message->topic, message->value);
				printfflush();
			}
		}

		return buf;
	}
}