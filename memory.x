/* memory.x — 링커 스크립트 */
/* LM3S6965 (QEMU에서 에뮬레이션하는 Cortex-M3 MCU) */

MEMORY
{
    /* Flash: 프로그램 코드 저장 영역 */
    /* rx = read + execute (읽기, 실행 가능 / 쓰기 불가) */
    FLASH : ORIGIN = 0x00000000, LENGTH = 256K

    /* SRAM: 변수, 스택 영역 */
    /* rwx = read + write + execute */
    RAM   : ORIGIN = 0x20000000, LENGTH = 64K
}

/* 스택의 시작 주소 = RAM 끝 (스택은 위에서 아래로 자람) */
_stack_top = ORIGIN(RAM) + LENGTH(RAM);

/* 섹션 배치 규칙 */
SECTIONS
{
    /* ============================================ */
    /* .vector_table — 벡터 테이블 (가장 먼저 와야 함) */
    /* ============================================ */
    .vector_table ORIGIN(FLASH) :
    {
        /* 첫 4바이트: 초기 스택 포인터 */
        LONG(_stack_top)

        /* 다음 4바이트: 리셋 핸들러 주소 (진입점) */
        LONG(Reset + 1)       /* +1: Thumb 모드 표시 */

        /* 나머지 예외 핸들러들 (일단 간단히) */
        LONG(DefaultHandler + 1)   /* NMI */
        LONG(DefaultHandler + 1)   /* HardFault */
        LONG(DefaultHandler + 1)   /* MemManage */
        LONG(DefaultHandler + 1)   /* BusFault */
        LONG(DefaultHandler + 1)   /* UsageFault */
    } > FLASH

    /* ============================================ */
    /* .text — 실행 코드 */
    /* ============================================ */
    .text :
    {
        *(.text .text.*)
    } > FLASH

    /* ============================================ */
    /* .rodata — 읽기 전용 데이터 (상수 문자열 등) */
    /* ============================================ */
    .rodata :
    {
        *(.rodata .rodata.*)
    } > FLASH

    /* ============================================ */
    /* .data — 초기값이 있는 전역 변수 */
    /* Flash에 초기값 저장, RAM에서 실행 */
    /* ============================================ */
    .data : AT(ADDR(.rodata) + SIZEOF(.rodata))
    {
        _sdata = .;
        *(.data .data.*)
        _edata = .;
    } > RAM

    _sidata = LOADADDR(.data);  /* Flash에서의 .data 시작 주소 */

    /* ============================================ */
    /* .bss — 0으로 초기화될 전역 변수 */
    /* ============================================ */
    .bss :
    {
        _sbss = .;
        *(.bss .bss.*)
        _ebss = .;
    } > RAM

    /* 사용하지 않는 섹션 제거 */
    /DISCARD/ :
    {
        *(.ARM.exidx .ARM.exidx.*)
    }
}

/* 진입점 지정 */
ENTRY(Reset)
