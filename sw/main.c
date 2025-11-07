#include "xparameters.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xil_types.h"
#include "xuartlite.h"
#include "xuartlite_l.h"
#include "microblaze_sleep.h"
#include "xgpio.h"

#include "trng_testbed.h"

u8 get_health(u8* HEALTH_ADDRESS);

void set_total(u8* TOTAL_ADDRESS, u32 total);
u32 get_total(u8* TOTAL_ADDRESS);

void set_memaddr(u8* MEMADDR_ADDRESS, u32 memaddr);
u32 get_memaddr(u8* MEMADDR_ADDRESS);

void set_rng(u8* RNG_ADDRESS, u32 rng);
u32 get_rng(u8* RNG_ADDRESS);

void set_status(u8* STATUS_ADDRESS, u8 status);
u8 get_status(u8* STATUS_ADDRESS);

u32 get_count(u32* COUNT_ADDRESS);

void run_data_collection(u32 timeout);

u8 data[1000000];

XGpio Gpio; // The driver instance
#define LED_CHANNEL 1

int main()
{
	// Initialize the driver
	int Status = XGpio_Initialize(&Gpio, XPAR_AXI_GPIO_0_BASEADDR);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// Set the LED channel's direction to output
	XGpio_SetDataDirection(&Gpio, LED_CHANNEL, 0x0);

	u8 is_active = 0x1;

	while (is_active)
	{
		 unsigned char c;
		 c = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);

		 switch (c) {
		     case 'r':
		    	 /* Set the LED to High */
				 XGpio_DiscreteWrite(&Gpio, LED_CHANNEL, 0x01);
				 run_data_collection(100);
				 XGpio_DiscreteClear(&Gpio, LED_CHANNEL, 0x01);
		         break;
		     case 's':
		    	 is_active = 0x0;
		    	 break;
		     default:
		         break;
		 }
	}

	while(1);
}

u8 get_health(u8* HEALTH_ADDRESS)
{
	return *HEALTH_ADDRESS;
}

void set_total(u8* TOTAL_ADDRESS, u32 total)
{
	u32* addr = (u32*) TOTAL_ADDRESS;
	*addr = total;
}

u32 get_total(u8* TOTAL_ADDRESS)
{
	u32* addr = (u32*) TOTAL_ADDRESS;
	return *addr;
}

void set_memaddr(u8* MEMADDR_ADDRESS, u32 memaddr)
{
	u32* addr = (u32*) MEMADDR_ADDRESS;
	*addr = memaddr;
}

u32 get_memaddr(u8* MEMADDR_ADDRESS)
{
	u32* addr = (u32*) MEMADDR_ADDRESS;
	return *addr;
}

void set_rng(u8* RNG_ADDRESS, u32 rng)
{
	u32* addr = (u32*) RNG_ADDRESS;
	*addr = rng;
}

u32 get_rng(u8* RNG_ADDRESS)
{
	u32* addr = (u32*) RNG_ADDRESS;
	return *addr;
}

void set_status(u8* STATUS_ADDRESS, u8 status)
{
	*STATUS_ADDRESS = status;
}

u8 get_status(u8* STATUS_ADDRESS)
{
	return *STATUS_ADDRESS;
}

u32 get_count(u32* COUNT_ADDRESS)
{
	u32* addr = (u32*) COUNT_ADDRESS;
	return *addr;
}

void run_data_collection(u32 timeout)
{
	void* data_addr = (void*)data;

	u32 total   = 1000000;
	u32 memaddr = (u32)data_addr;
	u32 rng     = 0;

	u32 t = 0;
	u8 c[7];
	int idx = -1;

	u8 success = 's';

//	while(t < timeout)
//	{
//		while(!XUartLite_IsReceiveEmpty(XPAR_UARTLITE_0_BASEADDR) && idx < 7)
//		{
//			idx    = idx + 1;
//			c[idx] = XUartLite_RecvByte(XPAR_UARTLITE_0_BASEADDR);
//		}
//
//		if (idx >= 7)
//			break;
//
//		t += 1;
//		MB_Sleep(1);
//	}
//
//	if (idx >= 0)
//	{
//		switch (idx) {
//			case 7:
//				total = (c[7] << 24) |
//					    (c[6] << 16) |
//					    (c[5] <<  8) |
//					    (c[4]      );
//			case 3:
//				rng = (c[3] << 24) |
//					  (c[2] << 16) |
//					  (c[1] <<  8) |
//					  (c[0]      );
//			default:
//				break;
//		}
//	}

	u8 health = get_health((u8*)TRNGTESTBED_STATUS_HEALTH_ADDR);
	while (t < timeout && health != 1)
	{
		t += 1;

		health = get_health((u8*)TRNGTESTBED_STATUS_HEALTH_ADDR);

		MB_Sleep(1);
	}

	if (t == timeout)
	{
		success = 'f';
	}
	else
	{
		set_total((u8*)TRNGTESTBED_STATUS_TOTAL_ADDR, total);
		set_memaddr((u8*)TRNGTESTBED_STATUS_MEMADDR_ADDR, memaddr);
		set_rng((u8*)TRNGTESTBED_STATUS_RNG_ADDR, rng);

		set_status((u8*)TRNGTESTBED_STATUS_MODE_ADDR, 1);

		t = 0;
		while ((t < timeout) && (get_status((u8*)TRNGTESTBED_STATUS_MODE_ADDR) == 1))
		{
			MB_Sleep(1);
			t += 1;
		}

		if (t == timeout && (get_status((u8*)TRNGTESTBED_STATUS_MODE_ADDR) == 1))
		{
			success = 't';
		}
	}

	XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, success);

	if (success == 's')
	{
		for (u32 i = 0; i < total; i++)
		{
			XUartLite_SendByte(XPAR_UARTLITE_0_BASEADDR, data[i]);
		}
	}
}
