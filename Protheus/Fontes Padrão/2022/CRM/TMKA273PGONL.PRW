#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"                   
#INCLUDE "TMKA273PGONL.CH"

/*                
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �TK273PGON3   � Autor �Michel W. Mosca      � Data � 21/02/07 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Monta array com os dados do Painel de Gestao de Orcamentos em���
���          �Aberto.                                                      ���
���          �Atencao: Nao funciona em sistema CodeBase.                   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � CALL CENTER                                                 ���
��������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �        �      �                                             ���
���          �        �      �                                             ���
���          �        �      �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
 

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TMKH06",.F.)
/*
PERGUNTE
MV_PAR01 - DIAS A ANALISAR ?
*/                  

//Retira o numero de dias da data inicial
dDataIni -= MV_PAR01

/*
����������������������������������������������������������Ŀ
� Estrutura do Array aCampaign                             �
� aCampaign[1] - Codigo     		                       �
� aCampaign[2] - Descricao                          	   �
������������������������������������������������������������
*/ 
/*
����������������������������������������������������������Ŀ
� Estrutura do Array aTabela                               �
� aStatus[1] - Nome do estado do atendimento               �
� aStatus[2] - Array com titulo "Campanha" e "Quantidade"  �
� aStatus[2] - Array aValores							   �
������������������������������������������������������������
*/     
/*
����������������������������������������������������������Ŀ
� Estrutura do Array aValores                              �
� aValores[1] - Nome da campanha                           �
� aValores[2] - Quantidade                                 �
������������������������������������������������������������
*/     
/*
����������������������������������������������������������Ŀ
� Estrutura do Array aValTot                               �
� aValTot[1] - Valor total de 1-Atendimento                �
� aValTot[2] - Valor total de 2-Cobranca                   �
� aValTot[3] - Valor total de 3-Encerrados                 �
������������������������������������������������������������
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
Aadd(aTabela[2], STR0002)	//"Or�amento"
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
	//Verificar se j� existe o elemento no array de valores
	For nVal := 1 To Len(aTabela[nStatus][3])
		If aTabela[nStatus][3][nVal][1] == aCampaign[nCampaign][2]
			Exit			
		EndIf		
	Next 

	nCount := (cAliasSUA)->SUACONTADOR	

	If nVal > Len(aTabela[nStatus][3]) 
		//Nao encontrou uma campanha, ent�o adiciona no array
		Aadd(aTabela[nStatus][3],{aCampaign[nCampaign][2], nCount})		
	Else                                                     
		//Encontrou uma campanha, ent�o incrementa o valor no array
		aTabela[nStatus][3][nVal][2]+=nCount
	EndIf
	aValTot[nStatus]+=nCount
	DbSelectArea(cAliasSUA)
	DbSkip()
End	                                        
                         

/*
����������������������������������������������������������Ŀ
|Converte os valores de Numerico para String conforme tipo |
|de dado esperado para o preenchimento do Grafico          |
������������������������������������������������������������
*/
For nStatus:=1 To 3 
	If Len(aTabela[nStatus][3]) > 0	
		For nVal := 1 To Len(aTabela[nStatus][3])
			nAux := aTabela[nStatus][3][nVal][2]
			aTabela[nStatus][3][nVal][2] := Nil
			aTabela[nStatus][3][nVal][2] := AllTrim(Str(nAux))		
		Next 
	Else                                         
		Aadd(aTabela[nStatus][3],{STR0007, "0"})	//"SEM INFORMA��O"
	EndIf
Next
DbSelectArea(cAliasSUA) 
DbCloseArea()

aChart	:= {GRP_PIE,; 
			{STR0006,{ || },{STR0001, STR0002, STR0005},aValTot},; //"Quantidade de Atendimentos" # "Faturamento" # "Or�amento" # "Atendimento"
			{STR0006,{ || }, aTabela}}			//"Quantidade de Atendimentos"

RestArea(aArea)
Return aChart
