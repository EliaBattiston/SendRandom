#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "sendRandom.h"

configuration sendRandomAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, sendRandomC as App;
  components RandomC;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components ActiveMessageC;
  components new TimerMilliC();
  components PrintfC;
  components SerialStartC;

/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.SplitControl -> ActiveMessageC;
  App.MilliTimer -> TimerMilliC;
  App.Random -> RandomC;
  RandomC <- MainC.SoftwareInit;
}