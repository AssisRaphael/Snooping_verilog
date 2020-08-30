module Snooping(comandoProcessador, selecaoProcessador, clock);
	input [11:0] comandoProcessador;//[11:9]endereco, [8]leitura ou escrita, [7:0]dado 
	input [2:0] selecaoProcessador;
	
	input clock;
	wire writeBackEnable;
	
	reg [7:0] barramento;
	reg [1:0] passo;
	wire [1:0] barramentoMensagem1,barramentoMensagem2,barramentoMensagem3;
	wire [7:0] barramentoDado;
	wire [2:0] barramentoAddr;
	
	reg[7:0] memoria[7:0];
	
	parameter BarramentoNada=0;
	parameter BarramentoWriteMiss=1;
	parameter BarramentoReadMiss=2;
	parameter BarramentoInvalidate=3;
	
	
	
	always@(posedge clock)begin
		if((barramentoMensagem1 == BarramentoNada)&&(selecaoProcessador == 1))begin
			passo = 0;
		end
		if((barramentoMensagem2 == BarramentoNada)&&(selecaoProcessador == 2))begin
			passo = 0;
		end
		if((barramentoMensagem3 == BarramentoNada)&&(selecaoProcessador == 3))begin
			passo = 0;
		end
		if((passo == 2) && writeBackEnable)begin
			memoria[barramentoAddr] = barramentoDado;
			barramento = memoria[comandoProcessador[11:9]];
		end
		passo = passo + 1;
	end
	
	
	CacheL1 c1(barramento, barramentoMensagem1, barramentoDado, barramentoAddr, writeBackEnable,(selecaoProcessador == 1),comandoProcessador,passo,clock);
	CacheL1 c2(barramento, barramentoMensagem2, barramentoDado, barramentoAddr, writeBackEnable,(selecaoProcessador == 2),comandoProcessador,passo,clock);
	CacheL1 c3(barramento, barramentoMensagem3, barramentoDado, barramentoAddr, writeBackEnable,(selecaoProcessador == 3),comandoProcessador,passo,clock);
	
	
	
endmodule