# Visual 2A03 Signal Mapping

Visual 2A03: http://www.qmtpro.com/~nes/chipimages/visual2a03/

|Breaks signal name|Visual 2A03 signal name|
|---|---|
|External terminals||
|CLK|node: 11669 clk_in|
|/NMI|node: 10331 nmi|
|/IRQ|node: 10488 irq|
|/RES|node: 10004 res|
|DBG|node: 11214 dbg|
|/IN0|node: 10006 joy1|
|/IN1|node: 10029 joy2|
|OUT0|node: 10007 out0|
|OUT1|node: 10008 out1|
|OUT2|node: 10005 out2|
|M2|node: 10743 phi2|
|R/W|node: 10092 rw|
|D0-7|db0-7|
|A0-15|ab0-15|
|Internal signals||
|/CLK|node: 11267|
|PHI0|node: 11235 clk0|
|PHI1|node: 10357 clk1out|
|PHI2|node: 10843 clk2out|
|RDY|node: 10758 rdy|
|RDY2| |
|ACLK|node: 10533 apu_/clk2|
|/ACLK|node: 11434 apu_clk1|
|RES|node: 10057 _res|
|/M2|node: 11200|
|/NMI|node: 10458 _nmi|
|/IRQ|node: 10701 _irq|
|INT|node: 10775 irq_internal|
|/LFO1|node: 10293 frm_quarter|
|/LFO2|node: 10563 frm_half|
|R/W (Core)|node: 10756 __rw|
|SPR/CPU|node: 11099 ab_use_spr_r|
|SPR/PPU|node: 10764 ab_use_spr_w|
|RW (DMABuf)|node: 10844 _rw|
|RD|node: 11133 rw_buf|
|WR|node: 10938 dbe|
|#DMC/AB|node: 11411 /ab_use_pcm|
|RUNDMC|node: 11515|
|DMCINT|node: 10753 pcm_irq_out|
|DMCRDY|node: 11483 pcm_dma_/rdy|
|/R4015|node: 10749 /r4015|
|/R4016|node: 13474 /r4016|
|/R4017|node: 13444 /r4017|
|/R4018|node: 10527 /r4018|
|/R4019|node: 10759 /r4019|
|/R401A|node: 10763 /r401a|
|W4000|node: 13322 w4000|
|W4001|node: 10559 w4001|
|W4002|node: 10134 w4002|
|W4003|node: 13264 w4003|
|W4004|node: 13290 w4004|
|W4005|node: 10580 w4005|
|W4006|node: 10133 w4006|
|W4007|node: 13273 w4007|
|W4008|node: 13348 w4008|
|W400A|node: 13371 w400a|
|W400B|node: 13398 w400b|
|W400C|node: 13300 w400c|
|W400E|node: 13436 w400e|
|W400F|node: 13415 w400f|
|W4010|node: 13514 w4010|
|W4011|node: 13375 w4011|
|W4012|node: 13491 w4012|
|W4013|node: 13457 w4013|
|W4014|node: 13542 w4014|
|W4015|node: 13356 w4015|
|W4016|node: 10174 w4016|
|W4017|node: 13520 w4017|
|W401A|node: 10773 w401a|
|SQA/LC|node: 11748 sq0_len_reload|
|SQB/LC|node: 11752 sq1_len_reload|
|TRI/LC|node: 11750 tri_len_reload|
|RND/LC|node: 11747 noi_len_reload|
|NOSQA|node: 10524 sq0_silence|
|NOSQB|node: 10522 sq1_silence|
|NOTRI|node: 11346 tri_silence|
|NORND|node: 11696 noi_silence|
|DBG|node: 10946 dbg_en|
|/DBGRD|node: 10839|
|LOCK|node: 10658 snd_halt|
|SQA0-3|sq0_out0-3|
|SQB0-3|sq1_out0-3|
|TRI0-3|tri_out0-3|
|RND0-3|noi_out0-3|
|DMC0-6|pcm_out0-6|
|Internal buses||
|DB|_db0-7|
|DMC_Addr|pcm_+a0-15|
|SPR_Addr|spr_a0-15|
|CPU_Addr|__ab0-15|
|A0-15|_ab0-15|
