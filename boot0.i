
#pragma used+

void delay_us(unsigned int n);
void delay_ms(unsigned int n);

#pragma used-

#pragma used+
sfrb PINB=3;
sfrb DDRB=4;
sfrb PORTB=5;
sfrb PINC=6;
sfrb DDRC=7;
sfrb PORTC=8;
sfrb PIND=9;
sfrb DDRD=0xa;
sfrb PORTD=0xb;
sfrb TIFR0=0x15;
sfrb TIFR1=0x16;
sfrb TIFR2=0x17;
sfrb PCIFR=0x1b;
sfrb EIFR=0x1c;
sfrb EIMSK=0x1d;
sfrb GPIOR0=0x1e;
sfrb EECR=0x1f;
sfrb EEDR=0x20;
sfrb EEARL=0x21;
sfrb EEARH=0x22;
sfrw EEAR=0x21;   
sfrb GTCCR=0x23;
sfrb TCCR0A=0x24;
sfrb TCCR0B=0x25;
sfrb TCNT0=0x26;
sfrb OCR0A=0x27;
sfrb OCR0B=0x28;
sfrb GPIOR1=0x2a;
sfrb GPIOR2=0x2b;
sfrb SPCR=0x2c;
sfrb SPSR=0x2d;
sfrb SPDR=0x2e;
sfrb ACSR=0x30;
sfrb SMCR=0x33;
sfrb MCUSR=0x34;
sfrb MCUCR=0x35;
sfrb SPMCSR=0x37;
sfrb SPL=0x3d;
sfrb SPH=0x3e;
sfrb SREG=0x3f;
#pragma used-

#asm
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
#endasm

eeprom char Parameter_bank[138]={0x00,                                                  
0x56,                                                  
0xa3,                                                  
0x04,                                                  
0x01,                                                  
0x01,                                                  
0x01,                                                  
0x21,                                                  
0x00,                                                  
0x00, 0xBF, 0xBC,                                      
0x6d,                                                  
0,0,0,0,                                               
0,0,0,0,                                               
0,0,0,0,                                               
0x02,                                                  
0,0,0,0,0,0,                                           
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,       
0,0,0,0,0,0,0,0,0,0,0,0,                               
0,0,0,                                                 
0x01, 0x02, 0x03,                                      
0x42, 0x48,0,0,                                        
0,0,0,0,                                               
0x3C, 0x23, 0xD7, 0x0A,                                
0,                                                     
0,                                                     
0x00,0x00,0xA0,0x41,                                   
0,0,0,0,                                               
0xf0,                                                  
0x0f,                                                  
0x05, 0x00, 0x01,                                      

0,0,0,0,                                               
0x00,0x00,0x80,0x40,                                   
0x00,0x00,0xA0,0x41,                                   
0,0,0,0,                                               
0,0,0,0,0,0,                                           
0,0,0,0,0,0,0,0,0,0,0,                                 
0,                                                     
0,                                                     
0,                                                     
0                                                      
};

#asm(".EQU SpmcrAddr=0x57")

register unsigned int Pagedata @2; 
register unsigned int PageAddress @4; 
register unsigned int CurrentAddress @6; 

register char spmcrval @10; 

unsigned char rx_wr_index0,rx_counter0;
char rx_buffer0[64];

char sensor_address=0x02,com_bytes_rx=0,writePageSegmentsCounter=0,p_bank_addr=0,checking_result=0,command_rx_val=0, preambula_bytes_rec, bytes_quantity_ans, Command_data[25], preambula_bytes;       

bit rx_buffer_overflow0,message_recieved=0,answering=0,burst_mode=0;
volatile char runApplication = 0x00;

char PageBuffer[128     ]; 
eeprom char tmpval[256];
void transmit_HART(void); 

int check_recieved_message(); 
int generate_command_data_array_answer(char command_recieved);

void start_transmit(int transmit_param);
void clear_buffer();
void BootLoad(void);
void eraseApplicationSection();
void (*voidFuncPtr)(void);
void (*APPLICATION)(void)=0x0000;
typedef void (*fptr_t)(void); 
volatile fptr_t reset = (fptr_t)0x0000; 

interrupt [19] void usart_rx_isr(void)
{

char data;
#asm("cli")

data=(*(unsigned char *) 0xc6);

rx_buffer0[rx_wr_index0]=data;
if (++rx_wr_index0 == 64) rx_wr_index0=0;
if (++rx_counter0 == 64)
{
rx_counter0=0;
rx_buffer_overflow0=1;

};

#asm("sei")   
}

char tx_buffer0[64];

unsigned char tx_rd_index0,tx_counter0;

interrupt [21] void usart_tx_isr(void)
{

if (tx_counter0)
{
--tx_counter0;

(*(unsigned char *) 0xc6)=tx_buffer0[tx_rd_index0];

if (++tx_rd_index0 == 64) tx_rd_index0=0;
};

}

interrupt [2] void ext_int0_isr(void)

{
if((*(unsigned char *) 0x69)==0x03)                    
{
PORTD.3=1;
(*(unsigned char *) 0xc1)=((*(unsigned char *) 0xc1)&0xc0)|0x10;

(*(unsigned char *) 0x69)=0x00;           
message_recieved=0;

}
else 
{

(*(unsigned char *) 0x69)=0x03;            
(*(unsigned char *) 0xc1)=0xc0;             
message_recieved=1;

}

}

unsigned char USART_Receive( void )
{

while ( ((*(unsigned char *) 0xc0)&0x80)!=0 );

rx_counter0++;

return (*(unsigned char *) 0xc6);
}
void transmit_HART(void)
{
int error_log;
error_log=check_recieved_message();    
if(answering)                         
{
if (!error_log)               
{
error_log=error_log|(generate_command_data_array_answer(command_rx_val));
start_transmit(error_log);
}
else
{ 

PORTD.3=1;

message_recieved=0;
start_transmit(error_log);
}
}
else                              
{

(*(unsigned char *) 0xc1)=((*(unsigned char *) 0xc1)&0xc0)|0x10;
PORTD.3=1;
}         
checking_result=0;                
rx_wr_index0=0;
rx_buffer_overflow0=0;        

}

void start_transmit(int transmit_param)  
{                                                          
char i=0,j=0;
char check_sum_tx=0;
while((*(unsigned char *) 0xc0)<0x20){;}

preambula_bytes=Parameter_bank[3];
delay_ms(25);
PORTD.3=0;
(*(unsigned char *) 0xc1)=((*(unsigned char *) 0xc1)&0xc0)|0x08;
delay_ms(15);
for (i=0;i<preambula_bytes;i++)
{
tx_buffer0[i]=0xff;
tx_counter0++;
}

if(burst_mode)tx_buffer0[i]=0x01;
else tx_buffer0[i]=0x06;
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i];
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i];
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
if(!transmit_param)
{
tx_buffer0[i]=bytes_quantity_ans+2;                                                  
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
tx_buffer0[i]=p_bank_addr;                                             
check_sum_tx=check_sum_tx^tx_buffer0[i]; 
i++;      
tx_buffer0[i]=0x00;                                             
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++; 
for(j=0;j<bytes_quantity_ans;j++)
{
tx_buffer0[i]=Command_data[j];                                                
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++;
}
}        
else {
tx_buffer0[i]=com_bytes_rx+2;       

check_sum_tx=check_sum_tx^tx_buffer0[i];
i++;
tx_buffer0[i]=transmit_param>>8;                                       
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++;      
tx_buffer0[i]=transmit_param;                                          
check_sum_tx=check_sum_tx^tx_buffer0[i];
i++;
j=i;
for(i=j;i<com_bytes_rx+j;i++)
{
tx_buffer0[i]=rx_buffer0[preambula_bytes_rec-preambula_bytes+i-2];                                                
check_sum_tx=check_sum_tx^tx_buffer0[i];

}
}

tx_buffer0[i]=check_sum_tx;
tx_rd_index0=1;

tx_counter0=i;
(*(unsigned char *) 0xc6)=tx_buffer0[0];

while(tx_counter0){;}
delay_ms(15);

PORTD.3=1;
message_recieved=0;
rx_counter0=0;

}

int generate_command_data_array_answer(char command_recieved)
{
char i=0,error=0,j=0;

bytes_quantity_ans=1; 

if(command_recieved == 0x00)
{

bytes_quantity_ans=12;    

for(i=1;i<12;i++)     
Command_data[i]=Parameter_bank[i];

}
if(command_recieved==0x06)
{

sensor_address = rx_buffer0[preambula_bytes_rec+4];
Parameter_bank[25] = sensor_address;
Command_data[0] =  sensor_address;     

}
if(command_recieved==16)
{
bytes_quantity_ans=3;
for(i=0;i<3;i++)  
Command_data[i] = Parameter_bank[98+i];         

}
if(command_recieved==19)
{
bytes_quantity_ans=3;
for(i=0;i<3;i++)
Parameter_bank[98+i]=rx_buffer0[preambula_bytes_rec+4+i];   

}

if(command_recieved>=0xaa)
{

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

}
else writePageSegmentsCounter++;
}  
else
{
runApplication=0x11;
writePageSegmentsCounter=0;       

}   
Command_data[0] =  0x0C;       

}

return error;
}         

int check_recieved_message(){
char i=0,j=0,k=0,tmp_i=0;

int check_sum=0; 
checking_result=0;
answering=1; 
while ((rx_buffer0[j])==0xff)
{
if(8<j)
{checking_result=0x90;

return checking_result;
}
j++;        
}
preambula_bytes_rec=j;
i=j;
if ((rx_buffer0[j])!=0x02)

{
checking_result=0x02;

}

check_sum=check_sum^rx_buffer0[i];

i++;         
if (((rx_buffer0[i])&0x30)!=0x00)
{checking_result=0x90;

}

if((rx_buffer0[i]&0x0f)==Parameter_bank[25])answering=1;       
else answering=0;
check_sum=check_sum^rx_buffer0[i];  
i++;
command_rx_val=rx_buffer0[i];
check_sum=check_sum^rx_buffer0[i];
i++; 
com_bytes_rx=rx_buffer0[i];                    
check_sum=check_sum^rx_buffer0[i];
i++;
tmp_i=i;
j=tmp_i;
for (i=tmp_i;i<tmp_i+com_bytes_rx;i++)
{
j++;

check_sum=check_sum^rx_buffer0[i];
k++;
}

if (j!=i)
{checking_result=0x90;

}

if(rx_buffer0[i]!=check_sum)
{
checking_result=0x88;

}                
return checking_result;
}

void clear_buffer()
{
char i=0;
for (i=0;i<64;i++)
{
rx_buffer0[i]=0;
tx_buffer0[i]=0;
}
for (i=0;i<25;i++)
{

Command_data[i]=0;
}
}        

void system_init(){

PORTB=0x00;
DDRB=0x2c;

DDRD.3=1;
PORTD.3=1;

{(*(unsigned char *) 0x6e)=0x00;TCCR0A=0x00;TCCR0B=0x00;TCNT0=0x00;};

(*(unsigned char *) 0xc1)=0xc0;
(*(unsigned char *) 0xc2)=0x06;

(*(unsigned char *) 0xc4)=0x17;

(*(unsigned char *) 0x69)=0x03;
EIMSK=0x01;
EIFR=0x01;

MCUCR = 0x01;
MCUCR = 0x03;

}

void BootLoad(void)
{ 
char i=0;
for (i=0;i<128     ;i+=2) 

{
Pagedata=PageBuffer[i]+(PageBuffer[i+1]<<8);   
CurrentAddress=PageAddress+i; 

while (SPMCSR&1); 
spmcrval=1;
#asm 
        movw r30, r6    ;//move CurrentAddress to Z pointer   
        mov r1, r3        ;//move Pagedata MSB reg 1
        mov r0, r2        ;//move Pagedata LSB reg 1  
        sts SpmcrAddr, r10   ;//move spmcrval to SPM control register
        spm                ;//store program memory
        #endasm
}    

while (SPMCSR&1);  
spmcrval=3;        
#asm 
    movw r30, r4       ;//move PageAddress to Z pointer
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
    spm                 ;//erase page
    #endasm

while (SPMCSR&1); 
spmcrval=5;        
#asm 
    movw r30, r4       ;//move PageAddress to Z pointer
    sts SpmcrAddr, r10    ;//move spmcrval to SPM control register              
    spm                 ;//write page
    #endasm
PageAddress +=128 ; 
}

void eraseApplicationSection()
{
#asm("cli");
for(PageAddress=0; PageAddress<12288; PageAddress++)
{
while (SPMCSR&1);  
spmcrval=3;        
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
(*(unsigned char *) 0xc1)=((*(unsigned char *) 0xc1)&0xc0)|0x10;
PORTD.3=1;

SPMCSR = 0x00;
delay_ms(100);

}
void main(void)
{

system_init();

#asm("sei")

runApplication=Parameter_bank[0];   

(*(unsigned char *) 0xc1)=((*(unsigned char *) 0xc1)&0xc0)|0x10;
PORTD.3=1;

while (1)
{
#asm("wdr")    
if(runApplication==0x11)
{
delay_ms(10);

Parameter_bank[0]=0x11;
delay_ms(10);
#asm("sei");
MCUCR = 0x01;
MCUCR = 0x00;     
reset();

} 

if(runApplication>=0xee)
{
eraseApplicationSection();

delay_ms(10);
Parameter_bank[0]=0x00;
Parameter_bank[2]=0xA3;
}

if(message_recieved)
{
transmit_HART();        
}

}
}
