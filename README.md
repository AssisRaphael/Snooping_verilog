# Snooping verilog
Este repositórios contém um processador de três núcleos que implementa protocolo Snooping.

Com o desenvolvimento dos microprocessadores o uso de vários núcleos se tornou comum e com isso surgiu a necessidade de melhorar o sistema de coerência entre as caches. Nessa prática desenvolvemos um processador de três núcleos que implementa protocolo Snooping. O processador acompanha três caches L1 de dois blocos de 8 bits e uma memória principal de 8 blocos.

O módulo principal implementa o processador de três núcleos que utiliza o protocolo Snooping nas caches L1. Assim, possui três instâncias do módulo CachesL1 e cada uma dessas possui 2 blocos de 8 bits. O módulo principal lê uma instrução de um núcleo do processador a cada ciclo de clock e executa a instrução em dois passos. O primeiro passo verifica a mudança de estado do bloco solicitado e faz o tratamento necessário da mensagem transmitida pelo barramento e o segundo passo acessa a memória para receber dados e fazer write-back. O diagrama do processador é ilustrado na figura.

![Snooping schema](https://www.researchgate.net/profile/Mark_Heinrich/publication/34676373/figure/fig3/AS:669425770430483@1536614949653/The-cache-coherence-problem-Initially-processors-0-and-1-both-read-location-x.png)

Os dados de entrada para o programa são a instrução enviada pelo processador, o núcleo solicitante e o clock. A instrução possui 12 bits em que os 3 bits mais significativos são o endereço acessado, o oitavo bit informa a instrução e os 8 bits menos significativos contêm o dado da instrução. 

O barramento foi dividido em três seções, uma que envia somente dados, uma que envia somente o endereço e outra que envia somente a mensagem. 

| Dado | Instrução | Núcleo | Estado        | Mensagem    |
|------|-----------|--------|---------------|-------------|
| 0    | Read      | P1     | Invalidate    | Nada        |
| 1    | Write     | P2     | Compartilhado | Write\-Miss |
| 2    | \-        | P3     | Modificado    | Read\-Miss  |
| 3    | \-        | \-     | \-            | Invalidate  |


