#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"                   
#INCLUDE "TMKA273PGONL.CH"

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TK273PGON3   ³ Autor ³Michel W. Mosca      ³ Data ³ 21/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta array com os dados do Painel de Gestao de Orcamentos em³±±
±±³          ³Aberto.                                                      ³±±
±±³          ³Atencao: Nao funciona em sistema CodeBase.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±³          ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/		 
Function TK273PGON3() 
Local aArea		:= GetArea()
Local aChart	:={}		//Armazena as dimensoes do Painel de Gestao
Local aTabela	:={{},{},{}}		//Armazena o conteudo temporariamente para cada painel de gestao
Local cAliasSUO := "SUO"	//Armazena o alias da tabela SUO   
Local cAliasSUA := "SUA"	//Armazena o alias da tabela SUA   
Local aCampaign	:={}		//Armazena as campanhas
Local nCampaign	:= 0 		//Armazena a campanha a ser adicionado um valor
Local aValTot	:={0,0,0}	//Armazena os totais por cada estado do atendimento    
Local nI        :=0         //Contador utilizado em Loops
Local nStatus   :=0			//Armazena o status atribuido em UA_OPER
Local nVal		:=0         //Variavel auxiliar na busca da campanha
Local nAux		:=0         //Armazena o valor temporario do contador
Local nCount	:=0			//Armazena o valor a ser incrementado no contador por estado  
Local dDataIni	:= dDatabase //Data inicial a ser apurada
Local dDataFim  := dDatabase //Data final a ser apurada
 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TMKH06",.F.)
/*
PERGUNTE
MV_PAR01 - DIAS A ANALISAR ?
*/                  

//Retira o numero de dias da data inicial
dDataIni -= MV_PAR01

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aCampaign                             ³
³ aCampaign[1] - Codigo     		                       ³
³ aCampaign[2] - Descricao                          	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/ 
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aTabela                               ³
³ aStatus[1] - Nome do estado do atendimento               ³
³ aStatus[2] - Array com titulo "Campanha" e "Quantidade"  ³
³ aStatus[2] - Array aValores							   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/     
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aValores                              ³
³ aValores[1] - Nome da campanha                           ³
³ aValores[2] - Quantidade                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/     
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aValTot                               ³
³ aValTot[1] - Valor total de 1-Atendimento                ³
³ aValTot[2] - Valor total de 2-Cobranca                   ³
³ aValTot[3] - Valor total de 3-Encerrados                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/     

cAliasSUO	:= GetNextAlias()  

BeginSQL alias cAliasSUO
	SELECT UO_CODCAMP, UO_DESC
	FROM %table:SUO% SUO
	WHERE UO_FILIAL = %xFilial:SUO% AND SUO.%notDel%
	ORDER BY UO_CODCAMP	
EndSQL
                                                                     
Aadd(aCampaign, {0, STR0008}) //"SEM CAMPANHA"
DbSelectArea(cAliasSUO)
While (!EOF())
	Aadd(aCampaign, {(cAliasSUO)->UO_CODCAMP, (cAliasSUO)->UO_DESC})   
	DbSelectArea(cAliasSUO)
	DbSkip()
End

DbSelectArea(cAliasSUO) 
DbCloseArea()
 
Aadd(aTabela[1], STR0001)	//"Faturamento"
Aadd(aTabela[1], {STR0003, STR0004}) //"Campanha" # "Quantidade"
Aadd(aTabela[1], {})	
Aadd(aTabela[2], STR0002)	//"Orçamento"
Aadd(aTabela[2], {STR0003, STR0004}) //"Campanha" # "Quantidade"
Aadd(aTabela[2], {})	
Aadd(aTabela[3], STR0005)	//"Atendimento"    
Aadd(aTabela[3], {STR0003, STR0004}) //"Campanha" # "Quantidade"
Aadd(aTabela[3], {})	
	

cAliasSUA	:= GetNextAlias()

BeginSQL alias cAliasSUA
	Column UA_EMISSAO As Date 
	SELECT UA_CODCAMP, UA_EMISSAO, UA_OPER, COUNT(*) SUACONTADOR
	FROM %table:SUA% SUA
	WHERE 	UA_FILIAL = %xFilial:SUA% 			AND 
			SUA.%notDel% 						AND                                         
	 		UA_EMISSAO >= %exp:dDataIni% 	AND 
	 		UA_EMISSAO <= %exp:dDataFim%		
	GROUP BY UA_CODCAMP, UA_EMISSAO, UA_OPER
	ORDER BY UA_CODCAMP, UA_EMISSAO, UA_OPER
EndSQL                   	 



DbSelectArea(cAliasSUA)	
While (!EOF())               
	
	If(dDataIni > (cAliasSUA)->UA_EMISSAO .OR.;
		dDataFim < (cAliasSUA)->UA_EMISSAO)
		DbSelectArea(cAliasSUA)
		DbSkip()		
		Loop		
	EndIf
	
	nStatus := Val((cAliasSUA)->UA_OPER)
	nCampaign := 1	//Sem campanha
	For nI:=2 To Len(aCampaign) 
		If (cAliasSUA)->UA_CODCAMP == aCampaign[nI][1]  				
			nCampaign	:= nI
			Exit			
		EndIf		
	Next		                                	  
	//Verificar se já existe o elemento no array de valores
	For nVal := 1 To Len(aTabela[nStatus][3])
		If aTabela[nStatus][3][nVal][1] == aCampaign[nCampaign][2]
			Exit			
		EndIf		
	Next 

	nCount := (cAliasSUA)->SUACONTADOR	

	If nVal > Len(aTabela[nStatus][3]) 
		//Nao encontrou uma campanha, então adiciona no array
		Aadd(aTabela[nStatus][3],{aCampaign[nCampaign][2], nCount})		
	Else                                                     
		//Encontrou uma campanha, então incrementa o valor no array
		aTabela[nStatus][3][nVal][2]+=nCount
	EndIf
	aValTot[nStatus]+=nCount
	DbSelectArea(cAliasSUA)
	DbSkip()
End	                                        
                         

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
|Converte os valores de Numerico para String conforme tipo |
|de dado esperado para o preenchimento do Grafico          |
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
For nStatus:=1 To 3 
	If Len(aTabela[nStatus][3]) > 0	
		For nVal := 1 To Len(aTabela[nStatus][3])
			nAux := aTabela[nStatus][3][nVal][2]
			aTabela[nStatus][3][nVal][2] := Nil
			aTabela[nStatus][3][nVal][2] := AllTrim(Str(nAux))		
		Next 
	Else                                         
		Aadd(aTabela[nStatus][3],{STR0007, "0"})	//"SEM INFORMAÇÃO"
	EndIf
Next
DbSelectArea(cAliasSUA) 
DbCloseArea()

aChart	:= {GRP_PIE,; 
			{STR0006,{ || },{STR0001, STR0002, STR0005},aValTot},; //"Quantidade de Atendimentos" # "Faturamento" # "Orçamento" # "Atendimento"
			{STR0006,{ || }, aTabela}}			//"Quantidade de Atendimentos"

RestArea(aArea)
Return aChart
