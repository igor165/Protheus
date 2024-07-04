#include "PROTHEUS.CH"
#include "APWIZARD.CH"
#include "LJWIZNFCE.CH"

Static aSX3		:= {}
Static aSX6		:= {}
Static aArqS	:= {}
Static cCpoSenh := "SENHA_PFX"
Static cCpoNomS := "ArquivoPFX"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjWizPAF ºAutor  ³Vendas Clientes       º Data ³  2017		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de ajuste manual de parâmetros para o funcionamento     º±±
±±º          ³  da PAF-ECF sobre tela Wizard                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjWizPAF()
Local oWizard						//Objeto Wizard
Local oGD_ERP						//Objeto para painel dos parâmetros (SX6)
Local oGD_PASS						//Objeto para painel de senha do certificado
Local lRetAux	:= .F.				//Auxiliar de Retorno
Local lSX3Ok	:= .F.				//Retorno da Tabela de Array SX3
Local lSX6Ok	:= .F.				//Retorno da Tabela de Array SX6
Local lPassOK	:= .F.
Local lIsPdvPAF	:= LjxBGetPaf()[2] .OR. LjGtIsPaf()
Local lSTBPEnvXML:= STBPEnvXML()
Local cMsgPFX	:= "A proxima tela se refere ao arquivo de Certificados caso possua " +; 
					"o arquivo com extensão (.PFX). Crie a pasta Certs dentro da Protheus Data desse ambiente" +;
					" e insira o arquivo para que seja efetuada a conversão (seu arquivo .PFX não será alterado)"


If GetRemoteType() == 5
	MsgAlert (STR0054) //"Wizard não disponível para ambiente SmartClient WebApp."
Else 
	//inicia os arrays estaticos
	LjSetArr('SX3')
	LjSetArr('SX6')
	LjSetArr('PASS')

	/*
		MONTAGEM DO WIZARD
			Explicacao sobre NEXT e BACK:
		Ao ser executado, NEXT soma 1 ao painel atual(oWizard:NPANEL), já BACK, subtrai 1
		Ex: Se estamos no PANEL 1 e queremos ir para o PANEL 4, usamos:
		NEXT {|| oWizard:NPANEL := 3 }, pois ao ser usado NEXT, ele vai somar 1, indo para o PANEL 4
	*/	
	DEFINE WIZARD oWizard;
		TITLE "Wizard PAF-ECF";									//"Wizard NFC-e"
		HEADER "Wizard de Configuração do PAF-ECF";									//"Wizard de Configuração da NFC-e"
		MESSAGE "Programa de Aplicativo Emissor de Cupom Fiscal (PAF-ECF)";			//"Nota Fiscal de Consumidor Eletrônica"
		TEXT "A partir de agora, validaremos o Dicionário de Dados e revisaremos as configurações de alguns parâmetros" PANEL;
		NEXT {|| lSX3Ok := LJLoad2Arr('SX3'), lSX6Ok := LJLoad2Arr('SX6'), lPassOK := LJLoad2Arr("PASS"),;
				nNextPanel := IIF(lSX3Ok .AND. lSX6Ok .And. lPassOK ,1,3), oWizard:NPANEL := nNextPanel/*3+1=4*/, .T.};
		FINISH {|| .T.}

	// PANEL 2 - PARAMETRO ERP	
	CREATE PANEL oWizard;
		HEADER STR0005;									//"Parâmetros (SX6)"
		MESSAGE STR0006 + CRLF + STR0007 PANEL;		//"Para efetivar as alterações, clique em Avançar."###"Somente um usuário do grupo ADMINISTRADORES pode efetuar alterações"
		BACK { || .T.};
		EXEC { || oGD_ERP := LJArr2Grid('SX6',oWizard:GetPanel(2)) };
		NEXT { || lRetAux := IIf(oGD_ERP:TudoOk(), (IIF(FwIsAdmin(), LJUpdSX6(oGD_ERP),.F.), .T.), .F.),;
					IIF(lRetAux, nNextPanel := IIF(lIsPdvPAF,3,2),.F.),;
					IIF(lRetAux .And. !lIsPdvPAF .And. lSTBPEnvXML, Aviso("Certificado",cMsgPFX,{"OK"},2), .F.),;
					oWizard:NPANEL := nNextPanel, lRetAux }; //no PDV não tem o certificado
		FINISH { || .T.}
		
	// PANEL 3 - Arquivo de Chaves	

	//"Para efetivar as alterações, clique em Avançar."###"Somente um usuário do grupo ADMINISTRADORES pode efetuar alterações"
	CREATE PANEL oWizard;
		HEADER "Arquivo de Certificado";
		MESSAGE STR0006 + CRLF + STR0007 +;
				CRLF + "O Arquivo de certificado (.PFX) deve estar na Pasta \Certs\ da 'Protheus Data'" PANEL;		
		BACK { || oWizard:nPanel := 3 , .T.};
		EXEC { || oGD_PASS := LJArr2Grid('PASS',oWizard:GetPanel(3)) };
		NEXT { || IIf(oGD_PASS:TudoOk(), (IIF(FwIsAdmin(), LjWPArqPFX(oGD_PASS), Nil), .T.), .F.) };		
		FINISH { || .T.}

	// PANEL 4 - LOG
	CREATE PANEL oWizard;
		HEADER STR0012;									//"Conclusão"
		MESSAGE STR0013 PANEL;							//"Verifique abaixo o log de conclusão"
		BACK {|| MsgInfo(STR0014, "Wizard PAF-ECF"),.F.};		//"Conclua o Assistente e execute-o novamente."###"WIZARD NFC-e"		
		NEXT {|| .T.};
		EXEC {|| LjWizLog('ALL', oWizard:GetPanel(4)), .T. };
		FINISH {|| .T. }

	ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
Endif 

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjPar2aHaC ºAutor  ³Vendas Clientes      º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que obtemos o aCols e aHeader que serão utilizados      º±±
±±º          ³  na montagem do Grid do Wizard                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJPAR2aHaC(cInfo)

Local nI		:= 0		//Contador
Local nUsado	:= 0		//Retorna o tamanho do Header
Local aAux		:= {}		//Array auxiliar
Local aRet		:= {}		//Array de retorno
Local aHeader	:= {}		//Elemento do Grid
Local aCols		:= {}		//Elemento do Grid
Local cNomeP	:= ""
Local cLegP		:= ""

Default cInfo	:= ""

If cInfo == "PASS"
	cNomeP := cCpoNomS
	cLegP  := cCpoSenh
Else
	cNomeP := STR0015 //'Parametro'###'PARAMETRO'
	cLegP  := STR0017 //'Conteudo'###'CONTEUDO'
EndIf

// ------------------------------
// AHEADER - serve para ERP
// ------------------------------
Aadd( aHeader, {cNomeP		, Upper(cNomeP)	, ''				,;
				10			, 0				, 'AllwaysTrue()'	,;
				Nil			, 'C'			, Nil				,;
				Nil} )

Aadd( aHeader, {cLegP		, Upper(cLegP)	, ''				,;
				250			, 0				, 'AllwaysTrue()'	,;
			 	Nil			, 'C'			, Nil				,;
			 	Nil} )

//tamanho do aHeader (quantidade de campos)
nUsado := Len( aHeader )

// -----
// ACOLS
// -----
If cInfo == "SX6"
	aAux := Aclone( LJGetArr('SX6') )
ElseIf cInfo == "PASS"
	aAux := Aclone( LJGetArr("PASS") )
EndIf	

//para cada tipo, obtém os dados dos parâmetros
For nI := 1 to Len( aAux )
	
	//Se o parâmetro existir
	If aAux[nI][3]
		//cria uma nova linha no aCols
		Aadd(aCols, Array(nUsado + 1) )
		//e o alimenta com os valores do parâmetro
		aTail(aCols)[1] 		:= PadR(aAux[nI][1],250)	//Parâmetro
		aTail(aCols)[2]			:= PadR(aAux[nI][4],250)	//Conteúdo
		aTail(aCols)[nUsado+1]	:= .F.						//Marca como não deletado
	EndIf
Next

// retorna o aHeader e aCols
Aadd( aRet, aHeader	)
Aadd( aRet, aCols	) 

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjSetArr ºAutor    ³Vendas Clientes      º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria uma tabela de arrays a partir do conteúdo específico     º±±
±±º          ³   (SX3, SX6)                                         		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjSetArr( cInfo, nOperacao, aAux )
Local lLeg82 := LJAnalisaLeg(82)[1]

Default cInfo		:= ""		//Tabela desejada
Default nOperacao	:= 0		//0=Cria Tabela de Array
Default aAux		:= {}		//Montagem da Tabela de Array

DO CASE

	Case cInfo == 'SX3'
		/*		
		[][1] - nome do campo
		[][2] - 1-obrigatorio 2-recomendado 3-opcional
		[][3] - indica se o campo existe
		*/			
		If nOperacao == 0
			aAux := {}
							
			Aadd( aAux, {'LG_CRECFPA'	, 1, .F.} )
			Aadd( aAux, {'L2_ORIGEM'	, 1, .F.} )
			Aadd( aAux, {'LR_ORIGEM'	, 1, .F.} )
			Aadd( aAux, {'L2_POSIPI'	, 1, .F.} )
			Aadd( aAux, {'LR_POSIPI'	, 1, .F.} )
			Aadd( aAux, {'L2_CEST'		, 1, .F.} )
			Aadd( aAux, {'LR_CEST'		, 1, .F.} )
		EndIf
		
		aSX3 := Aclone( aAux )
	
	Case cInfo == 'SX6'			
		/*		 
		[][1] - nome do parametro 
		[][2] - 1-obrigatorio 2-recomendado 3-opcional		
		[][3] - indica se o parametro existe
		[][4] - valor do parametro
		*/			
		If nOperacao == 0
			aAux := {}
			
			Aadd(aAux, {'MV_LJPAFEC', 1, .F., Nil} )
			Aadd(aAux, {'MV_LJPAFWS', IIF(lLeg82,3,1), .F., Nil} )
			Aadd(aAux, {'MV_LJDAVEC', 3, .F., Nil} )
			Aadd(aAux, {'MV_LJSNFEP', 3, .F., Nil} )
			Aadd(aAux, {'MV_LJCRPAF', IIF(lLeg82,3,1), .F., Nil} )
			Aadd(aAux, {'MV_LJOFFLN', 1, .F., Nil} )
			Aadd(aAux, {'MV_LJAMBIE', 1, .F., Nil} )
			Aadd(aAux, {'MV_LJIMAUT', 1, .F., Nil} )
			Aadd(aAux, {'MV_LJRPAUT', 1, .F., Nil} )
			Aadd(aAux, {'MV_LJMATOF', 1, .F., Nil} )
			Aadd(aAux, {'MV_LJSERDA', 3, .F., Nil} )
			Aadd(aAux, {'MV_LJSERPR', 3, .F., Nil} )
			Aadd(aAux, {'MV_LJPRVEN', 1, .F., Nil} )
			
			If lLeg82
				Aadd(aAux, {'MV_LJPENXM', 3, .F., Nil} )
			EndIf
		EndIf
		
		aSX6 := Aclone( aAux )
	
	Case cInfo == "PASS"
		If nOperacao == 0
			aAux := {}
			
			Aadd(aAux, {cCpoSenh, 3, .T., Space(50)} )
		EndIf
		
		aArqS := Aclone( aAux )
ENDCASE

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjGetArr ºAutor    ³Vendas Clientes      º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que retorna o conteúdo do array a partir de um         º±±
±±º          ³   elemento específico.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJGetArr(cInfo)

Local aAux := {}		//Retorno do Conteúdo

Default cInfo := ""

DO CASE
	Case cInfo == 'SX3'
		aAux := aClone(aSX3)
		
	Case cInfo == 'SX6'
		aAux := aClone(aSX6)
	
	Case cInfo == "PASS"
		aAux := aClone(aArqS)

ENDCASE

Return aAux

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjLoad2Arr ºAutor    ³Vendas Clientes    º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtém os dados do array estático (SX3,SX6)            º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJLoad2Arr(cInfo)
	
Local nI		:= 0			//Contador
Local nPos		:= 0			//Posição do Array
Local cAliasName:= ""		//Nome do Alias
Local xGetMV	:= Nil			//Conteúdo GetMV
Local aAux		:= {}			//Dados do array estático (SX3 ou SX6) 
Local lRet		:= .T.			//Retorno

Default cInfo	:= ""

//obtem os dados do array estatico
aAux := aClone( LjGetArr(cInfo) )

DO CASE

	Case cInfo == "SX3"		
		
		For nI := 1 to Len(aAux)
				
			nPos := At( "_", aAux[nI][1] )
			
			//ZZ_FieldName
			If nPos == 3
				cAliasName := 'S' + SubStr(aAux[nI][1], 1, 2)  		
			//ZZZ_FieldName
			Else
				cAliasName := SubStr(aAux[nI][1], 1, 3)
			EndIf	
			
			If &(cAliasName)->(FieldPos(aAux[nI][1]) ) > 0
				aAux[nI][3] := .T.
			Else	//se o campo for OBRIGATORIO
				If aAux[nI][2] == 1	
					lRet := .F.
				EndIf
			EndIf
			
		Next

	Case cInfo == "SX6"

		For nI := 1 to Len( aAux )
			
			xGetMV := GetMV( aAux[nI][1], .F., "NOT_FOUND" )//SuperGetMV( aAux[nI][1], .F., "NOT_FOUND" )
		
			If ValType(xGetMV) == "C" .AND. xGetMV == "NOT_FOUND"
				If aAux[nI][2] == 1		//se o parametro for OBRIGATORIO
					lRet := .F.
				EndIf
			Else
				aAux[nI][3] := .T.		//indica que o parametro existe
				aAux[nI][4] := xGetMV	//armazena o valor do parametro
			EndIf
		Next
ENDCASE

//atualiza o array estatico para geracao do Log
LjSetArr( cInfo, 1/*atualiza*/, aAux ) 

//limpa o array da memória
ASize( aAux, 0 )
aAux := Nil

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjWizLog ºAutor    ³Vendas Clientes      º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Log de Ocorrências após a alteração dos parâmetros            º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjWizLog( cInfo, oWindow )

Local cLog		:= ''			//Conteúdo do Log
Local nI		:= 0			//Contador I
Local nX		:= 0			//Contador X
Local aAux		:= {}			//Array auxiliar
Local aLog		:= { {/*OBRIG*/}, {/*RECOM*/}, {/*OPCIO*/} }	//Resultado do Log
Local oMultiGet	:= Nil		//Interface com o resultado do Log

Default cInfo	:= 'ALL'
Default oWindow := Nil

If cInfo == 'ALL'  
	Aadd( aAux, Aclone(LJGetArr('SX3')) )
	Aadd( aAux, Aclone(LJGetArr('SX6')) )
	Aadd( aAux, Aclone(LJGetArr('PASS')) )
Else
	Aadd( aAux, Aclone(LJGetArr(cInfo)) )
EndIf
	
For nI := 1 to Len( aAux )
	For nX := 1 to Len( aAux[nI] )		
		//se o campo/parametro/configuracao nao existir
		If !aAux[nI][nX][3]
			Do Case 
				//itens obrigatorios
				Case aAux[nI][nX][2] = 1
					Aadd( aLog[1], aAux[nI][nX][1] )								
				//itens recomendados		  
				Case aAux[nI][nX][2] = 2
					Aadd( aLog[2], aAux[nI][nX][1] ) 
				//itens opcionais
				Case aAux[nI][nX][2] = 3
					Aadd( aLog[3], aAux[nI][nX][1] )
			EndCase
		EndIf
	Next
Next

/*
	Formataçao da string contendo o LOG	
*/
If cInfo == 'ALL'
	If Len(aLog[1]) > 0
		cLog += 'NÃO FOI POSSÍVEL FINALIZAR A CONFIGURAÇÃO DO PAF-ECF. Verifique os itens OBRIGATÓRIOS:'
		cLog += Replicate(CRLF,2)
	ElseIf (Len(aLog[2]) + Len(aLog[3])) > 0
		cLog += 'A configuração do PAF-ECF foi finalizada, porém há algumas advertências:'
		cLog += Replicate(CRLF,2)
	Else
		cLog += 'A configuração do PAF-ECF foi finalizada com SUCESSO!'
		cLog += Replicate(CRLF,2)
	EndIf
EndIf

If Len(aLog[1]) > 0 
	cLog += STR0024	//"- os itens OBRIGATÓRIOS abaixo não existem nesse ambiente:"
	cLog += CRLF
	For nI := 1 to Len(aLog[1])
		cLog += (aLog[1][nI] + ';')
	Next
	cLog += Replicate(CRLF,2)
EndIf

If Len(aLog[2]) > 0
	cLog += STR0025	//"- os itens RECOMENDADOS abaixo não existem nesse ambiente:"
	cLog += CRLF
	For nI := 1 to Len(aLog[2])
		cLog += (aLog[2][nI] + ';')
	Next
	cLog += Replicate(CRLF,2)
EndIf

If Len(aLog[3]) > 0
	cLog += STR0026	//"- os itens OPCIONAIS abaixo não existem nesse ambiente:"
	cLog += CRLF
	For nI := 1 to Len(aLog[3])
		cLog += (aLog[3][nI] + ';')
	Next
	cLog += Replicate(CRLF,2)
EndIf

If Len(aLog[1]) > 0 .OR. Len(aLog[2]) > 0 .OR. Len(aLog[3]) > 0
	cLog += "- Para campos/parâmetros obrigatórios, execute o compatibilizador do Boletim do PAF-ECF POL0852017R1"
	cLog += CRLF
	cLog += STR0050	//"- Para campos/parâmetros recomendados ou opcionais, atualize o dicionário, consultando a documentação no TDN de acordo com o campo/parâmetro a ser configurado."
	cLog += Replicate(CRLF,2)
EndIf

If Len(aLog[1]) > 0 .OR. Len(aLog[2]) > 0 .OR. Len(aLog[3]) > 0
	cLog += "- Para maiores informações, por gentileza, leia o documento técnico http://tdn.totvs.com/display/PROT/MVAR-3505+DT+PAF-ECF+ER+02.05+Laudo+POL0852017R1"
	cLog += Replicate(CRLF,2)
EndIf

/*
	Montagem do MultiGet com o resultado do log
*/
oMultiGet := TMultiGet():Create(oWindow			, {|| cLog} 		, 5					, 5				,; 
								292				, 130				, /*oFont*/			, Nil			,;
								Nil				, Nil				, Nil				, .T. /*lPixel*/,;
								Nil				, Nil				, /*bWhen*/			, Nil			,; 
								Nil				, .T. /*lReadOnly*/	, /*bValid*/		, Nil			,;
								Nil				, .F. /*lBorder*/	, /*lVScroll*/		, /*cLabelText*/,;
								/*nLabelPos*/	, /*oLabelFont*/	, /*nLabelColor*/	)

Return oMultiGet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjUpdSX6 ºAutor    ³Vendas Clientes      º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite update na tabela SX6 com base na edição do grid       º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJUpdSX6(oGetData)

Local nI			:= 0		//Contador
Local nPos			:= 0		//Posição do Array
Local aColsAux	:= {}		//aCols do objeto MSNewGetDados
Local aSX6Aux		:= {}		//Conteúdo editado do array aSX6 	

Default oGetData := Nil

//obtemos o aCols do objeto MSNewGetDados com os dados editados
aColsAux := aClone(oGetData:aCols)

//verifica se há algum parâmetro pra ser atualizado (nao deletado no grid)
nPos := Ascan( aColsAux, {|x| Atail(x) == .F.} )

If nPos > 0

	If MsgYesNo(STR0029 + CRLF +;		//"Atualizar os valores dos parâmetros(SX6)?"
				STR0030)	//"Os parâmetros excluídos no grid não serão considerados."

		//obtemos o conteudo do array estatico aSX6
		aSX6Aux := Aclone( LJGetArr('SX6') )

		For nI := 1 to Len(aColsAux)
			//só atualiza o SX6 e o array, se a linha do grid nao tiver deletada
			If !aTail( aColsAux[nI] )

				//atualizamos a tabela SX6 
				PutMV( AllTrim(aColsAux[nI][1]), AllTrim(aColsAux[nI][2]) )

				//atualizamos o array estático aSX6
				nPos := Ascan( aSX6Aux, {|x| x[1] == AllTrim(aColsAux[nI][1])} )
				If nPos > 0
					aSX6Aux[nPos][4] := aColsAux[nI][2]
					LjSetArr( "SX6", 1, aSX6Aux )
				EndIf				
			EndIf
		Next

	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LjArr2Grid ºAutor    ³Vendas Clientes    º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lê as informações do grid a partir de um array                º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJArr2Grid(cInfo, oWnd)
Local aAlter	:= {}		//Array que mostrará a coluna "CONTEÚDO" se o login do usuário for administrador

Default cInfo	:= ""
Default oWnd	:= Nil

If cInfo == "SX6" .Or. cInfo == "PASS"
	//se pertencer ao grupo Administradores, permite editar a coluna CONTEUDO
	If FwIsAdmin()
		If cInfo == "PASS"
			aAlter := {cCpoSenh}
		Else
			aAlter := {STR0018}		//'CONTEUDO'
		EndIf
	EndIf
EndIf	

//obtemos o aCols e aHeader que serao utilizados
aAuxHeader := Aclone( LJPAR2aHaC(cInfo)[1] )
aAuxCols := Aclone( LJPAR2aHaC(cInfo)[2] )

oGetDados := MsNewGetDados():New(	010						, 010			, 125 			, 280			,;
									GD_UPDATE+GD_DELETE		, 'AllwaysTrue' , "LjWzPTdOK"	, Nil			,;
									aAlter					, /*nFreeze*/0	, 999			, "AllwaysTrue"	,;
									""						, "AllwaysTrue"	, oWnd			, aAuxHeader	,;
									aAuxCols 				)

Return oGetDados
/*
MsNewGetDados(): New ( 	[ nTop]					, [ nLeft]		, [ nBottom]		, [ nRight ]	, 
						[ nStyle]				, [ cLinhaOk]	, [ cTudoOk]		, [ cIniCpos]	,
						[ aAlter]				, [ nFreeze]	, [ nMax]			, [ cFieldOk]	,
						[ cSuperDel]			, [ cDelOk]		, [ oWnd]			, [ aPartHeader], 
						[ aParCols]				, [ uChange]	, [ cTela] 			)
*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ TudoOk     ºAutor    ³Vendas Clientes    º Data ³  29/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se todos os parâmetros OBRIGATÓRIOS foram            º±±
±±º          ³   preenchidos.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                       º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjWzPTdOK()
Local cAux			:= ""	//Variável auxiliar
Local cMsgErro	:= ""	//Mensagem de Erro
Local nI			:= 0	//Contador
Local nPos			:= 0	//Posição do Array
Local lRet			:= .T.	//Variável de retorno
Local lSTBPEnvXML:= STBPEnvXML()

AEval( aCols, {|x| x[1] := AllTrim(x[1])} )

For nI := 1 to Len(aCols)
	DO CASE
		Case aCols[nI][1] == "MV_LJPAFWS" .And. lSTBPEnvXML
			cAux := AllTrim(aCols[nI][2])
			
			If Empty(cAux)
				lRet := .F.
				cMsgErro += aCols[nI][1] + "Preencha com o WebService Válido para envio do XML (Fornecido pela SEFAZ) "
				cMsgErro += CRLF
			Else
				If !("?WSDL" $ Upper(cAux))
					aCols[nI][2] := cAux + "?WSDL" 
				EndIf
			EndIf

		Case aCols[nI][1] == "MV_LJCRPAF" .And. lSTBPEnvXML
			cAux := AllTrim(aCols[nI][2])
			
			If Empty(cAux)
				lRet := .F.
				cMsgErro += aCols[nI][1] + " - preencha com o código do Credenciamento do PAF na SEFAZ (Fornecido pela SEFAZ)"
				cMsgErro += CRLF
			Else
				If !(Len(cAux) > 0 .And. Len(cAux) < 16)
					lRet := .F.
					cMsgErro += aCols[nI][1] + " - tamanho inválido para esse parâmetro"
					cMsgErro += CRLF
					
				ElseIf !(Val(cAux) > 0)
					lRet := .F.
					cMsgErro += aCols[nI][1] + " - O conteúdo desse parâmetro deve ser númerico positivo (maior que zero). Por favor ajuste o seu preenchimento"
					cMsgErro += CRLF	
				EndIf
			EndIf

		Case aCols[nI][1] == "MV_LJSNFEP"
			cAux := AllTrim(aCols[nI][2])
			
			If !Empty(cAux) .And. Len(cAux) > 3
				lRet := .F.
				cMsgErro += aCols[nI][1] + " - tamanho inválido. Deve possuir 3 caracteres. Exemplo: ABC"
				cMsgErro += CRLF
			EndIf
		
		Case Upper(AllTrim(aCols[nI][1])) == cCpoSenh
			
			//Por ser opcional a configuração, apenas alerto
			lRet := .T.
			cAux := AllTrim(aCols[nI][2])
			
			If Empty(cAux)
				cMsgErro := "Atenção, caso você possua um arquivo de Certificado na extensão .PFX, insira-o na pasta \Certs\ dentro da Protheus Data " +;
							"do seu ambiente e insira a senha deste arquivo para que sejam gerados os arquivos usados na geração do XML do PAF (Redução Z e Estoque)"
							
				Aviso("LjWzPTdOK", cMsgErro, {"OK"}, 2)
			EndIf
	END CASE
Next nI

If !lRet
	Aviso("LjWzPTdOK", STR0047 + CRLF + cMsgErro, {"OK"}, 2) //"Antes de prosseguir, corrija a(s) inconsistência(s) abaixo: "
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}LjWPArqPFX
Validação dos arquivos de certificado

@author  	Varejo
@version 	P12
@since   	14/11/2017
@return  	lRet , lógico, OK ? 
/*/
//--------------------------------------------------------
Static Function LjWPArqPFX(oGetData)
Local lRet := .T.
Local cAux := ""
Local cMsgErro:= ""
Local aColsAux:= {}

Default oGetData := NIL

If !ExistFunc("LPXPfxCvt")
	MsgAlert("Atualize seu PAF-ECF conforme Laudo INA0062019")
	lRet := .F.
Else
	aColsAux := aClone(oGetData:aCols)
	
	If Ascan( aColsAux, {|x| Atail(x) == .F.} ) > 0
	
		cAux := AllTrim(aColsAux[1][2])
	
		If !Empty(cAux) .And. MsgYesNo("Confirma Senha do Certificado ? (Arquivo .PFX)")
			lRet :=	LPXPfxCvt(,,,,cAux,.T.)
		EndIf
	EndIf
EndIf

Return lRet