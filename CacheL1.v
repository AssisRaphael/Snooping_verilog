module CacheL1(barramento, barramentoMensagem, barramentoDado, barramentoAddr,writeBackEnable ,falador, instrucao, passo, clock);

	input [7:0] barramento;
	input falador,clock;
	input [11:0]instrucao;
	input [1:0] passo;
	reg hit;
	
	output reg [1:0] barramentoMensagem;
	output reg [7:0] barramentoDado;
	output reg [2:0] barramentoAddr;
	output reg writeBackEnable;
	
	parameter read=0;
	parameter write=1;
	
	parameter BarramentoNada=0;
	parameter BarramentoWriteMiss=1;
	parameter BarramentoReadMiss=2;
	parameter BarramentoInvalidate=3;
	
	parameter EstadoInvalidate = 0;
	parameter EstadoCompartilhado = 1;
	parameter EstadoModificado = 2;

	reg [7:0]bloco0,bloco1;
	reg [1:0]tag0,tag1;
	reg [1:0]estadoB0,estadoB1;
	
	initial begin
		estadoB0 = EstadoInvalidate;
		estadoB1 = EstadoInvalidate;
	end
	
	always@(posedge clock)begin
		writeBackEnable = 0;
		case(passo)
			0:begin
				if(falador)begin//processador
					if(instrucao[9] == 0)begin//indice 0
						if(tag0 == instrucao[11:10])//Se dado estiver na cache
							hit =1;
						else
							hit = 0;
					end
					else begin //indice 1
						if(tag1 == instrucao[11:10])//Se dado estiver na cache
							hit =1;
						else
							hit = 0;
					end
					if(hit && (instrucao[8]==0))begin//Read-Hit
						barramentoMensagem = BarramentoNada;
					end
					else if(hit && (instrucao[8]==1))begin//Write-Hit
						barramentoMensagem = BarramentoInvalidate;
						barramentoAddr = instrucao[11:9];
					end
					else if(!hit && (instrucao[8]==0))begin//Read-Miss
						barramentoMensagem = BarramentoReadMiss;
						barramentoAddr = instrucao[11:9];
					end
					else if(!hit && (instrucao[8]==0))begin//Write-Miss
						barramentoMensagem = BarramentoWriteMiss;
						barramentoAddr = instrucao[11:9];
					end
				end
			end
			1:begin
				if(!falador)begin//Barramento
					if(barramentoMensagem == BarramentoInvalidate) begin//Invalidate
						if((tag0 == barramentoAddr[2:1]) && (barramentoAddr[0] == 0))begin//invalidate bloco 0
							barramentoMensagem = BarramentoNada;
							estadoB0 = EstadoInvalidate;
						end
						else if((tag1 == barramentoAddr[2:1]) && (barramentoAddr[0] == 1))begin//invalidate bloco 1
							barramentoMensagem = BarramentoNada;
							estadoB1 = EstadoInvalidate;
						end
					end
					else if(barramentoMensagem == BarramentoReadMiss) begin//ReadMiss
						if((tag0 == barramentoAddr[2:1]) && (barramentoAddr[0] == 0) && (estadoB0 == EstadoModificado))begin//ReadMiss bloco 0
							barramentoMensagem = BarramentoReadMiss;
							estadoB0 = EstadoCompartilhado;
							barramentoDado = bloco0;
							writeBackEnable = 1;
						end
						else if((tag1 == barramentoAddr[2:1]) && (barramentoAddr[0] == 1) && (estadoB0 == EstadoModificado))begin//ReadMiss bloco 1
							barramentoMensagem = BarramentoReadMiss;
							estadoB1 = EstadoCompartilhado;
							barramentoDado = bloco1;
							writeBackEnable = 1;
						end
					end
					else if(barramentoMensagem == BarramentoWriteMiss) begin//WriteMiss
						if((tag0 == barramentoAddr[2:1]) && (barramentoAddr[0] == 0) && (estadoB0 == EstadoModificado))begin//WriteMiss bloco 0
							barramentoMensagem = BarramentoWriteMiss;
							estadoB0 = EstadoInvalidate;
							barramentoDado = bloco0;
							writeBackEnable = 1;
						end
						else if((tag1 == barramentoAddr[2:1]) && (barramentoAddr[0] == 1) && (estadoB0 == EstadoModificado))begin//WriteMiss bloco 1
							barramentoMensagem = BarramentoWriteMiss;
							estadoB1 = EstadoInvalidate;
							barramentoDado = bloco1;
							writeBackEnable = 1;
						end
						else if((tag0 == barramentoAddr[2:1]) && (barramentoAddr[0] == 0) && (estadoB0 == EstadoCompartilhado))begin//WriteMiss bloco 0
							barramentoMensagem = BarramentoWriteMiss;
							estadoB0 = EstadoInvalidate;
						end
						else if((tag1 == barramentoAddr[2:1]) && (barramentoAddr[0] == 1) && (estadoB0 == EstadoCompartilhado))begin//WriteMiss bloco 1
							barramentoMensagem = BarramentoWriteMiss;
							estadoB1 = EstadoInvalidate;
						end
					end			
				end
			end
			2:begin
				if(falador && (barramentoMensagem == BarramentoWriteMiss)) begin//Processador
					if(barramentoAddr[0] == 0) begin
						tag0 = instrucao[11:10];
						bloco0 = instrucao[7:0];
						estadoB0 = EstadoModificado;
						barramentoMensagem = BarramentoNada;
					end
					else if(barramentoAddr[0] == 1) begin
						tag1 = instrucao[11:10];
						bloco1 = instrucao[7:0];
						estadoB1 = EstadoModificado;
						barramentoMensagem = BarramentoNada;
					end
				end
			end
			3:begin
				if(falador)begin
					if(barramentoAddr[0] == 0) begin
						tag0 = instrucao[11:10];
						bloco0 = barramento;
						estadoB0 = EstadoCompartilhado;
						barramentoMensagem = BarramentoNada;
					end
					else if(barramentoAddr[0] == 1) begin
						tag1 = instrucao[11:10];
						bloco1 = barramento;
						estadoB1 = EstadoCompartilhado;
						barramentoMensagem = BarramentoNada;
					end
				end
			end
		endcase
	end

endmodule
