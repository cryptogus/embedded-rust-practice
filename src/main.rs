#![no_std]
#![no_main]
use core::arch::asm;
use core::ptr;

#[unsafe(no_mangle)]
pub extern "C" fn Reset() -> ! {
    unsafe extern "C" {
        unsafe static mut _sdata: u8;
        unsafe static mut _edata: u8;
        unsafe static _sidata: u8;
    }
    unsafe {
        let count = &raw const _edata as usize - &raw const _sdata as usize;
        ptr::copy_nonoverlapping(&raw const _sidata, &raw mut _sdata, count);
    }

    unsafe extern "C" {
        unsafe static mut _sbss: u8;
        unsafe static mut _ebss: u8;
    }

    unsafe {
        let count = &raw const _ebss as usize - &raw const _sbss as usize;
        ptr::write_bytes(&raw mut _sbss, 0, count);
    }

    main()
}

fn main() -> ! {
    let mut counter: u32 = 0;

    loop {
        counter = counter.wrapping_add(1);
        unsafe {
            asm!("wfi");
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn DefaultHandler() -> ! {
    loop {
        unsafe { asm!("bkpt") };
    }
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {
        unsafe { asm!("bkpt") };
    }
}