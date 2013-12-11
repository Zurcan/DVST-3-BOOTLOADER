/*****************************************************
Project : 
Version : 
Date    : 12.03.2013
Author  : 
Company : 
Comments: 


Chip type           : ATmega168
Program type        : Boot Loader - Size:1024words
Clock frequency     : 0,460000 MHz
Memory model        : Small
External RAM size   : 0
Data Stack size     : 256
*****************************************************/

/*
***********���������� Bootloader�************************
1. ������������� ����� � �� �� ��������� HART-loader, 
   ���������� ������ ������������� ���������� ������
   � �� ������������ ����-3.
2. ����������� ������ ���������� (��������������������)
   ��� �� flash ������ ����������, ��� � � eeprom.
3. �������� CRC ������������ ���� ��� �����������
   ������������ ������.
*********************************************************

***********������ ������ ��������� ������ HART-loader****
������� ��������, ��� �������� HART-loader �������� �� ���� ��� �� 
���������� HART. ������� ������� � ����� ������������ �������, 
�������� �� � ���������� ����������������� ������� ����������� 
�����������. ������, ����� ����, ��� ���������� ������ ������ 
��������� ���  Bootloadera ������������� � ���������, �������� 
���� ��������� ������� HART-���������. ������������ ����������� 
� ����� ������ ��������� �������� ����� ������ ���
�������������������� �����������. � ���� �������, �����������
����� "������" ������ ������� �� ������ ����������. 
**********************************************************
   
***********������� ��������� ������ HART-loader**********
00 - ������ ����������������� ����������
06 - ������ ������ ���������� � HART-����
0f - ������ ��������� ������ �������
13 - ������ ��������� ������ ������� 
A9 - ������ �����
AA - ������ ��������, ��� ���� �������� ������������� ������������� (���� �� ������� ������ ���������� ���������������� 0���)
   - ����� ����������������
�� - ����� ����������������
   - ��, ����������� ������� ��, ��� ����� ������ ����� ���������, �.�. �� ����������� � ��� �� ��������� ����� - �������� �����
*********************************************************   
*/
//#include <mega168.h>

#include <delay.h>
#include <data_arrays.h>
//#include <mega328p_bits.h>
#define  PageByte 	 128     // 64 Bytes
#define  AddressLshift    6
#asm(".EQU SpmcrAddr=0x57")
#define IVCE 0
#define RXB8 1
#define TXB8 0
#define WDCE 4
#define WDE 3
#define WDP2 2
#define WDP1 1
#define WDP0 0
//#define UPE 2
//#define OVR 3
//#define FE 4
#define UDRE 5
#define RXC 7
//#define FRAMING_ERROR (1<<FE)
//#define PARITY_ERROR (1<<UPE)
//#define DATA_OVERRUN (1<<OVR)
//#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)
#define RxEn UCSR0B=(UCSR0B&0xc0)|0x10
#define TxEn UCSR0B=(UCSR0B&0xc0)|0x08
#define Transmit PORTD.3=0//=PORTD&0xf7
#define Recieve PORTD.3=1//PORTD|0x08
#define wait_startOCD EICRA=0x03
#define wait_stopOCD EICRA=0x00
#define disable_uart UCSR0B=0xc0
#define disable_eints {EIMSK=0x00;EIFR=0x00;}
#define enable_eints {EIMSK=0x01;EIFR=0x01;}
//#define enable_led PORTD=PORTD|0x40
//#define disable_led PORTD=PORTD&0xbf
#define start_wait_Rx_timer {TIMSK0=0x01;TCCR0A=0x00;TCCR0B=0x04;TCNT0=0xA0;}
#define stop_wait_Rx_timer {TIMSK0=0x00;TCCR0A=0x00;TCCR0B=0x00;TCNT0=0x00;}
//#define setlevel_0_10 {PORTD.7=0;PORTD.6=0;}
//#define setlevel_0_20 {PORTD.7=0;PORTD.6=1;}
//#define setlevel_0_30 {PORTD.7=1;PORTD.6=0;}
//#define setlevel_0_50 {PORTD.7=1;PORTD.6=1;}
// USART Receiver buffer
register unsigned int Pagedata @2; //program data to be written from this and read back for checking
register unsigned int PageAddress @4; //address of the page
register unsigned int CurrentAddress @6; //address of the current data -  PageAddress + loop counter
//register char inchar @8; //data received from RS232 
register char spmcrval @10; //value to write to SPM control register 
//register unsigned int i @11;   //loop counter
//register unsigned int j @13;  //loop counter  
#define RX_BUFFER_SIZE0 64
unsigned char rx_wr_index0,rx_counter0;
char rx_buffer0[RX_BUFFER_SIZE0];
//char com_data_rx[25];
char sensor_address=0x02,com_bytes_rx=0,writePageSegmentsCounter=0,p_bank_addr=0,checking_result=0,command_rx_val=0, preambula_bytes_rec, bytes_quantity_ans, Command_data[25], preambula_bytes;       //writePageSegmentsCounter - variable needed to navigate in page construction (filling temporary flash buffer), each segment consists of 32bytes of data, so total number of them in flash page is 4

bit rx_buffer_overflow0,message_recieved=0,answering=0,burst_mode=0;
volatile char runApplication = 0x00;
//unsigned int ubbr;
//unsigned int Checkdata ; //compared with Pagedata for checking
char PageBuffer[PageByte]; //buffer for data to be written 
eeprom char tmpval[256];
void transmit_HART(void); 
//int writePageToFlash(void);
int check_recieved_message(); 
int generate_command_data_array_answer(char command_recieved);
//void update_eeprom_parameters(char update_flag);
void start_transmit(int transmit_param);
void clear_buffer();
void BootLoad(void);
void eraseApplicationSection();
void (*voidFuncPtr)(void);
void (*APPLICATION)(void)=0x0000;
typedef void (*fptr_t)(void); 
volatile fptr_t reset = (fptr_t)0x0000; 
//void spmMacro(char val);
// Declare your global variables here
interrupt [USART_RXC] void usart_rx_isr(void)//����� �� USART
{

char data;
#asm("cli")
//status=UCSR0A;

data=UDR0;
//#asm("sei")

//if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)//���� ��� ������, �� ������ ������ � ������ USART
//   {
   rx_buffer0[rx_wr_index0]=data;
   if (++rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
   if (++rx_counter0 == RX_BUFFER_SIZE0)
      {
      rx_counter0=0;
      rx_buffer_overflow0=1;
    
     };
//   };
 #asm("sei")   
}
// USART Transmitter buffer
#define TX_BUFFER_SIZE0 64
char tx_buffer0[TX_BUFFER_SIZE0];

unsigned char tx_rd_index0,tx_counter0;


// USART Transmitter interrupt service routine
interrupt [USART_TXC] void usart_tx_isr(void)//�������� �� USART ��������������
{


if (tx_counter0)
   {
   --tx_counter0;
   
   UDR0=tx_buffer0[tx_rd_index0];

   if (++tx_rd_index0 == TX_BUFFER_SIZE0) tx_rd_index0=0;
   };
  
}
// External Interrupt 0 service routine
interrupt [EXT_INT0] void ext_int0_isr(void)//������������� ���������� �������� �� ������������ ������ (set_rising_edge_int), � ����� ����� ������ (set_falling_edge_int), ��� ������������� ��� � �������, � ����������� �������� ������ �������� �������.1-�����, 0- ��������. 
//��������, ������, ������������� ��������, ������ �� �������, ���������� ������ OCD ����� ������
{
if(EICRA==0x03)                    //���� ��������� ���������� �� �������� ������, �� ������������� �� ����� ������� ������ � ��������
                {
                Recieve;
                RxEn;
                //wait_stopOCD;
                //start_wait_Rx_timer;
                //disable_eints;
                wait_stopOCD;           //EICRA=0x00
                message_recieved=0;
                //mono_channel_mode;
                }
else 
                {
                //Transmit;
                
                //stop_wait_Rx_timer;
                wait_startOCD;            //EICRA=0x03
                disable_uart;             //��������� USART, ��������� � ����� ������
                message_recieved=1;
                
                }
//start_check_OCD_timer;//�������� ������ ������������� �������� 3.33 �� (4 ����� ��� ����������� ������� 1200��)

}



unsigned char USART_Receive( void )
{
/* Wait for data to be received */
while ( (UCSR0A&0x80)!=0 );
/* Get and return received data from buffer */
rx_counter0++;
//Parameter_bank[1]=0x02;
return UDR0;
}
void transmit_HART(void)//������������ �������� � �� HART 
{
int error_log;
error_log=check_recieved_message();    //����� ��������� ������������ ��������� ��������� � ������������� �������� ���������� "��������� ��������"
if(answering)                         //���� ����� �����
        {
        if (!error_log)               //������ ���
                {
                error_log=error_log|(generate_command_data_array_answer(command_rx_val));//����� ���������� � ��������� �������� ������� �� HART
                start_transmit(error_log);
                }
        else
                { //��������������, ���� ������ ����
                //PORTD=0x08;
                //Parameter_bank[4]=0x05;
                Recieve;
//                rx_buffer_overflow0=0;
//                checking_result=0;
//                rx_wr_index0=0;
                message_recieved=0;
                start_transmit(error_log);
                }
        }
else                              //����� �� HART �� �����
        {
//        rx_buffer_overflow0=0;
//        checking_result=0;
//        rx_wr_index0=0;
        RxEn;
        Recieve;
        }         
    checking_result=0;                //���������� "��������� ��������"
    rx_wr_index0=0;
    rx_buffer_overflow0=0;        
//clear_buffer();        
}

void start_transmit(int transmit_param)  // ����� ���������� ����������� �������� ���������, � ����� ������� �������� ��������� ������ ���� ��������� 
{                                                          //
char i=0,j=0;
char check_sum_tx=0;
while(UCSR0A<0x20){;}

//if(!RxTx){
preambula_bytes=Parameter_bank[3];
delay_ms(25);
Transmit;
TxEn;
delay_ms(15);
for (i=0;i<preambula_bytes;i++)
        {
        tx_buffer0[i]=0xff;
        tx_counter0++;
        }
//i++;         
if(burst_mode)tx_buffer0[i]=0x01;//��������� ����
else tx_buffer0[i]=0x06;
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i];//�����
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i];//�������
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
if(!transmit_param)
        {
        tx_buffer0[i]=bytes_quantity_ans+2;                                                  //����� ����  //����� ������� ������ � ����������� ���� ��� ���������� �������
        check_sum_tx=check_sum_tx^tx_buffer0[i];
        i++; 
        tx_buffer0[i]=p_bank_addr;                                             //������ 1� ����
        check_sum_tx=check_sum_tx^tx_buffer0[i]; 
        i++;      
        tx_buffer0[i]=0x00;                                             //������ 2� ����
        check_sum_tx=check_sum_tx^tx_buffer0[i];
        i++; 
        for(j=0;j<bytes_quantity_ans;j++)
                {
                tx_buffer0[i]=Command_data[j];                                                //������ //����� ����� ������� ������ � ������� ��� ���������� ������� � ����������� ��� �� ������� � ����� ��������
                check_sum_tx=check_sum_tx^tx_buffer0[i];
                i++;
                }
        }        
else {
        tx_buffer0[i]=com_bytes_rx+2;       //����� ������ ����� ���������� ���� �� ��������� ���������                                           //����� ����  //����� ������� ������ � ����������� ���� ��� ���������� �������
        //bytes_quantity_ans=rx_buffer0[preambula_bytes_rec-preambula_bytes+i]+2;  //��� �������� ��� �� ����� ���������, ���� ����� � �����
        check_sum_tx=check_sum_tx^tx_buffer0[i];
        i++;
        tx_buffer0[i]=transmit_param>>8;                                       //������ 1� ����
        check_sum_tx=check_sum_tx^tx_buffer0[i];
        i++;      
        tx_buffer0[i]=transmit_param;                                          //������ 2� ����
        check_sum_tx=check_sum_tx^tx_buffer0[i];
        i++;
        j=i;
        for(i=j;i<com_bytes_rx+j;i++)
                {
                tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i-2];                                                //������ ����� �� ������� �������� ������
                check_sum_tx=check_sum_tx^tx_buffer0[i];
                //i++; 
                }
        }
        //i++; 
tx_buffer0[i]=check_sum_tx;
tx_rd_index0=1;
//if(!transmit_param){
//for(i=0;i<=rx_counter0;i++)tx_buffer0[i]=rx_buffer0[i]; }  
//tx_rd_index0=1;           
tx_counter0=i;
UDR0=tx_buffer0[0];
//Parameter_bank[5]=0x06;
while(tx_counter0){;}
delay_ms(15);
//RxEn;
Recieve;
message_recieved=0;
rx_counter0=0;

}



int generate_command_data_array_answer(char command_recieved)//��������� �� ������ ����������� ������ ���������� (Parameter_bank) � ���������� ��� � ������������ ������ ������ (Command_data) � ������� ������������ ������� (Command_mask)
{
char i=0,error=0,j=0;
//char *dataPtr ;
//*dataPtr = Parameter_bank[98];

//runApplication=0x00;
bytes_quantity_ans=1; 
//if((command_recieved==0x00)|(command_recieved==0x06)|(command_recieved==0x16)|(command_recieved==0x19)|(command_recieved==0xaa)| (command_recieved==0xab))error=0
if(command_recieved == 0x00)
{

    bytes_quantity_ans=12;    
    //while(i<12)
    for(i=1;i<12;i++)     
    Command_data[i]=Parameter_bank[i];
//    error=0;
}
if(command_recieved==0x06)
{
    // bytes_quantity_ans=1;
     sensor_address = rx_buffer0[preambula_bytes_rec+4];
     Parameter_bank[25] = sensor_address;
     Command_data[0] =  sensor_address;     
 //    error=0;
}
if(command_recieved==16)
{
    bytes_quantity_ans=3;
   for(i=0;i<3;i++)  
   Command_data[i] = Parameter_bank[98+i];         
   //Command_data[1] = *dataPtr;
    //Command_data[i]=*(dataPtr+i) ;    
//    Command_data[2]=Parameter_bank[99];
//    Command_data[3]=Parameter_bank[100];
//    error=0;
}
if(command_recieved==19)
{
    bytes_quantity_ans=3;
    for(i=0;i<3;i++)
    Parameter_bank[98+i]=rx_buffer0[preambula_bytes_rec+4+i];   
    //Parameter_bank[99]=rx_buffer0[preambula_bytes_rec+5];
    //Parameter_bank[100]=rx_buffer0[preambula_bytes_rec+6];  
//    error=0;
}
//if(command_recieved==42)
//{
//   //bytes_quantity_ans=0;
//   //Command_data[0]=   
//   //if(rx_buffer0[]
//   Command_data[0] =  0x0C;
//}
if(command_recieved>=0xaa)
{
    

//    if(writePageSegmentsCounter<3)writePageSegmentsCounter++;
//    else writePageSegmentsCounter = 0;
    if(command_recieved==0xaa)
    {
        for(i=writePageSegmentsCounter*32; i<(writePageSegmentsCounter+1)*32;i++,j++)
            PageBuffer[i]=rx_buffer0[preambula_bytes_rec+4+j];         
        if(writePageSegmentsCounter==3)
        {
            #asm("cli")
            BootLoad();
            #asm("sei")
            writePageSegmentsCounter=0;  
                        
            //PageAddress+=128;
        }
        else writePageSegmentsCounter++;
    }  
    else
    {
     runApplication=0x11;
     writePageSegmentsCounter=0;       
//    MCUCR = 0x01;
//    MCUCR = 0x00;
////Parameter_bank[0]=0x11;
//    //delay_ms(100);
//    voidFuncPtr=(void(*)(void))0x00B8;   //������ ���� ���������
//    voidFuncPtr();
//    #asm("jmp 0x00B8");
     }   
    Command_data[0] =  0x0C;       
 //   error=0;
 
}
//if(command_recieved==0xab)
//{
//    runApplication=0x11;
//    Command_data[0] =  0x0C;       
//     error=0;     
//}
return error;
}         

int check_recieved_message(){
char i=0,j=0,k=0,tmp_i=0;//����� i - ������� ���� ���� j- ������� ���� ��������

int check_sum=0; 
checking_result=0;
answering=1; 
while ((rx_buffer0[j])==0xff)
        {
        if(8<j)
                {checking_result=0x90;//������ ������������ ������, ���� ���������� �������� ������ ���� ����� ���������� ��������
                 //rx_buffer0[i+1]=0x00;
                 return checking_result;
                 }
         j++;        
        }
        preambula_bytes_rec=j;
        i=j;
if ((rx_buffer0[j])!=0x02)
//if ((rx_buffer0[i])!=0x02)
        {
        checking_result=0x02;
        //return checking_result;
        }//������������� ������ ������ "�������� �����", ���� �� �� �������� ����������
//else    {
        check_sum=check_sum^rx_buffer0[i];
//        }
i++;         
if (((rx_buffer0[i])&0x30)!=0x00)
        {checking_result=0x90;
        //return checking_result;
        }
//burst_mode=(rx_buffer0[i]&0x40)>>6;                          //burst_mode ����� ������-�� ����������� � �������         
if((rx_buffer0[i]&0x0f)==Parameter_bank[25])answering=1;       //��� �������� ������, ���� ����� �� ���, ������ ������
else answering=0;
check_sum=check_sum^rx_buffer0[i];  
i++;
command_rx_val=rx_buffer0[i];// ����� ���� �� ������ �������� �������: ���� ��� ������� � ����� ������, �� ������ �� ������, ���� ��� => checking_result=0x0600;
check_sum=check_sum^rx_buffer0[i];
i++; 
com_bytes_rx=rx_buffer0[i];                    //���������� ����, ���� �� ��������� ����� ���� ������ � ���� ��� �� ���������, ������������� ��� ���-���� ������ ������������ ������ 0�9000
check_sum=check_sum^rx_buffer0[i];
i++;
tmp_i=i;
j=tmp_i;
for (i=tmp_i;i<tmp_i+com_bytes_rx;i++)
       {
       j++;
       //com_data_rx[k]=rx_buffer0[i];
       check_sum=check_sum^rx_buffer0[i];
       k++;
       }
                //j++;
//        if(com_bytes_rx!=0)i--;        
if (j!=i)
       {checking_result=0x90;
       //return checking_result;
       }
//i++;                
if(rx_buffer0[i]!=check_sum)
        {
        checking_result=0x88;
        //return checking_result;
        }                
return checking_result;
}

void clear_buffer()
{
char i=0;
for (i=0;i<RX_BUFFER_SIZE0;i++)
        {
        rx_buffer0[i]=0;
        tx_buffer0[i]=0;
        }
for (i=0;i<25;i++)
        {
//        com_data_rx[i]=0;
        Command_data[i]=0;
        }
}        

void system_init(){
//#asm("wdr")
//WDTCSR=0x38;
//WDTCSR=0x0E;
// Crystal Oscillator division factor: 1 
/*#pragma optsize-
CLKPR=0x80;
CLKPR=0x00;
#ifdef _OPTIMIZE_SIZE_
#pragma optsize+
#endif
  */
// Input/Output Ports initialization
// Port B initialization
// Func7=In Func6=In Func5=Out Func4=In Func3=Out Func2=Out Func1=In Func0=In 
// State7=T State6=T State5=0 State4=T State3=0 State2=0 State1=T State0=T 
PORTB=0x00;
DDRB=0x2c;

// Port D initialization
// Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
// State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 
//PORTD=0x00;
DDRD.3=1;
PORTD.3=1;
//DDRD.6=1;
//DDRD.7=1;
//PORTD.6=0;
//PORTD.7=0;

stop_wait_Rx_timer;
/*USART predefinition: 1200 baud rate, tx enable, all interrutpts enabled 8bit buffer*/
//UCSR0A=0x00;
UCSR0B=0xc0;
UCSR0C=0x06;
//UBRR0H=0x00;
UBRR0L=0x17;


// External Interrupt(s) initialization
// INT0: On
// INT0 Mode: Any change
// INT1: Off
// Interrupt on any change on pins PCINT0-7: Off
// Interrupt on any change on pins PCINT8-14: Off
// Interrupt on any change on pins PCINT16-23: Off
wait_startOCD;
EIMSK=0x01;
EIFR=0x01;
//PCICR=0x00;
MCUCR = 0x01;
MCUCR = 0x03;

}

void BootLoad(void)
{ 
    char i=0;
    for (i=0;i<PageByte;i+=2) //fill temporary buffer in 2 byte chunks from PageBuffer       
    
        {
        Pagedata=PageBuffer[i]+(PageBuffer[i+1]<<8);   
        CurrentAddress=PageAddress+i; 
//        spmMacro(1);
        while (SPMCSR&1); //wait for spm complete
        spmcrval=1;
        #asm 
        movw r30, r6    ;//move CurrentAddress to Z pointer   
        mov r1, r3        ;//move Pagedata MSB reg 1
        mov r0, r2        ;//move Pagedata LSB reg 1  
        sts SpmcrAddr, r10   ;//move spmcrval to SPM control register
        spm                ;//store program memory
        #endasm
        }    
//         spmMacro(3);
//         spmMacro(5);
    while (SPMCSR&1);  //wait for spm complete
    spmcrval=3;        //erase page
    #asm 
    movw r30, r4       ;//move PageAddress to Z pointer
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
    spm                 ;//erase page
    #endasm
      
    while (SPMCSR&1); //wait for spm complete
    spmcrval=5;        //write page
    #asm 
    movw r30, r4       ;//move PageAddress to Z pointer
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
    spm                 ;//write page
    #endasm
    PageAddress +=128 ; //essentially the same as multiply by PageSize
  }
//void spmMacro(char val)
//{
//    while (SPMCSR&1); //wait for spm complete
//    spmcrval=val;        //if val = 5 - write page if val = 3 - erase page, if val = 1 save data to buffe
//    #asm 
//    movw r30, r4       ;//move PageAddress to Z pointer
//    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
//    spm                 ;//write page
//    #endasm
//}
void eraseApplicationSection()
{
#asm("cli");
for(PageAddress=0; PageAddress<12288; PageAddress++)
{
    while (SPMCSR&1);  //wait for spm complete
    spmcrval=3;        //erase page
    #asm 
    movw r30, r4       ;//move PageAddress to Z pointer
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
    spm                 ;//erase page
    #endasm
}
PageAddress=0;
runApplication=0x00;
#asm("sei");

}           
void executeLoadedCode(void)
{
#asm("sei");
system_init();
RxEn;
Recieve;
//#asm("wdr");
//Parameter_bank[0]=0x11;
//delay_ms(1000);

//Parameter_bank[0]=0x11;
SPMCSR = 0x00;
delay_ms(100);

//reset();
//APPLICATION();
//voidFuncPtr=(void(*)(void))0x0000;   //������ ���� ���������
//voidFuncPtr();

}
void main(void)
{
// Declare your local variables here
//int i=0,j=0;
//int a = 0;
system_init();

//for(i =0; i<128; i++)
//PageBuffer[i]=i;
//BootLoad();
//SPMCSR = 0x00;
//#asm("wdr")
//
//for(i=0; i < 64;i++)
//{
//
//formTmpBuffer(i);          
//
//}
//erasePageFromMemory(0x0000);

//while (SPMCSR&1);
//writePageToMemory(0x0000);


//sensor_address=Parameter_bank[14];
//writePageToFlash();
#asm("sei")
//#asm("wdr")
        runApplication=Parameter_bank[0];   
//        Parameter_bank[0]++;
        //runApplication=0x11;
        RxEn;
        Recieve;
//delay_ms(2000);

        

        while (1)
              {
                #asm("wdr")    
                if(runApplication==0x11)//&(runApplication<0x15))
                    {
                    delay_ms(10);
                    //executeLoadedCode();  
                    Parameter_bank[0]=0x11;
                    delay_ms(10);
                    #asm("sei");
                    MCUCR = 0x01;
                    MCUCR = 0x00;     
                    reset();
//                   #asm 
//                                  ldi r16, 0;\n\t" 
//                                  push r16;\n\t" 
//                                  ldi r16, 0;\n\t" 
//                                  push r16; \n\t" 
//                                  ret;   \n\t" 
//                                 
//                   #endasm
//                    #asm ("jmp 0x0000");
                    } 
               // if((runApplication>=0x15)&(runApplication<0xee))Parameter_bank[0]=0x00;
                if(runApplication>=0xee)
                    {
                    eraseApplicationSection();
                    
                    delay_ms(10);
                    Parameter_bank[0]=0x00;
                    Parameter_bank[2]=0xA3;
                    }
               // if(runApplication==0x01)Parameter_bank[0]=0x00;
                if(message_recieved)
                {
                transmit_HART();        
                }

              }
}
