#INCLUDE "OGX016.CH"
#INCLUDE "protheus.CH"
#INCLUDE "fwmvcdef.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#DEFINE _CRLF CHR(13)+CHR(10)

//lista os farfdos para calcular e dar preço 
function OGX016(cFilCtr, cCodCtr, aLstBlc, nPrecoBase, cCodClient, cCodLoja)
	Local aBlocos := {}
	Local nA      := 1
	Local nB      := 1 
	
	Default aLstBlc    := {}
	Default nPrecoBase := 0     
	Default cCodClient := ""
	Default cCodLoja   := ""
	
	//executa o processo de ágio e deságio	
	aBlocos := OGX016CALC(cFilCtr, cCodCtr, ,aLstBlc, nPrecoBase , cCodClient, cCodLoja, .f. )
	
    DXI->(DbSetOrder(1))
    DXI->(DbGoTop())

    if valtype(aBlocos) == "A" //se trata de um array
		//retorna os valores para a dxi.
		for nA := 1 to len(aBlocos)
		 	//lista de blocos 
		 	for nB := 1 to len(aBlocos[nA][1])
		 		if DXI->(DbSeek(aBlocos[nA][1][nB][1]+aBlocos[nA][1][nB][2]+aBlocos[nA][1][nB][3])) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ                                                                                                                                   
		 			Reclock("DXI", .F.)
		 				DXI->DXI_VLBASE := aBlocos[nA][1][nB][10] //valor usado no cálculo
		 				DXI->DXI_VADFOL := aBlocos[nA][1][nB][9][1] //AD Folha
		 				DXI->DXI_VADCOR := aBlocos[nA][1][nB][9][2] //AD Cor
		 				DXI->DXI_VADHVI := aBlocos[nA][1][nB][9][3] //AD HVI
		 				DXI->DXI_VADOUT := aBlocos[nA][1][nB][9][4] //AD Outros 
		 				DXI->DXI_VADTOT := aBlocos[nA][1][nB][7] // agio/deságio total
		 				DXI->DXI_VLCAGD := aBlocos[nA][1][nB][10] + aBlocos[nA][1][nB][7] // agio/deságio total
		 				DXI->DXI_EXTCAL := aBlocos[nA][1][nB][8] + _CRLF + "Cálculo executado em " + dtos(dDatabase) + " - " + Time()
		 				DXI->DXI_TIPPRE := aBlocos[nA][1][nB][11]  //tipo de valor usado -  Fixo, valor base, indice.
		 			DXI->(MsUnlock())     // Destrava o registro		
		 		endif
		 		
		 	next nB
		next nA
	endif
return .t.

/** {Protheus.doc} OGX016CALC
Executa o cálculo de ágio e deságio de um ou mais blocos e fardos com base nos parâmetros do contrato
@param:     cFilCtr   char(2) Filial do contrato
            cContrato char(6) Número do contrato
            cReserva  char(6) código da reserva            
            cBloco    char(6) código do bloco
            aCtr      array - Dados do contrato <- OGX016CTR
            lExibeLog Boolean - Indica se o log do processamento deve ser exibido ao final do bloco
@return:    Numero - valor do ágio/deságio calculado para o bloco
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGC040 - Consulta de Blocos/Fardos
*/
Function OGX016CALC(cFilCtr, cContrato, cReserva, aLstBlc, nPrecoBase, cCodClient, cCodLoja, lExibeLog )
   Local aDadosCtr   := {}
   Local aBlocos     := {}
   Local nR          := 0
   Local cMsg        := ""
   Local cHist       := ""
   Local nValorBase  := 0 
   
   
   Default lExibeLog  := .F.
   Default cFilCtr    := xFilial("NJR") //se não informado a filial é conforme leitura normal
   Default aLstBlc    := {}
   Default nPrecoBase := 0
   Default cCodClient := "" 
   Default cCodLoja   := ""
   
   /*Busca os dados do contrato*/
   aDadosCtr := OGX016CTR(cFilCTR, cContrato)
   
   If Empty(aDadosCtr)
      cMsg := STR0017    //Não foi encontrado dados de reserva
	  Return cMsg
   endif
   
   //verifica se foi passado o cliente - loja- Indice de preco por Tabela
   if empty(cCodClient) .and. empty(cCodLoja)
	   DbSelectArea("NJ0")
	   NJ0->(DbSetOrder(1))
	   If NJ0->(DbSeek(xFilial("NJ0")+aDadosCtr[1][6]+aDadosCtr[1][7]))
			if NJR->NJR_TIPO == "1" //Compras - fornecedor
				cCodClient     := NJ0->NJ0_CODFOR
				cCodLoja       := NJ0->NJ0_LOJFOR				
			else //vendas - cliente
				cCodClient     := NJ0->NJ0_CODCLI
				cCodLoja       := NJ0->NJ0_LOJCLI				
			endif
	   EndIf	
   endif
   
   //verifica qual valor vai ser utilizado - evoluir para que seja possível tbm usar indices
   if nPrecoBase > 0
   		nValorBase := nPrecoBase
   endif 
   
   //retorna os dados da reserva do contrato
   aBlocos := OGX016RES(cFilCtr, cContrato, cReserva, aLstBlc, nValorBase, cCodClient, cCodLoja )

   If Empty(aBlocos)
      cMsg := STR0004    //Não foi encontrado dados de reserva
	  Return cMsg
   endif

   /**********************Ágio Deságio Por TIPO************************
   ********************************************************************/

   if aDadosCtr[2][3] $ "2|3|4" //forma de calculo diferente de nenhum

   	   OGX016VTIP(aDadosCtr, @aBlocos) //função que calcula por tipo

   endif

   /**********************Ágio Deságio Por HVI************************
   ********************************************************************/

   if aDadosCtr[3][3] $ "2|3|4" //forma de calculo diferente de nenhum

   	   OGX016VHVI(aDadosCtr, @aBlocos) //função que calcula por HVI

   endif


   /**********************Ágio Deságio Outros************************
   ********************************************************************/

   if aDadosCtr[4][3] $ "2|3|4" //forma de calculo diferente de nenhum

   	  OGX016VOUT(aDadosCtr, @aBlocos) //função que calcula por outros

   endif

	//log de processamento
	If lExibeLog .AND. !IsInCallStack("OGC040")
	   //monta a variavel de histórico
	   cHist := STR0005 + aDadosCtr[1][5] + _CRLF   //"SIMULAÇÃO DO CONTRATO NR."
	   cHist += STR0006 + aDadosCtr[1][6] + '/' + aDadosCtr[1][7] +_CRLF  //"Cliente/Loja:"

	   For nR := 1 to Len(aBlocos)

	   		cHist += "........................................" + _CRLF
			cHist += STR0014 + aBlocos[nR][2] + _CRLF        //"BLOCO: "
			cHist += STR0021 + ": " + alltrim(str(aBlocos[nR][5])) + _CRLF //"Peso líquido: "
			cHist += STR0022 + ": " + alltrim(str(len(aBlocos[nR][1]))) + _CRLF //"Qtd. Fardos: "
			cHist += STR0015 + alltrim(Str(aBlocos[nR][6])) + _CRLF  + _CRLF     //"Resultado :"
			cHist += STR0023 + ": " + _CRLF + _CRLF  + aBlocos[nR][7]                //"Mensagem:"

	   next nR

	   AutoGrLog(cHist)
	   MostraErro()
	EndIF
Return aBlocos

/*{Protheus.doc} OGX016VTIP
Validação e Cálculo de Ágio e Deságio por Tipo/Folha/Cor
@author jean.schulze
@since 10/08/2017
@version undefined
@param aDadosCtr, array, descricao
@param aBlocos, array, descricao
@type function
*/

Function OGX016VTIP(aDadosCtr, aBlocos)
  Local nR          := 0
  Local nI          := 0
  Local nX          := 0
  Local aTFC        := {}
  Local nTipoFardo  := 0
  Local cAliasDX7   := ""
  Local cSqlDX7     := ""
  Local cMsg        := ""
  Local aOper       := {}
  Local nY          := 0

    aAdd(aOper,{'==', '='})//Igual a
    aAdd(aOper,{'.AND.','AND'})// E
	aAdd(aOper,{'.OR.','OR'})// OU

  aTFC     := aClone(aDadosCtr[2][1])  //Dados de TIPO por Folha/Cor

  For nR := 1 to Len(aBlocos)

	  cMsg := nil

      If aBlocos[nR][4] == aDadosCtr[1][4] //tipo padrao do contrato
         cMsg := STR0011  // "Fardo é do tipo padrão do contrato"
         lAplicAgi := .F.
      Else
	      //Agora deve comparar na matriz de dados de Tipo/folha/Cor do contrato
	      lAplicAgi := .F.
	      nTipoFardo := 0

	      For nI := 1 to Len(aTFC)  //Executa cada uma das linhas de Agio/Desagio por TIPO Folha/Cor do contrato

	         //Verifica se a Classificação comercial do fardo existe no contrato
	         If aBlocos[nR][4] /*class com.*/ $ aTFC[nI][1] /*tipos opcionais do contrato*/

	            lAplicAgi  := .T.
	            nTipoFardo := nI

	            //regras hvi para aplicação do ágio e deságio
	            If !Empty(aTFC[nI][2])

	               For nX := 1 to Len(aBlocos[nR][1]) //a lista de fardos do bloco

		               cSqlDX7 := "SELECT DISTINCT 'S' RES " + ;
		                            "FROM " + RetSqlName("DX7") + " DX7 " +;
		                            "WHERE DX7_FILIAL = '" + aBlocos[nR][1][nX][1] + "' " +;
		                            "AND DX7_SAFRA = '" + aBlocos[nR][1][nX][2] + "' " + ;
		                            "AND DX7_ETIQ = '" + aBlocos[nR][1][nX][3] + "' " +;   //000220592   1E000009'
		                            "AND DX7_ATIVO = '1' "

		               if !empty(aTFC[nI][2])
			                For nY :=  1 to Len(aOper)// Realiza o tratamento de replace nas operações da regra
		                      aTFC[nI][2][1][1]  := StrTran(aTFC[nI][2][1][1] ,aOper[nY][1],aOper[nY][2] ,, )
		                    Next nY
		               		cSqlDX7 += "AND ( " + aTFC[nI][2][1][1] + " )"
		               endif

		               cAliasDX7 := GetSqlAll(cSqlDX7)
		               If !(cAliasDX7)->(Eof()) .AND. (cAliasDX7)->RES == "S"
			              cMsg := STR0010 + _CRLF  // "O Fardo atende os requisitos de HVI"
			           Else
			              lAplicAgi := .F.
			              cMsg := STR0001 + _CRLF
			              Exit
			           EndIF

		           next nX

	            Else
	                //LOG não existe regra HVI para validação
	                cMsg := STR0002  //"Regra HVI não definida para esta Classificação Comercial"
	            EndIf

	         Else
		        Loop
	         EndIF

	         If !lAplicAgi
	            Exit
	         EndIf

	      Next nI

	  EndIf
	  	  
	  //existe ágio e deságio
	  If lAplicAgi

	    //apropria os valores
		OGX016CALT(aDadosCtr[1], aDadosCtr[2], @aBlocos[nR], nTipoFardo, cMsg )
		
	  else //tratamento de excessão
	  	
	  	if empty(cMsg)
	  		cMsg := STR0024 + " " + STR0025 + ": " + aBlocos[nR][4] //O Tipo do bloco não possui dados para Ágio Deságio. /Tipo do Bloco:
	  	endif
	  	
	  	//adiciona mensagem para os fardos
	  	aBlocos[nR][7] := STR0036 + _CRLF + cMsg + _CRLF + _CRLF  //Adiciona Mensagem de Observação no Array aReserva
	  	
	  	//trata a listagem dos fardos - tratamento para ser gravado na DXI
   	  	For nX := 1 to Len(aBlocos[nR][1])
   	  	 	//mensagem
   	  	 	ablocos[nR][1][nX][8]  := aBlocos[nR][7] 
   	  	next nX
	  	
	  Endif

   Next nR

return .t.

/*{Protheus.doc} OGX016VHVI
Função que valida o uso do ágio deságio por HVI
@author jean.schulze
@since 14/08/2017
@version undefined
@param aDadosCtr, array, descricao
@param aBlocos, array, descricao
@type function
*/
Function OGX016VHVI(aDadosCtr, aBlocos)
   Local nX         := 0
   Local nI         := 0
   Local nC         := 0
   Local aRegHVI    := aClone(aDadosCtr[3][1]) //lista de regras HVI
   Local aHviFar    := {}
   Local aMediaHvi  := {}
   Local cRegra     := ""
   Local cMesagem   := ""
   Local nVlrConsl  := 0
   Local nValorAgio := 0
   Local nPos       := 0
   Local nCount		:= 0 				// Contador de fardos que entraram na regra hvi ( percentual fardo a fardo)
   Local nPercen	:= aDadosCtr[3][7] 	// Percentual HVI de Tolrância
   Local nPerCount	:= 0				// Percentual de fardos que atingiram a regra em questão
   Local nQtdTotal  := 0 	 
   Local nMediaVlr  := 0	
   Local aMsgSucess := {}	   	 
		   	   

   if aDadosCtr[3][6] == "1" //regra por Média do bloco

   	   for nX := 1 to len(aBlocos)

   	   	   cMesagem  := ""
   	   	   nVlrConsl := 0

	   	   //busca os dados de hvi do bloco
	   	   aHviFar := OGX016DX7(aBlocos[nX][1])

	   	   //resolve a média do bloco
	   	   for nI := 1 to len(aHviFar)

	   	   	 	if len(aMediaHvi) > 0

	   	   	 		for nC := 1 to len(aHviFar[nI][2])
	   	   	 			aMediaHvi[nC][2] += aHviFar[nI][2][nC][2] //soma os valores
	   	   	 		next nC

	   	   	 	else //primeira passagem, criamos o array com a estrutura
	   	   	 		aMediaHvi := aClone(aHviFar[nI][2])
	   	   	 	endif

	   	   next nI

	   	   //dividir media pela qtd de fardo
	   	   for nI := 1 to len(aMediaHvi)
	   	   		aMediaHvi[nI][2] :=  aMediaHvi[nI][2] / len(aBlocos[nX][1])
	   	   next nI

	   	   if len(aMediaHvi) > 0 //se tem dados de HVI

	   	   	   //confronta as regras
	   	   	   For nI := 1 to Len(aRegHVI)

	   	   	   	   //verifica se o tipo está listado, ou é empty
	   	   	   	   if empty(aRegHVI[nI][2]) .or. (aBlocos[nX][4] $ aRegHVI[nI][2])
	   	   	   	   	  //replace dos campos da regra pelos dados do array
	   	   	   	   	  cRegra := OGX016RPLC(aRegHVI[nI][1], aMediaHvi)
	   	   	   	   	  // verifica se a regra está atendida
	   	   	   	   	  if (&(alltrim(cRegra)))

	   	   	   	   	  	//consolida o valor do bloco
			   	    	nVlrConsl  += aRegHVI[nI][3]
			   	    		
			   	    	aAdd(aMsgSucess, {aRegHVI[nI][3], aRegHVI[nI][4] })
						
	   	   	   	   	  else
	   	   	   	   	  	//Não vamos aplicar
	   	   	   	   	  	cMesagem += STR0031 + "'" + alltrim(aRegHVI[nI][4]) + "'" + STR0032 + _CRLF //" não foi contemplada para a média de HVI do Bloco"
	   	   	   	   	  endif
	   	   	   	   else
	   	   	   	   	  //crava erros
	   	   	   	   	  cMesagem += STR0029 + alltrim(aRegHVI[nI][4]) + _CRLF //o tipo do bloco é incompatível com a regra
 	   	   	   	   endif

		   	   next nI
		   else
		   	  //crava erros
	   	   	  cMesagem += STR0030 + _CRLF  //o fardo não possui exame hvi
	   	   endif

		   //informa a mensagem
		   aBlocos[nX][7] += STR0037 + _CRLF 

	   	   //apropria os valores e trata mensagens
	   	   if aDadosCtr[3][3] == "3" //Percentual - não muda o ágio e deságio em virtude do valor do fardo
	   	   	  	
	   	   	   //reset	
	   	   	   nQtdTotal := 0 	 
			   nMediaVlr := 0		   	 
		   	   
		   	   //trata a listagem dos fardos - tratamento para ser gravado na DXI
			   For nI := 1 to Len(aBlocos[nX][1])
	
			   	  	 //valor por hvi
			   	  	 ablocos[nX][1][nI][9][3] := OGX016CALH(aDadosCtr[1], aDadosCtr[3], nVlrConsl, ablocos[nX][1][nI][10] ) 
			   	  	 
			   	  	 //mensagem
			   	  	 ablocos[nX][1][nI][8]    += STR0037 + _CRLF 
			   	  	 
			   	  	 for nC := 1 to len(aMsgSucess)
			   	  	 	ablocos[nX][1][nI][8] += iif(aMsgSucess[nC][1] < 0, STR0018,  STR0019) + STR0033 + "'" + alltrim(aMsgSucess[nC][2]) + "'" + " : "+ alltrim(Str(OGX016CALH(aDadosCtr[1], aDadosCtr[3], aMsgSucess[nC][1], ablocos[nX][1][nI][10] ))) + "."  + _CRLF
					 next nC	
					 
					 ablocos[nX][1][nI][8]    += cMesagem + _CRLF
			   	  	 
			   	  	 //valor total - soma as 4 formas de ágio e deságio
			   	  	 ablocos[nX][1][nI][7]    := ablocos[nX][1][nI][9][1] + ablocos[nX][1][nI][9][2] + ablocos[nX][1][nI][9][3] + ablocos[nX][1][nI][9][4]
			   	  	 
			   	  	 nQtdTotal += ablocos[nX][1][nI][6] //peso	 
			   	  	 nMediaVlr += ablocos[nX][1][nI][6] *  ablocos[nX][1][nI][10]
			   	  	 
			   next nI
			  			 	
	   	       //informa o valor somente por hvi
	   	       aBlocos[nX][8][3] += OGX016CALH(aDadosCtr[1], aDadosCtr[3], nVlrConsl,  nMediaVlr / nQtdTotal ) 
	   	       
	   	       //consolida o valor do bloco
	   	       aBlocos[nX][6]  += aBlocos[nX][8][3]
	   	       
	   	       //tratamento de mensagens
	   	       for nC := 1 to len(aMsgSucess)
			   	   aBlocos[nX][7] += iif(aMsgSucess[nC][1] < 0, STR0018,  STR0019) + STR0033 + "'" + alltrim(aMsgSucess[nC][2]) + "'" + " : "+ alltrim(Str(OGX016CALH(aDadosCtr[1], aDadosCtr[3], aMsgSucess[nC][1], nMediaVlr / nQtdTotal ))) + "."  + _CRLF
			   next nC
					 
	   	       aBlocos[nX][7] += cMesagem + _CRLF
	   	       	
		   else //demais formas de cálculo
		   	   
		   	   //informa o valor somente por hvi
	   	       aBlocos[nX][8][3] += OGX016CALH(aDadosCtr[1], aDadosCtr[3], nVlrConsl)
		   	   
		   	   //consolida o valor do bloco
	   	       aBlocos[nX][6] += aBlocos[nX][8][3]
	   	       
	   	       //trata as mensagens
	   	       for nC := 1 to len(aMsgSucess)
			   	   cMesagem += iif(aMsgSucess[nC][1] < 0, STR0018,  STR0019) + STR0033 + "'" + alltrim(aMsgSucess[nC][2]) + "'" + " : "+ alltrim(Str(OGX016CALH(aDadosCtr[1], aDadosCtr[3], aMsgSucess[nC][1] ))) + "."  + _CRLF
			   next nC
					 
	   	       aBlocos[nX][7] += cMesagem + _CRLF
	   	       		   	   
		   	   //trata a listagem dos fardos - tratamento para ser gravado na DXI
			   For nI := 1 to Len(aBlocos[nX][1])
	
			   	  	 //valor por hvi
			   	  	 ablocos[nX][1][nI][9][3] := aBlocos[nX][8][3]
			   	  	 //mensagem
			   	  	 ablocos[nX][1][nI][8]    += STR0037 + _CRLF + cMesagem + _CRLF
			   	  	 //valor total - soma as 4 formas de ágio e deságio
			   	  	 ablocos[nX][1][nI][7]    := ablocos[nX][1][nI][9][1] + ablocos[nX][1][nI][9][2] + ablocos[nX][1][nI][9][3] + ablocos[nX][1][nI][9][4]
	
			   next nI
		   endif

   	   next nX
   elseif aDadosCtr[3][6] == "2" //regra por Fardo a Fardo

   	   for nX := 1 to len(aBlocos)

   	   	   cMesagem  := ""
   	   	   nVlrConsl := 0

	   	   //busca os dados de hvi do bloco
	   	   aHviFar := OGX016DX7(aBlocos[nX][1])


   	   	   aBlocos[nX][7] += STR0038 + _CRLF


	   	   if len(aHviFar) > 0 //tem dados de hvi

	   	   	   	For nI := 1 to Len(aRegHVI)

	   	   	   	   //verifica se o tipo está listado, ou é empty
	   	   	   	   if empty(aRegHVI[nI][2]) .or. (aBlocos[nX][4] $ aRegHVI[nI][2])

	   	   	   	   	   nVlrConsl := 0 //reset para média ponderada
	   	   	   	   	   nPesConsl := 0 //reset peso

	   	   	   	   	   //verifica todos os fardos do bloco
	   	   	   	   	   For nC := 1 to Len(aBlocos[nX][1])

	   	   	   	   	   	   if nI == 1 //first pass
	   	   	   	   	   	   		aBlocos[nX][1][nC][8] += STR0038 + _CRLF
	   	   	   	   	   	   endif 

	   	   	   	   	   	   //encontra o posicionamento do fardo no HVI
	   	   	   	   	   	   if (nPos := aScan(aHviFar,{|x| allTrim(x[1]) == alltrim(aBlocos[nX][1][nC][1]+aBlocos[nX][1][nC][2]+aBlocos[nX][1][nC][3]) })) > 0

	   	   	   	   	   	   		//edita a regra
	   	   	   	   	   	   		cRegra := OGX016RPLC(aRegHVI[nI][1], aHviFar[nPos][2] /*dados HVI do fardo*/)

			   	   	   	     	// verifica se a regra está atendida
				   	   	   	   	if (&(alltrim(cRegra)))

					   	   	   	   	//executa o ágio e deságio
					   	   	   	   	nValorAgio := OGX016CALH(aDadosCtr[1], aDadosCtr[3], aRegHVI[nI][3], aBlocos[nX][1][nC][10])

							   	  	//informa a mensagem
									aBlocos[nX][1][nC][8] += iif(nValorAgio < 0, STR0018,  STR0019) + STR0033 + "'" + alltrim(aRegHVI[nI][4]) + "'" + " : " + alltrim(Str(nValorAgio)) + "."  + _CRLF

							   	    //imput de valor total
							   	    aBlocos[nX][1][nC][7]  += nValorAgio

							   	    //valor por hvi
							   	    ablocos[nX][1][nC][9][3] += nValorAgio

							   	    //consolida o valor do bloco
							   	    nVlrConsl += A410Arred(nValorAgio * aBlocos[nX][1][nC][6],'DXI_VADHVI') /*valor * peso*/
								else
									//monta a mensagem de erro que não foi possível aplicar a regra
									aBlocos[nX][1][nC][8] += STR0031 + "'" + alltrim(aRegHVI[nI][4]) + "'" + STR0032 + _CRLF
		   	   	   	   	   	   	endif

	   	   	   	   	   	   else
	   	   	   	   	   	   		//informa que não tem dados hvi
	   	   	   	   	   	   		aBlocos[nX][1][nC][8] += STR0030 + _CRLF
	   	   	   	   	   	   endif

	   	   	   	   	   	   if nI == Len(aRegHVI) //last pass
	   	   	   	   	   	   		aBlocos[nX][1][nC][8] += _CRLF //pula a linha
	   	   	   	   	   	   endif

	   	   	   	   	   	   nPesConsl += aBlocos[nX][1][nC][6] //peso fardo

	   	   	   	   	   next nC

	   	   	   	   	   // lê a média ponderada para coloca no histórico e no valor de ágio e deságio
	   	   	   	   	   if nVlrConsl > 0

		   	   	   	   	   //consolida o valor do bloco
				   	       aBlocos[nX][6]  += A410Arred(nVlrConsl / nPesConsl, 'DXI_VADHVI')

				   	       //informa o valor somente por hvi
				   	       aBlocos[nX][8][3] += A410Arred(nVlrConsl / nPesConsl, 'DXI_VADHVI')

						   //informa a mensagem
						   aBlocos[nX][7] +=  iif(nVlrConsl < 0, STR0018,  STR0019) + STR0033 + "'" + alltrim(aRegHVI[nI][4]) + "'" + " : " + alltrim(Str(A410Arred(nVlrConsl / nPesConsl,'DXI_VADHVI'))) + "."  + _CRLF

						else
						  //monta a mensagem de erro que não foi possível aplicar a regra
						  aBlocos[nX][7]  += STR0031 + "'" + alltrim(aRegHVI[nI][4]) + "'" + STR0032 + _CRLF
						endif

	   	   	   	   else

	   	   	   	      //tipo de bloco incompatível
	   	   	   	   	  aBlocos[nX][7] +=  STR0029 + alltrim(aRegHVI[nI][4]) + _CRLF //o tipo do bloco é incompatível com a regra

	   	   	   	   	  //verifica todos os fardos do bloco
			   	   	  For nC := 1 to Len(aBlocos[nX][1])
			   	   	   		if nI == 1 //first pass
	   	   	   	   	   	   		aBlocos[nX][1][nC][8] += STR0038 + _CRLF
	   	   	   	   	   	    endif

			   	   	   		aBlocos[nX][1][nC][8] += STR0029 + alltrim(aRegHVI[nI][4]) + _CRLF //o tipo do bloco é incompatível com a regra

			   	   	   		if nI == Len(aRegHVI) //last pass
	   	   	   	   	   	   		aBlocos[nX][1][nC][8] += _CRLF //pula a linha
	   	   	   	   	   	    endif

	   	   	   	   	  next nC

 	   	   	   	   endif

	   	   	   	next nI

	   	   else

	   	   	   //informa que não tem dados hvi
	   	   	   aBlocos[nX][7] += STR0030 + _CRLF

	   	   	   //verifica todos os fardos do bloco
	   	   	   For nC := 1 to Len(aBlocos[nX][1])
   	   	   	   	    aBlocos[nX][1][nC][8] += STR0038 + _CRLF + STR0030 + _CRLF + _CRLF
	   	   	   next nC

	   	   endif

	   	   aBlocos[nX][7] += _CRLF //pula a linha

   	    next nX
   elseif aDadosCtr[3][6] == "3" //Regra por Percentual Fardo a Fardo

   		For nX := 1 to Len(aBlocos)

   		   cMesagem  := ""
   	   	   nVlrConsl := 0

	   	   //busca os dados de hvi do bloco
	   	   aHviFar := OGX016DX7(aBlocos[nX][1])
   		   //############## REGRAS HVI DO CONTRATO  ###########
   	   	   For nI := 1 to Len(aRegHVI) // Percorre as regras hvi do contrato

   	   	   		   nPerCount	:= 0 // reset da variavel de percentual de atingimento das regras
   	   	   		   nCount 		:= 0 // reset da variável de contador de fardos que atingiram a regra em questão

	   	   	   	   If Empty(aRegHVI[nI][2]) .OR. (aBlocos[nX][4] $ aRegHVI[nI][2])
	   	   	   	    	//############## QUANTIDADE DE FARDOS DENTRO DA REGRA EM QUESTÃO  ###########
	   	   	   	    	For nC := 1 To Len(aHviFar)

		   	   	   	   	    If &(AllTrim(OGX016RPLC(aRegHVI[nI][1], aHviFar[nC][2])))
		   	   	   	   	    	nCount++
		   	   	   	   	  	EndIf

	   	   	   	   	  	Next nC
	   	   	   	   	  	//###########################################################################

	   	   	   	   	  	If nPercen > 0 // Se o percentual for maior que 0 verifica a possibilidade de aplicação do agio/deságio
					   		If nCount > 0
					   			nPerCount := ( nCount * 100 ) / Len(aBlocos[nX][1])
					   			If nPerCount >= nPercen
					   				//############## APLICAÇÃO DO AGIO/DESAGIO ###########
				   	   	   	   	  	nVlrConsl  += aRegHVI[nI][3] //consolida o valor do bloco
				   	   	   	   	  		
							   	    //informa a mensagem
									aAdd(aMsgSucess, {aRegHVI[nI][3], aRegHVI[nI][4] })
									
									//####################################################
					   			Else
					   				cMesagem += STR0034 + " " + aRegHVI[nI][4] + " / " + Alltrim(str(nPerCount)) + "%." + _CRLF // # "Porcentam de tolerância hvi do bloco não foi atingida para a regra"
					   			EndIf
					   		Else
					   			cMesagem += STR0034 + " " + aRegHVI[nI][4] + " / " + Alltrim(str(nPerCount)) + "%." +  _CRLF // # "Porcentam de tolerância hvi do bloco não foi atingida para a regra"
					   		EndIf
					   	Else
					   		cMesagem += STR0035 + " " + aRegHVI[nI][4] + "." + _CRLF // # "Porcentam de tolerância informado igual a 0, para a regra"
					    EndIf
				   Else
				   		cMesagem += STR0029 + aRegHVI[nI][4] + "." + _CRLF // # "O tipo do bloco é incompatível com a regra: "
 	   	   	   	   EndIf
		   Next nI
		   //###################################################
		   
		   aBlocos[nX][7] += STR0039 + _CRLF
		   
		   //apropria os valores e trata mensagens
	   	   if aDadosCtr[3][3] == "3" //Percentual - não muda o ágio e deságio em virtude do valor do fardo
	   	   	  	
	   	   	   //reset	
	   	   	   nQtdTotal := 0 	 
			   nMediaVlr := 0		   	 
		   	   
		   	   //trata a listagem dos fardos - tratamento para ser gravado na DXI
			   For nI := 1 to Len(aBlocos[nX][1])
	
			   	  	 //valor por hvi
			   	  	 ablocos[nX][1][nI][9][3] := OGX016CALH(aDadosCtr[1], aDadosCtr[3], nVlrConsl, ablocos[nX][1][nI][10] ) 
			   	  	 
			   	  	 //mensagem
			   	  	 ablocos[nX][1][nI][8]    += STR0039 + _CRLF
			   	  	 
			   	  	 for nC := 1 to len(aMsgSucess)
			   	  	 	ablocos[nX][1][nI][8] += Iif(aMsgSucess[nC][1] < 0, STR0018,  STR0019) + " "+ STR0033 + alltrim(aMsgSucess[nC][2]) + " : " + alltrim(Str( OGX016CALH(aDadosCtr[1], aDadosCtr[3], aMsgSucess[nC][1], ablocos[nX][1][nI][10] ) )) + "."  + _CRLF
					 next nC	
					 
					 ablocos[nX][1][nI][8]    += cMesagem + _CRLF
			   	 			   	  	 
			   	  	 //valor total - soma as 4 formas de ágio e deságio
			   	  	 ablocos[nX][1][nI][7]    := ablocos[nX][1][nI][9][1] + ablocos[nX][1][nI][9][2] + ablocos[nX][1][nI][9][3] + ablocos[nX][1][nI][9][4]
			   	  	 
			   	  	 nQtdTotal += ablocos[nX][1][nI][6] //peso	 
			   	  	 nMediaVlr += ablocos[nX][1][nI][6] *  ablocos[nX][1][nI][10]
			   	  	 
			   next nI
			  			 	
	   	       //informa o valor somente por hvi
	   	       aBlocos[nX][8][3] += OGX016CALH(aDadosCtr[1], aDadosCtr[3], nVlrConsl,  nMediaVlr / nQtdTotal ) 
	   	       
	   	       //consolida o valor do bloco
	   	       aBlocos[nX][6]  += aBlocos[nX][8][3]
	   	       
	   	       for nC := 1 to len(aMsgSucess)
			   	   aBlocos[nX][7] += Iif(aMsgSucess[nC][1] < 0, STR0018,  STR0019) + " "+ STR0033 + alltrim(aMsgSucess[nC][2]) + " : " + alltrim(Str( OGX016CALH(aDadosCtr[1], aDadosCtr[3], aMsgSucess[nC][1], nMediaVlr / nQtdTotal ) )) + "."  + _CRLF
			   next nC	
					 
			   aBlocos[nX][7]  += cMesagem + _CRLF
	   	        	
		   else //demais formas de cálculo
		   	   
		   	   //informa o valor somente por hvi
	   	       aBlocos[nX][8][3] += OGX016CALH(aDadosCtr[1], aDadosCtr[3], nVlrConsl)
		   	   
		   	   //consolida o valor do bloco
	   	       aBlocos[nX][6] += aBlocos[nX][8][3]
	   	       	   	          
	   	       //trata as mensagens
	   	       for nC := 1 to len(aMsgSucess)
			   	   cMesagem += Iif(aMsgSucess[nC][1] < 0, STR0018,  STR0019) + " "+ STR0033 + alltrim(aMsgSucess[nC][2]) + " : " + alltrim(Str( OGX016CALH(aDadosCtr[1], aDadosCtr[3], aMsgSucess[nC][1] ) )) + "."  + _CRLF
			   next nC
					 
	   	       aBlocos[nX][7] += cMesagem + _CRLF	   	       		   	   
	   	       		   	   
		   	   //trata a listagem dos fardos - tratamento para ser gravado na DXI
			   For nI := 1 to Len(aBlocos[nX][1])
	
			   	  	 //valor por hvi
			   	  	 ablocos[nX][1][nI][9][3] := aBlocos[nX][8][3]
			   	  	 //mensagem
			   	  	 ablocos[nX][1][nI][8]    += STR0039 + _CRLF + cMesagem + _CRLF
			   	  	 //valor total - soma as 4 formas de ágio e deságio
			   	  	 ablocos[nX][1][nI][7]    := ablocos[nX][1][nI][9][1] + ablocos[nX][1][nI][9][2] + ablocos[nX][1][nI][9][3] + ablocos[nX][1][nI][9][4]
	
			   next nI
		   endif
		 
   		Next nX
   endif

return .t.

/*{Protheus.doc} OGX016VOUT
Validação e Cálculo de Ágio e Deságio por Outros
@author jean.schulze
@since 10/08/2017
@version undefined
@param aDadosCtr, array, descricao
@param aBlocos, array, descricao
@type function
*/
Function OGX016VOUT(aDadosCtr, aBlocos)
	Local nR          := 0
	Local nI          := 0
	Local nX          := 0
	Local cMsg        := ""
	Local nValorAgio  := 0
	Local nValorMed   := 0
	Local nPesoTot    := 0
	Local aAgioOutros := {}
	Local nQtdVinc    := 0
	Local nQtdCtr	  := 0


	aAgioOutros := aClone(aDadosCtr[4][1])  //Dados de outros
    //forma de aplicação??? blocos/fardos/quantidade - hj aplica por bloco

    For nR := 1 to Len(aBlocos)

    	cMsg := ""

    	For nI := 1 to Len(aAgioOutros)

    		//verifica se é vinculado ou não
    		if aAgioOutros[nI][3] == "2" //possui vinculação

    			cMsg := "" //reset

    			nQtdVinc   := OGX016FVIN(aDadosCtr[1][5], aAgioOutros[nI][4] ) //busca a quantidade vinculada
    			nQtdCtr    := aDadosCtr[1][8] / 100 * ( aAgioOutros[nI][5] - ( aAgioOutros[nI][5]  / 100 * aDadosCtr[1][9] )  )  //monta a quantidade minima QTD * % de vinculação + tolerancia

    			//consulta as vinculações e verifica se já foi informado o total ou não
    			if nQtdVinc == 0 //nada foi vinculado
    				cMsg := STR0041 //"O ágio/deságio não possui vinculações de fardo."
    			elseif nQtdVinc < nQtdCtr //existe quantidade a vincular
    				cMsg := STR0042+alltrim(str(nQtdVinc))+STR0043+alltrim(str(nQtdCtr-nQtdVinc)) //"O ágio/deságio ainda possui quantidade à vincular. Qtd Vinculada:"+alltrim(str(nQtdVinc))+", Qtd à vincular:"+alltrim(str(nQtdCtr))
    			endif

    			nPesoTot  := 0 //peso fardo
				nValorMed := 0 //valor médio

    			//trata a listagem dos fardos - tratamento para ser gravado na DXI
			   	For nX := 1 to Len(aBlocos[nR][1])

			   	  	//busca a relação de fardos
	    			DbselectArea( "N87" )
					DbSetOrder( 1 )
					DbGoTop()

					//verifica se o fardpo está na relação
					If dbSeek( xFilial( "N87" )+aDadosCtr[1][5]+"3"+aAgioOutros[nI][4]+ablocos[nR][1][nX][2]+ablocos[nR][1][nX][3] ) //N87_FILIAL+N87_CODCTR+N87_APLICA+N87_SEQUEN+N87_SAFRA+N87_ETIQ

						 //calcula o ágio
						 nValorAgio     := OGX016CALO(aDadosCtr[1], aDadosCtr[4], aAgioOutros[nI][2], ablocos[nR][1][nX][10])

						 //valor por outros
				   	  	 ablocos[nR][1][nX][9][4] += nValorAgio
				   	  	 //mensagem
				   	  	 ablocos[nR][1][nX][8]    += iif(nI == 1, STR0040 + _CRLF, "" )  +  iif(nValorAgio < 0, STR0018,  STR0019) + alltrim(aAgioOutros[nI][1]) + " : " + alltrim(Str(nValorAgio)) + "." + cMsg + _CRLF
				   	  	 //valor total - soma as 4 formas de ágio e deságio
				   	  	 ablocos[nR][1][nX][7]    := ablocos[nR][1][nX][9][1] + ablocos[nR][1][nX][9][2] + ablocos[nR][1][nX][9][3] + ablocos[nR][1][nX][9][4]

				   	  	 //soma para fazer ponderado
				   	  	 nValorMed += ablocos[nR][1][nX][6] * nValorAgio //valor médio

					else
						//mensagem
						ablocos[nR][1][nX][8]    += iif(nI == 1, STR0040 + _CRLF, "" ) + STR0044 + alltrim(aAgioOutros[nI][1]) + "." + cMsg + _CRLF //"Fardo não vinculado para o ágio/deságio: "
					Endif

					nPesoTot  += ablocos[nR][1][nX][6] //peso fardo

			   	next nX

    			nValorAgio := A410Arred( nValorMed / nPesoTot, 'DXI_VADHVI')

    			//consolida o valor do bloco
	   	    	aBlocos[nR][6]    += nValorAgio

	   	    	//informa o valor somente por outros
	   	    	aBlocos[nR][8][4] += nValorAgio

    			//apropria a mensagem
				aBlocos[nR][7] += iif(nI == 1, STR0040 + _CRLF, "" )  +  iif(nValorMed / nPesoTot < 0, STR0018,  STR0019) + alltrim(aAgioOutros[nI][1]) + " : " + alltrim(Str(nValorAgio)) + "." + cMsg + _CRLF


    		else //não tem vinculação
    			
    		   	
    		   //apropria os valores e trata mensagens
		   	   if aDadosCtr[4][3] == "3" //Percentual - muda o ágio e deságio em virtude do valor do fardo
		   	   	  	
		   	   	   //reset	
		   	   	   nQtdTotal := 0 	 
				   nMediaVlr := 0	
				   				   
				   //trata a listagem dos fardos - tratamento para ser gravado na DXI
				   For nX := 1 to Len(aBlocos[nR][1])
	
				   	  	 //valor por outros
				   	  	 nValorAgio := OGX016CALO(aDadosCtr[1], aDadosCtr[4], aAgioOutros[nI][2], ablocos[nR][1][nX][10])
				   	  	 
				   	  	 ablocos[nR][1][nX][9][4] += nValorAgio
		   	             
		   	             //mensagem
		   	        	 ablocos[nR][1][nX][8]    += iif(nI == 1, STR0040 + _CRLF, "" )  + iif(nValorAgio < 0, STR0018,  STR0019) + " "+ alltrim(aAgioOutros[nI][1]) + " : " + alltrim(Str(nValorAgio)) + "."  + _CRLF 
				   	  	 
				   	  	 //valor total - soma as 4 formas de ágio e deságio
				   	  	 ablocos[nR][1][nX][7]    := ablocos[nR][1][nX][9][1] + ablocos[nR][1][nX][9][2] + ablocos[nR][1][nX][9][3] + ablocos[nR][1][nX][9][4] 
				   	  	 
				   	  	 nQtdTotal += ablocos[nR][1][nX][6] //peso	 
				   	  	 nMediaVlr += ablocos[nR][1][nX][6] *  ablocos[nR][1][nX][10]
	
				   	next nX	   	 
			   	   
				   	//calcula o ágio
		    		nValorAgio     := OGX016CALO(aDadosCtr[1], aDadosCtr[4], aAgioOutros[nI][2], nMediaVlr / nQtdTotal)
	
		   	    	//consolida o valor do bloco
		   	    	aBlocos[nR][6]    += nValorAgio
	
		   	    	//informa o valor somente por outros
		   	    	aBlocos[nR][8][4] += nValorAgio	  
		   	    	
		   	        //informa a mensagem
				    cMsg := iif(nValorAgio < 0, STR0018,  STR0019) + " "+ alltrim(aAgioOutros[nI][1]) + " : " + alltrim(Str(nValorAgio)) + "."  + _CRLF
	
				    //apropria a mensagem
				    aBlocos[nR][7] += iif(nI == 1, STR0040 + _CRLF, "" )  + cMsg 	    				 	

		   	        	
			   else //demais formas de cálculo
			   	   
			   	   //calcula o ágio
		    		nValorAgio     := OGX016CALO(aDadosCtr[1], aDadosCtr[4], aAgioOutros[nI][2])
	
		   	    	//consolida o valor do bloco
		   	    	aBlocos[nR][6]    += nValorAgio
	
		   	    	//informa o valor somente por outros
		   	    	aBlocos[nR][8][4] += nValorAgio
	
		   	    	//informa a mensagem
					cMsg := iif(nValorAgio < 0, STR0018,  STR0019) + " "+ alltrim(aAgioOutros[nI][1]) + " : " + alltrim(Str(nValorAgio)) + "."  + _CRLF
	
					//apropria a mensagem
					aBlocos[nR][7] += iif(nI == 1, STR0040 + _CRLF, "" )  + cMsg 
	
					//trata a listagem dos fardos - tratamento para ser gravado na DXI
				   	For nX := 1 to Len(aBlocos[nR][1])
	
				   	  	 //valor por outros
				   	  	 ablocos[nR][1][nX][9][4] += nValorAgio
				   	  	 //mensagem
				   	  	 ablocos[nR][1][nX][8]    += iif(nI == 1, STR0040 + _CRLF, "" )  + cMsg 
				   	  	 //valor total - soma as 4 formas de ágio e deságio
				   	  	 ablocos[nR][1][nX][7]    :=  ablocos[nR][1][nX][9][1] +  ablocos[nR][1][nX][9][2] +  ablocos[nR][1][nX][9][3] +  ablocos[nR][1][nX][9][4]
	
				   	next nX
			   endif    				

			endif
    	next nI

    next nR

return .t.


/** {Protheus.doc} OGX016CTR
carrega o array de retorno com os dados do contrato
@param:     cFilCtr   char(2) Filial do contrato
            cContrato char(6) Número do contrato
            cReserva  char(6) código da reserva
            cSafra    char(15) Safra
            cBloco    char(6) código do bloco
@return:    Array - Dados do contrato e da guia Algodão/Tipo cor e folha
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016CTR(cFilCTR, cContrato)
   //Carrega os dados de um contrato em um array específico
   Local aCtr  := nil  //Contrato

   DbSelectArea("NJR")
   NJR->(DbSetOrder(1))
   If NJR->(DbSeek(cFilCTR+cContrato))

      //Atualiza os dados no array - verificar impactos ao mexer na ordenação ou remover opção.
      aCtr  := {}
      aAdd(aCtr, {NJR->NJR_VLRBAS, NJR->NJR_MOEDA, NJR->NJR_UMPRC, NJR->NJR_TIPALG, NJR->NJR_CODCTR, NJR->NJR_CODENT, NJR->NJR_LOJENT, NJR->NJR_QTDCTR, NJR->NJR_TOLENT, NJR->NJR_CODPRO }  ) //dados do contrato
      aAdd(aCtr, {OGX016TIPO(cFilCtr, cContrato), NJR->NJR_TIPUM, NJR->NJR_TIPCAL, NJR->NJR_TIPFAT})
      aAdd(aCtr, {OGX016HVI(cFilCtr, cContrato), NJR->NJR_HVIUM, NJR->NJR_HVICAL, NJR->NJR_HVIFAT, /*removido*/ , NJR->NJR_HVIREG, NJR->NJR_HVITOL} )                                    //OGX016HVI(cFilCtr, cContrato))
      aAdd(aCtr, {OGX016OUT(cFilCtr, cContrato), NJR->NJR_OUTUM, NJR->NJR_OUTCAL, NJR->NJR_OUTFAT} )                                    //OGX016OUT(cFilCtr, cContrato))

   EndIf

Return aCtr

/** {Protheus.doc} OGX016TIPO
carrega os dados da aba aLGODÃO -> Tipo Folha e Cor e as regras HVI
@param:     cFilCtr   char(2) Filial do contrato
            cContrato char(6) Número do contrato
@return:    Array - Dados do contrato e da guia Algodão/Tipo cor e folha
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016TIPO(cFilCtr, cContrato, cTipoCalc)
   Local aRet  := {}
   Local aFC   := {}
   Local nF    := 0
   Local nC    := 0
   Local cRg   := ""

   DbSelectArea("N7J")
   N7J->(DbSetOrder(1))
   If N7J->(DbSeek(cFilCTR+cContrato))

      While !(N7J->(Eof())) .AND. ( N7J->N7J_CODCTR == cContrato )

      	 cRg  := OGX016REG(cFilCtr, cContrato, N7J->N7J_SEQUEN)

         aAdd(aFC, {N7J->N7J_TCRTIP, cRg, {}})

         nT := Len(aFC)

         For nF := 1 to 8   //Folha

            nFl := &("N7J->N7J_FOLHA"+AllTrim(STR(nF)))

	        aAdd(aFC[Nt][3], {})

	        //Carrega os dados de Cor em aTCor
	        If Select("N7G") = 0
	           DbSelectArea("N7G")
	           N7G->(DbSetOrder(1))
	        EndIf
	        N7G->(DbGoTop())

	        lZero := !(N7G->(DbSeek(cFilCTR+cContrato+N7J->N7J_SEQUEN)))

            For nC := 1 to 5  //Cor
                If lZero
                   nCl := 0
                Else
                  nCl := &("N7G->N7G_COR"+AllTrim(STR(nC)))
                EndIF

                aAdd(aFC[Nt][3][nF], {nFl, nCl} )
            Next nC

         Next nF
         N7J->(DbSkip())
      End

      N7G->(DbCloseArea())
      N7J->(DbCloseArea())

   Else
      aFC := {}
   EndIf

   aRet := aFC

Return aRet

/** {Protheus.doc} OGX016REG
Monta a instrução de regra HVI para o tipo Cor / Folha
@param:     cFilCtr   char(2) Filial do contrato
            cContrato char(6) Número do contrato
            cSeq  char(6) código da reserva
@return:    String - Instrução contengo a regra HVI para os tipos Cor e folha
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Consulta de Blocos/Fardos
*/
Function OGX016REG(cFilCtr, cContrato, cSeq  /*N7J->N7J_SEQUEN*/)
    Local aRet      := {}
	Local aArea		:= GetArea() // Area ativa
	Local cAliasQry := GetNextAlias() // Obtem o proximo alias disponivel
	Local cQry 		:= "" // Query

	Default cFilCTR 	:= ""
	Default cContrato	:= ""

   cQry := "SELECT * FROM " + RetSqlName("N7F") + " N7F " + ;
             "WHERE N7F_FILIAL = '" + cFilCtr + "' " + ;
             "AND N7F_CODCTR = '" + cContrato + "' " +;
             "AND N7F_SEQTIP = '" + cSeq + "' " +;
             "AND D_E_L_E_T_ = '' " +;
             "ORDER BY N7F_REGRA, N7F_CAMPO " ;


    cQry := ChangeQuery( cQry )

	If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasQry)->( dbCloseArea() )
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. ) // Executa a query

	dbSelectArea(cAliasQry) // Seleciona a area do alias
	(cAliasQry)->(dbGoTop()) // Posiciona no topo do registro
	While (cAliasQry)->(!Eof()) // Preenche o array com os códigos e valores do AgioDesagio - Outros referente ao contrato
		aAdd(aRet, { (cAliasQry)->N7F_CAMPO, (cAliasQry)->N7F_REGRA })
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return aRet

/*{Protheus.doc} OGX016HVI
Retorna os dados de Ágio/Deságio por HVI
@author jean.schulze
@since 26/07/2017
@version undefined
@param cFilCTR, characters, descricao
@param cContrato, characters, descricao
@type function
*/
Function OGX016HVI(cFilCTR, cContrato)
	Local aRet      := {}
	Local aArea		:= GetArea() // Area ativa
	Local cAliasQry := GetNextAlias() // Obtem o proximo alias disponivel
	Local cQry 		:= "" // Query

	Default cFilCTR 	:= ""
	Default cContrato	:= ""

    cQry := "SELECT N78_HVICMP, N78_HVITIP, N78_HVIPON, N78_HVIREG"
    cQry += " FROM "+ retSqlName('N78')+" N78"
    cQry += " WHERE N78.D_E_L_E_T_ = ''"
	cQry += "   AND N78_FILIAL 	= '"+cFilCTR+"'"
	cQry += "   AND N78_CODCTR  = '"+cContrato+"'"
	cQry += "   AND N78_APLICA 	= '2'" /*HVI*/
	cQry += "   AND N78_HVIPON	!= 0  " 
	cQry += "   ORDER BY N78_SEQUEN"

	cQry := ChangeQuery( cQry )

	If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasQry)->( dbCloseArea() )
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. ) // Executa a query

	dbSelectArea(cAliasQry) // Seleciona a area do alias
	(cAliasQry)->(dbGoTop()) // Posiciona no topo do registro
	While (cAliasQry)->(!Eof()) // Preenche o array com os códigos e valores do AgioDesagio - Outros referente ao contrato
		aAdd(aRet, { (cAliasQry)->N78_HVICMP, (cAliasQry)->N78_HVITIP, (cAliasQry)->N78_HVIPON, (cAliasQry)->N78_HVIREG })
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return aRet


/*{Protheus.doc} OGX016DX7
Retorna os dados de HVI para o Bloco
@author jean.schulze
@since 14/08/2017
@version undefined
@param cFilCTR, characters, descricao
@param cContrato, characters, descricao
@type function
*/
Function OGX016DX7(aFardos)
	Local aHviFard  := {} //monta os fardos
	Local aHvi      := {} //monta a media dos itens
	Local aArea		:= GetArea() // Area ativa
	                   ///DX7_CG,  Este campo e do topo caracter e foi retirado da lista de campos HVI
	Local aFieldDX7 := Separa("DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI", ",")
	Local nI        := 0
	Local nC        := 0

	if (Select("DX7") == 0)
		DbSelectArea("DX7")		//Resultado Laboratorial
	endif

	For nI:= 1 to len(aFardos) //vamos buscar todos os fardos
		DX7->(dbSetOrder(1))
		if DX7->(dbSeek(aFardos[nI][1]+aFardos[nI][2]+aFardos[nI][3])) //busca os dados de HVI
		 	//coloca no array()
		 	aHvi := {} //reset
		 	For nC := 1  to Len(aFieldDX7)
		 		 if valtype(&("DX7->"+aFieldDX7[nC])) == "N" 	
		 		 	aAdd(aHvi, {aFieldDX7[nC],&("DX7->"+aFieldDX7[nC])})
		 		 else
		 		 	aAdd(aHvi, {aFieldDX7[nC],0}) //somente itens numericos
		 		 endif	
			Next nC

		    aAdd(aHviFard, {aFardos[nI][1]+aFardos[nI][2]+aFardos[nI][3],aHvi})

		endif
    Next nI

	RestArea(aArea)

Return aHviFard

/*{Protheus.doc} OGX016RPLC
Replace para aplicação de regra
@author jean.schulze
@since 15/08/2017
@version undefined
@param cRegra, characters, descricao
@param cNomeDoArr, characters, descricao
@type function
*/
Function OGX016RPLC(cRegra, aDadosHvi)
	Local aFieldDX7 := Separa("DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI", ",")  //DX7_CG, Este campo não entra no calculo pois é do tipo caracter - 11-1 / 21-2 etc
	Local nA        := 0

	for nA:=1 to len(aFieldDX7)
		cRegra := StrTran( cRegra, aFieldDX7[nA], alltrim(str(aDadosHvi[nA][2]))) //array de campos + local de valor
	next

Return cRegra

/*{Protheus.doc} OGX016OUT
Retorna os dados de Ágio/Deságio por Outros
@author jean.schulze
@since 26/07/2017
@version undefined
@param cFilCTR, characters, descricao
@param cContrato, characters, descricao
@type function
*/
Function OGX016OUT(cFilCTR, cContrato)

	Local aRet      := {}
	Local aArea		:= GetArea() // Area ativa
	Local cAliasQry := GetNextAlias() // Obtem o proximo alias disponivel
	Local cQry 		:= "" // Query

	Default cFilCTR 	:= ""
	Default cContrato	:= ""

    cQry := "SELECT N78_OUTCOD, N78_OUTPON, N7K_DESCRI, N7K_VINCUL, N78_OUTPER, N78_SEQUEN "
    cQry += " FROM "+ retSqlName('N78')+" N78"
    cQry += " INNER JOIN "+ retSqlName('N7K')+ " N7K " //sempre precisa vincula
    cQry += "  ON N7K_FILIAL = '"+xFilial("N7K")+"' "
    cQry += " AND N7K_CODIGO = N78_OUTCOD "
    cQry += " WHERE N78.D_E_L_E_T_ = ''"
	cQry += "   AND N78_FILIAL 	= '"+cFilCTR+"'"
	cQry += "   AND N78_CODCTR  = '"+cContrato+"'"
	cQry += "   AND N78_APLICA 	= '3'"
	cQry += "   AND N78_OUTPON	> 0  " /*Valor do Cálculo Maior que 0*/
	cQry += "   ORDER BY N78_SEQUEN"

	cQry := ChangeQuery( cQry )

	If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
		(cAliasQry)->( dbCloseArea() )
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. ) // Executa a query

	dbSelectArea(cAliasQry) // Seleciona a area do alias
	(cAliasQry)->(dbGoTop()) // Posiciona no topo do registro
	While (cAliasQry)->(!Eof()) // Preenche o array com os códigos e valores do AgioDesagio - Outros referente ao contrato
		aAdd(aRet, { (cAliasQry)->N7K_DESCRI, (cAliasQry)->N78_OUTPON, (cAliasQry)->N7K_VINCUL, (cAliasQry)->N78_SEQUEN, (cAliasQry)->N78_OUTPER })
		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return aRet

/*{Protheus.doc} OGX016FVIN
Consulta de Fardos Vinculados a um Ágio/Deságio Outros
@author jean.schulze
@since 19/09/2017
@version undefined
@param cCodCtr, characters, descricao
@param cSequen, characters, descricao
@type function
*/
Function OGX016FVIN(cCodCtr, cSequen )
	Local cAliasQDV := GetNextAlias()
	Local nQtdVinc  := 0
	Local cFiltro   := ""

	cFiltro += " AND N87.N87_SEQUEN = '" + cSequen+"' " + ;
	           " AND N87.N87_CODCTR = '" + cCodCtr+"' " + ;
	           " AND DXP.DXP_CODCTP = '" + cCodCtr+"' "
	cFiltro := "%" + cFiltro + "%"

    //monta a query de busca da quantidade de fardos vinculados (N87)
    BeginSql Alias cAliasQDV

      SELECT SUM(DXI.DXI_PSLIQU) as DXI_PSLIQU
              FROM %Table:N87% N87
              INNER JOIN %Table:DXI% DXI ON  DXI.DXI_SAFRA  = N87.N87_SAFRA
                                         AND DXI.DXI_ETIQ   = N87.N87_ETIQ
                                         AND DXI.%notDel%
              INNER JOIN %Table:DXD% DXD ON  DXI.DXI_FILIAL = DXD.DXD_FILIAL
                                         AND DXI.DXI_SAFRA  = DXD.DXD_SAFRA
                                         AND DXI.DXI_BLOCO  = DXD.DXD_CODIGO
                                         AND DXD.%notDel%
              INNER JOIN %Table:DXQ% DXQ ON  DXQ.DXQ_FILORG = DXD.DXD_FILIAL
                                         AND DXQ.DXQ_BLOCO  = DXD.DXD_CODIGO
                                         AND DXQ.DXQ_CODRES = DXI.DXI_CODRES
                                         AND DXQ.%notDel%
              INNER JOIN %Table:DXP% DXP ON  DXP.DXP_CODIGO = DXQ.DXQ_CODRES
                                         AND DXP.DXP_FILIAL = DXQ.DXQ_FILIAL
                                         AND DXP.%notDel%
          WHERE N87.%notDel%
                  %exp:cFiltro%
    EndSQL

    DbselectArea( cAliasQDV )
    DbGoTop()
    if ( cAliasQDV )->( !Eof() )
  		nQtdVinc := ( cAliasQDV )->DXI_PSLIQU
    endif
    (cAliasQDV)->( dbCloseArea() )

return nQtdVinc

/** {Protheus.doc} OGX016RES
carrega o array de retorno com os dados do contrato
@param:     cFilCtr   char(2) Filial do contrato
            cContrato char(6) Número do contrato
            cReserva  char(6) código da reserva
            cSafra    char(15) Safra
            cBloco    char(6) código do bloco
@return:    Array - Dados da reserva referente a um bloco específico ou todos os blocos de um contrato
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016RES(cFilCtr, cContrato, cReserva, aLstBlc, nValorBase, cCodClient, cCodLoja)
   Local aTmp      := {}
   Local cQuery    := ""
   Local cAliasTMP := ""
   Local nValorFix := 0
   Local nCont     := 0
   Local cBloco    := ""
   Local cTipoPrc  := 0

   Default cReserva := ""
   Default aLstBlc  := {}

   cQuery := "SELECT DXP_CODIGO,DXP_CODCTP,DXP_ITECTP,DXP_CLACOM,DXP_STATUS,DXP_TIPRES,DXP_ITECAD, "
   cQuery +=        "DXP_TIPACT,DXQ_TIPO,DXQ_QUANT,DXQ_PSLIQU,DXQ_APROVA,DXQ_FILORG,DXI_FILIAL, "
   cQuery +=        "DXI_SAFRA,DXI_ETIQ,DXI_CODIGO,DXI_CLACOM,DXI_PSLIQU,DXI_CLAVIS,DXI_BLOCO, "
   cQuery +=        "DXI_FARDAO,DXI_CODPRO,DXI_CODRES,DXI_ITERES, DXI_ITEMFX, DXI_VLBASE, DXI.R_E_C_N_O_ DXI_RECNO, DXP_ITECAD "
   cQuery += "FROM "+ RetSqlName("DXI") + " DXI "
   cQuery +=    "INNER JOIN "+ RetSqlName("DXQ") + " DXQ ON DXI.DXI_FILIAL = DXQ.DXQ_FILORG "
   cQuery +=                                     " AND DXI.DXI_CODRES = DXQ.DXQ_CODRES "
   cQuery +=                                     " AND DXI.DXI_ITERES = DXQ.DXQ_ITEM "
   cQuery += 									 " AND DXQ.D_E_L_E_T_ = '' "
   cQuery +=    "INNER JOIN "+ RetSqlName("DXP") + " DXP ON DXP.DXP_FILIAL = DXQ.DXQ_FILIAL "
   cQuery +=                                           "AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO "
   cQuery += 									" AND DXP.D_E_L_E_T_ = '' "
   cQuery += "WHERE DXP.DXP_FILIAL = '" + cFilCtr + "' "
   cQuery += "AND DXP.DXP_CODCTP = '" + cContrato + "' "
   cQuery += "AND ((DXI_FATURA < '2') OR (DXI_FATURA = '2' and DXI_TIPPRE  = '2' )) " //somente o que não foi faturado ou está a fixar
      
   If !Empty(cReserva)
      cQuery += "AND DXP.DXP_CODIGO = '" + cReserva + "' "
   EndIf

   If len(aLstBlc) > 0
   
   	  //monta os blocos selecionados
	  For nCont := 1  to Len(aLstBlc) 
		  if !empty(aLstBlc[nCont]) //not null
			  cBloco +=  iif(!empty(cBloco),",","") + "'" + AllTrim(aLstBlc[nCont]) + "'" //monta os blocos conforme o tipo
	      endif
	  Next nCont
	    
	  if !empty(cBloco)
	  	 cQuery += "AND DXQ.DXQ_BLOCO IN (" + cBloco + ") "
	  endif   	
     
   EndIf

   cQuery += "AND DXI.D_E_L_E_T_ = ''"

   cAliasTMP := GetSqlAll(cQuery)

   (cAliasTMP)->(DbGoTop())

   While !(cAliasTMP)->(Eof())
   		  
   		  
   		  aVlrCtr   := OGAX721FAT(cFilCtr, cContrato, (cAliasTMP)->DXP_ITECAD, /*regra fiscal*/ ,(cAliasTMP)->DXI_RECNO, 0, nValorBase, cCodClient, cCodLoja) 
   		  nValorFix := aVlrCtr[1][1]
   		  cTipoPrc 	:= aVlrCtr[1][2]
   		  	
   		  if (nPos := aScan(aTMP,{|x| allTrim(x[3])+allTrim(x[2]) == alltrim((cAliasTMP)->DXQ_FILORG)+alltrim((cAliasTMP)->DXI_BLOCO) })) > 0
   		  	  //consolida a quantidade
   		  	  aTMP[nPos][5] += (cAliasTMP)->DXI_PSLIQU
   		  	  //somente repopula os valores dos fardos
   		  	  aAdd(aTMP[nPos][1], { (cAliasTMP)->DXI_FILIAL, ;
   		  		 		    		(cAliasTMP)->DXI_SAFRA,  ;
   		  		 				    (cAliasTMP)->DXI_ETIQ,   ;
   		  		 				    (cAliasTMP)->DXI_CODIGO, ;
   		  		 				    (cAliasTMP)->DXI_CLACOM, ;
   		  		 				    (cAliasTMP)->DXI_PSLIQU,;
   		  		 				    0 /*valor fardo de ágio e deságio*/, ;
   		  		 				    "" /*mensagem de ágio e deságio fardo*/,;
   		  		 				    {0,0,0,0} /*Valor por ágio 1(FOLHA), 2(COR) 3(HVI), 4(Outros)*/ ,;
   		  		 				    nValorFix,; 
   		  		 				    cTipoPrc })

   		  else

	  		 aAdd(aTMP, {{{ (cAliasTMP)->DXI_FILIAL, ;
	  		 				(cAliasTMP)->DXI_SAFRA,  ;
	  		 				(cAliasTMP)->DXI_ETIQ,   ;
	  		 				(cAliasTMP)->DXI_CODIGO, ;
	  		 				(cAliasTMP)->DXI_CLACOM, ;
	  		 				(cAliasTMP)->DXI_PSLIQU, ;
	  		 				0 /*valor fardo de ágio e deságio*/, ;
	  		 				"" /*mensagem de ágio e deságio fardo*/,;
   		  		 			{0,0,0,0} /*Valor por ágio 1(FOLHA), 2(COR) 3(HVI), 4(Outros)*/  ,;
   		  		 			nValorFix,;
   		  		 			cTipoPrc}},; //array de fardos
	  		 			 (cAliasTMP)->DXI_BLOCO  , ;
	  		 			 (cAliasTMP)->DXQ_FILORG , ;
	  		 		     (cAliasTMP)->DXI_CLACOM , ;
	  		 			 (cAliasTMP)->DXI_PSLIQU , ;
	  		 			 0 /*valor consolidado de ágio e deságio*/, ;
	  		 			 "" /*mensagem de ágio e deságio*/,;
   		  		 		 {0,0,0,0} /*Valor por ágio 1(FOLHA), 2(COR) 3(HVI), 4(Outros)*/})
   		  endif

         (cAliasTMP)->(DbSkip())
   EndDo

Return aTMP

/** {Protheus.doc} OGX016CALT
Cálculo dos valores de Ágio Deságio por Tipo
@param:     aCtrDados   array Contém os dados do contrato
			aAgioTipo   array dos dados de ágio e deságio por tipo
            aBloco   array Contém os dados do Bloco para calcular
            lOk      Boolean Indica se algum fardo não atende a regra HVI
@return:    Array -  Dados do resultado da simulação
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016CALT(aCtrDados, aAgioTipo, aBloco, nTipoFardo, cMsg)
   Local nX   := 0
   Local nTipoFolha := Val(SubStr(aBloco[4], 4, 1))
   Local nTipoCor   := Val(SubStr(aBloco[4], 2, 1))
   Local aResultado := {}
   Local nMediaVlr  := 0
   Local nQtdTotal  := 0
       
   //existe tipo /cor/folha
   if  nTipoFardo > 0 .and. (nTipoFolha > 0 .and. nTipoFolha <= 8 ) .and. (nTipoCor > 0 .and. nTipoCor <= 5)

	   aResultado := aAgioTipo[1][nTipoFardo][3][nTipoFolha][nTipoCor] //busca a soma de valores

	   If aAgioTipo[3] == "2" //Valor  
	   	       
	       //calcula por folha
	      aBloco[8][1] := OGX016CVLR(aResultado[1], aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	      //calcula por cor
	      aBloco[8][2] := OGX016CVLR(aResultado[2], aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	      //calcula o total
	      aBloco[6]    := aBloco[8][1] + aBloco[8][2]
	      
	      //cria a mensagem para folha
	      cMsg += iif(!empty(cMsg), _CRLF,  "") + iif(aBloco[8][1] < 0, STR0018,  STR0019) + " " + STR0026 + ": " + alltrim(Str(abloco[8][1])) + "." + _CRLF //Ágio/Deságio/"Folha"
	      //cria a mensagem para cor
	      cMsg += iif(abloco[8][2]< 0, STR0018,  STR0019) + " " + STR0027 + ": " + alltrim(Str(abloco[8][2])) + "." + _CRLF //Ágio/Deságio/"COR"
	      //cria a mensagem para o total
	      cMsg += STR0028 + " " + iif(abloco[6] < 0, STR0018,  STR0019) + " " + STR0020 + ": " + alltrim(Str(abloco[6])) + "." //Ágio/Deságio/"Tipo/Cor/Folha"
	      
	      //adiciona mensagem para os fardos
	      abloco[7] := STR0036 + _CRLF + cMsg + _CRLF + _CRLF  
	  		      
	      //trata a listagem dos fardos - tratamento para ser gravado na DXI
	   	  For nX := 1 to Len(aBloco[1])
	
	   	  	 //valor por folha
	   	  	 aBloco[1][nX][9][1] := aBloco[8][1]
	   	  	 //valor por cor
	   	  	 aBloco[1][nX][9][2] := aBloco[8][2]
	   	  	 //mensagem
	   	  	 abloco[1][nX][8]    := abloco[7] 
	   	  	 //valor total - soma as 4 formas de ágio e deságio
	   	  	 aBloco[1][nX][7]    := aBloco[1][nX][9][1] + aBloco[1][nX][9][2] + aBloco[1][nX][9][3] + aBloco[1][nX][9][4]
	
	   	  next nX
	      
	   ElseIf aAgioTipo[3] == "3" //Percentual
	   
	   	  For nX := 1 to Len(aBloco[1])

	   	  	 //valor por folha
	   	  	 aBloco[1][nX][9][1] := OGX016CPCT(aResultado[1], aBloco[1][nX][10]  /*Valor base*/,  aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	   	  	 //valor por cor
	   	  	 aBloco[1][nX][9][2] := OGX016CPCT(aResultado[2], aBloco[1][nX][10]  /*Valor base*/,  aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	   	  	 //valor total - soma as 4 formas de ágio e deságio
	   	  	 aBloco[1][nX][7]    := aBloco[1][nX][9][1] + aBloco[1][nX][9][2] + aBloco[1][nX][9][3] + aBloco[1][nX][9][4]
	   	  	 	 
	   	  	 nQtdTotal += aBloco[1][nX][6] //peso	 
	   	  	 nMediaVlr += aBloco[1][nX][6] * aBloco[1][nX][10]
	   	  	 
	   	  	 //adiciona mensagem para os fardos
	   	  	 aBloco[1][nX][8] := STR0036 + _CRLF + cMsg 
	   	  	 
	   	  	 //cria a mensagem para folha
	   	  	 aBloco[1][nX][8] += iif(!empty(cMsg), _CRLF,  "") + iif(aBloco[1][nX][9][1] < 0, STR0018,  STR0019) + " " + STR0026 + ": " + alltrim(Str(aBloco[1][nX][9][1])) + "." + _CRLF //Ágio/Deságio/"Folha"
	   	  	 //cria a mensagem para cor
	   	  	 aBloco[1][nX][8] += iif(aBloco[1][nX][9][2]< 0, STR0018,  STR0019) + " " + STR0027 + ": " + alltrim(Str(aBloco[1][nX][9][2])) + "." + _CRLF //Ágio/Deságio/"COR"
	   	  	 //cria a mensagem para o total
	   	  	 aBloco[1][nX][8] += STR0028 + " " + iif(aBloco[1][nX][9][1] + aBloco[1][nX][9][2] < 0, STR0018,  STR0019) + " " + STR0020 + ": " + alltrim(Str(aBloco[1][nX][9][1] + aBloco[1][nX][9][2])) + "." + _CRLF + _CRLF     //Ágio/Deságio/"Tipo/Cor/Folha"
	      	   	  	 	   	  	 
	   	  next nX	
	      
	      //calcula por folha
	      aBloco[8][1] := OGX016CPCT(aResultado[1],  nMediaVlr / nQtdTotal  /*Valor base*/,  aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	      //calcula por cor
	      aBloco[8][2] := OGX016CPCT(aResultado[2],  nMediaVlr / nQtdTotal   /*Valor base*/,  aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	      //calcula o total
	      aBloco[6]    := aBloco[8][1] + aBloco[8][2]   
	      
	      //cria a mensagem para folha
	      cMsg += iif(!empty(cMsg), _CRLF,  "") + iif(aBloco[8][1] < 0, STR0018,  STR0019) + " " + STR0026 + ": " + alltrim(Str(aBloco[8][1])) + "." + _CRLF //Ágio/Deságio/"Folha"
	      //cria a mensagem para cor
	      cMsg += iif(aBloco[8][2]< 0, STR0018,  STR0019) + " " + STR0027 + ": " + alltrim(Str(aBloco[8][2])) + "." + _CRLF //Ágio/Deságio/"COR"
	      //cria a mensagem para o total
	      cMsg += STR0028 + " " + iif(aBloco[6] < 0, STR0018,  STR0019) + " " + STR0020 + ": " + alltrim(Str(aBloco[6])) + "." //Ágio/Deságio/"Tipo/Cor/Folha"
	      
	      //adiciona mensagem para os fardos
	      aBloco[7] := STR0036 + _CRLF + cMsg + _CRLF + _CRLF     	

	   ElseIf aAgioTipo[3] == "4" //Pontuação
	      //calcula por folha
	      aBloco[8][1] := OGX016CPON(aResultado[1], aAgioTipo[4] /*fator*/, aCtrDados[1] /*valor base*/, aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	      //calcula por cor
	      aBloco[8][2] := OGX016CPON(aResultado[2], aAgioTipo[4] /*fator*/, aCtrDados[1] /*valor base*/, aAgioTipo[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
	       //calcula o total
	      aBloco[6]    := aBloco[8][1] + aBloco[8][2]
	      
	      //cria a mensagem para folha
	      cMsg += iif(!empty(cMsg), _CRLF,  "") + iif(aBloco[8][1] < 0, STR0018,  STR0019) + " " + STR0026 + ": " + alltrim(Str(abloco[8][1])) + "." + _CRLF //Ágio/Deságio/"Folha"
	      //cria a mensagem para cor
	      cMsg += iif(abloco[8][2]< 0, STR0018,  STR0019) + " " + STR0027 + ": " + alltrim(Str(aBloco[8][2])) + "." + _CRLF //Ágio/Deságio/"COR"
	      //cria a mensagem para o total
	      cMsg += STR0028 + " " + iif(abloco[6] < 0, STR0018,  STR0019) + " " + STR0020 + ": " + alltrim(Str(abloco[6])) + "." //Ágio/Deságio/"Tipo/Cor/Folha"
	      
	      //adiciona mensagem para os fardos
	      aBloco[7] := STR0036 + _CRLF + cMsg + _CRLF + _CRLF  
	  		     	      
	      //trata a listagem dos fardos - tratamento para ser gravado na DXI
	   	  For nX := 1 to Len(aBloco[1])
	
	   	  	 //valor por folha 
	   	  	 aBloco[1][nX][9][1] := aBloco[8][1]
	   	  	 //valor por cor
	   	  	 aBloco[1][nX][9][2] := aBloco[8][2]
	   	  	 //mensagem
	   	  	 abloco[1][nX][8] := aBloco[7]  
	   	  	 //valor total - soma as 4 formas de ágio e deságio
	   	  	 aBloco[1][nX][7]    := aBloco[1][nX][9][1] + aBloco[1][nX][9][2] + aBloco[1][nX][9][3] + aBloco[1][nX][9][4]
	
	   	  next nX
   	  
	   EndIf

   else
   	   Return .f.
   endif

Return .t.

/*{Protheus.doc} OGX016CALH
Calculo de valores do ágio e deságio HVI
@author jean.schulze
@since 15/08/2017
@version undefined
@param aCtrDados, array, descricao
@param aAgioHvi, array, descricao
@param nVlrAgio, numeric, descricao
@type function
*/
Function OGX016CALH(aCtrDados, aAgioHvi, nVlrAgio, nVlrBase)

   If aAgioHvi[3] == "2" //Valor
      nVlrAgio := OGX016CVLR(nVlrAgio,  aAgioHvi[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
   ElseIf aAgioHvi[3] == "3" //Percentual
      nVlrAgio := OGX016CPCT(nVlrAgio,  nVlrBase /*Valor base*/,  aAgioHvi[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
   ElseIf aAgioHvi[3] == "4" //Pontuação
      nVlrAgio := OGX016CPON(nVlrAgio, aAgioHvi[4] /*fator*/, aCtrDados[1] /*valor base*/, aAgioHvi[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
   EndIf

Return nVlrAgio

/** {Protheus.doc} OGX016CALO
Cálculo dos valores de Ágio Deságio Outros
@param:     aCtrDados   array Contém os dados do contrato
			aAgioOutros  array dos dados de ágio e deságio Outros
            nVlrAgio   valor do ágio deságio
@return:    Valor conrvertido
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016CALO(aCtrDados, aAgioOutros, nVlrAgio, nVlrBase)

   If aAgioOutros[3] == "2" //Valor
      nVlrAgio := OGX016CVLR(nVlrAgio, aAgioOutros[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
   ElseIf aAgioOutros[3] == "3" //Percentual
      nVlrAgio := OGX016CPCT(nVlrAgio, nVlrBase /*Valor base*/,  aAgioOutros[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
   ElseIf aAgioOutros[3] == "4" //Pontuação
      nVlrAgio := OGX016CPON(nVlrAgio, aAgioOutros[4] /*fator*/, aCtrDados[1] /*valor base*/, aAgioOutros[2] /*Un Agio*/,  aCtrDados[3] /*Un Preço*/, aCtrDados[10] /*Produto*/)
   EndIf

Return nVlrAgio

/** {Protheus.doc} OGX016CPON
carrega o array de retorno com os dados do contrato
@param:     nPontosTot Resultado da regra HVI por tipo/cor/folha no contrato
            nFator     Fator informado no contrato
            nValorBase Valor base informado no contrato
            unMedida   Unidade de Medida
            unPreco    Unidade de preço
@return:    Decimal - Valor calculado
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016CPON(nPontosTot, nFator, nValorBase, unMedida, unPreco, cProduto)
	Local nValor := 0

	nValor := A410Arred(nPontosTot / nFator, 'DXI_VADTOT')

	if unMedida <> unPreco //trazer para unidade de medida de preço
		nValor := A410Arred(nValor * AGRX001(unMedida,unPreco,1, cProduto), 'DXI_VADTOT')
	endif

return nValor

/** {Protheus.doc} OGX016CVLR
carrega o array de retorno com os dados do contrato
@param:     nValor     Resultado da regra HVI por tipo/cor/folha no contrato
            unMedida   Unidade de Medida
            unPreco    Unidade de preço
@return:    Decimal - Valor calculado
@author:    Marcelo Ferrari
@since:     24/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016CVLR(nValor, unMedida, unPreco, cProduto)

	if unMedida <> unPreco //trazer para unidade de medida de preço
		nValor := A410Arred(nValor * AGRX001(unMedida,unPreco,1, cProduto), ' DXI_VADTOT')
	endif

return nValor

/** {Protheus.doc} OGX016CPCT
Executa o cálculo da simulação do ágio/deságio por percentual para tipos opcionais por cor e folha

@param:     nValor     Resultado da soma de Cor + Folha conforme o tipo visual
            nValorBase Valor base informado no contrato
            unMedida   Unidade de Medida
            unPreco    Unidade de preço
@return:    Decimal - Valor calculado
@author:    Marcelo Ferrari
@since:     26/07/2017
@Uso:       OGX016 - Simulação do Bloco/Fardo
*/
Function OGX016CPCT(nPercentual, nValorBase, unMedida, unPreco, cProduto)

	if unMedida <> unPreco //trazer para unidade de medida de preço
		nPercentual := nPercentual * AGRX001(unMedida,unPreco,1,cProduto )
	endif

	nValor := A410Arred(nValorBase * (nPercentual / 100),'DXI_VADTOT')

return nValor
