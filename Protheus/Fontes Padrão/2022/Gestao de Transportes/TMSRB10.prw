#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSRB10.CH"

#DEFINE CRLF Chr(13)+Chr(10)

/*/-----------------------------------------------------------
{Protheus.doc} TMSRB10()
Recibo de Pagamento de Diaria

Uso: SIGATMS

@sample
//TMSRB10(aImpDia)

@author Paulo Henrique Corrêa Cardoso.
@since 24/01/2014
@version 1.0
-----------------------------------------------------------/*/
User Function TMSRB10(aImpDia)
Local cDesc1	:= STR0001		// "Este relatorio ira imprimir o recibo de pagamento de diarias"
Local cDesc2 	:= STR0002		// "pagamento de diarias."
Local cDesc3 	:= ""

Local cAliasArq := "DYX" 		// Recebe o Alias
Local cTitulo 	:= STR0005		// "Recibo de Diarias"	
Local aDiarias	:= {}			// Recebe as Diariasfi
Local cPergunt	:= ""			// Recebe o Pergunte
Local nCount	:= 0 			// Recebe o Contador
Local cViagem	:= ""			// Recebe a Viagem
Local cRota		:= ""			// Recebe a Rota	
Local cNomeMot	:= ""			// Recebe o Nome do Motorista	
Local lMenu		:= .T.			// Controla se o recibo foi chamado do menu ou na aprovação da Diaria
LOCAL cTamanho 	:= "M"			// Recebe o Tamanho da impressao
Local nTipo		:= 18
Local cNomeProg	:= "TMSRB10"
Local aCposProtg:= {}
Local aCpoAccess:= {'DA4_NOME'}
Local lLgpd		:= FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. ExistFunc('TMLGPDCpPr')

/*
Layout array aImpDia 

aImpDia := {	{[Codigo Diaria],[Item Diaria]} ,;
				{[Codigo Diaria],[Item Diaria]} ,;
		        {[Codigo Diaria],[Item Diaria]} }

*/

Default aImpDia   := {} 		// Recebe as diarias a serem impressas 

Private lAbortPrint := .F.
Private aLinha  := { }
Private nLastKey := 0
Private aReturn := {STR0003,1,STR0004, 1, 2, 1,"",1 } //"Zebrado"###"Administracao" cRelat
Private wnrel		:= "TMSRB10" 	// Recebe o nome do Relatorio
Private m_pag := 01

If lLgpd
	aCposProtg := TMLGPDCpPr(aCpoAccess, "DA4")
	If !Empty(aCposProtg)
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCposProtg )) < Len(aCposProtg)
			Help(" ",1,STR0027,,,,) //"LGPD - Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Para mais informações contate o Administrador do sistema !!"
			Return
		EndIf	
	EndIf
	IIf(ExistFunc('FwPdLogUser'), FwPdLogUser(cNomeProg),) 
EndIf

SetEnableVias(.T.)

If !Empty(aImpDia)
	
	lMenu := .F.
	dbSelectArea("DYV")
	DYV->( dbSetOrder(1) )
	
	dbSelectArea("DYX")
	DYX->( dbSetOrder(1) )
	
	dbSelectArea("SE2")
	SE2->( dbSetOrder(1) )
	
	For nCount :=1 To Len(aImpDia)
		If DYX->( dbSeek( FWxFilial("DYX") + aImpDia[nCount][1]  + aImpDia[nCount][2]  ) )
			
			If SE2->( dbSeek( FWxFilial("SE2") + DYX->DYX_PRETIT + ALLTRIM(DYX->DYX_NUMTIT)) )
			    
			   	DYV->( dbSeek(FWxFilial("DYV") + aImpDia[nCount][1]) )
		    	cNomeMot :=  Posicione("DA4",1,FWxFilial("DA4") + DYV->DYV_CODMOT, "DA4_NOME")

			    If !Empty(DYV->DYV_VIAGEM)
			    	cViagem := DYV->DYV_VIAGEM 
			    	cRota 	 :=  Posicione("DTQ",2,FWxFilial("DTQ") + DYV->DYV_FILORI + DYV->DYV_VIAGEM,"DTQ_ROTA")          
			  	EndIf
			  	
			  	If DYX->DYX_VALTIT > 0
					AADD(aDiarias,{DYX->DYX_NUMREC,DYX->DYX_VALTIT,SE2->E2_MOEDA,cNomeMot,DYX->DYX_DATAPR,cViagem,cRota,ALLTRIM(DYX->DYX_NUMTIT)})
				EndIf
			EndIf
			
		EndIf
	Next nCount
	
Else
	cPergunt := "TMSRB10"	
	Pergunte(cPergunt,.T.)
	aDiarias := RB10Busc()
EndIf


wnrel := SetPrint(cAliasArq,wnrel,cPergunt,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,{},.F.,cTamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cAliasArq,,,cTamanho,aReturn[4])

If nLastKey == 27
	Return
Endif

nTipo := IIF(aReturn[4]==1,15,18)

RptStatus({|lEnd| TMSRB10IMP(@lEnd,wnrel,aDiarias,cTitulo,cTamanho,nTipo,cNomeProg)},cTitulo)

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSRB10IMP()
Imprime o recibo de Pagamento de Diaria

Uso: TMSRB10

@sample
//TMSRB10IMP(aDiarias)

@author Paulo Henrique Corrêa Cardoso.
@since 24/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function TMSRB10IMP(lEnd,wnrel,aDiarias,cTitulo,cTamanho,nTipo,cNomeProg)
Local lRet 		:= .F. 		// Recebe o retorno
Local nLinha 	:= 0		// Recebe a Linha de Impressao
Local cExtenso	:= ""		// Recebe o Valor por extenso
Local cExt1 	:= ""		// Recebe a primeira linha do valor por extenso
Local cExt2 	:= ""		// Recebe a segunda linha do valor por extenso
Local cIdioma	:= "" 		// Recebe o Idioma
Local cMoeda	:= ""		// Recebe a Moeda
Local nCount	:= 0 		// Recebe o Contador
Local nColuna	:= 50		// Recebe a Coluna
Local nCntVias	:= 0		// Recebe o contador de vias
Local nVias		:= 0  		// recebe o numero de vias que serão impressas
		
Default aDiarias := {}
Default cNomeProg:= ''		

nVias := GetNVias()

// Layout Retrato
If nTipo == 15
	nColuna := 25
EndIf

/*	[1]Numero do Recibo
	[2]Valor
	[3]Codigo da Moeda
	[4]Nome do Fornecedor
	[5]Data de Aprovação
*/



For nCount := 1 To Len(aDiarias)
	
	nMoeda :=  aDiarias[nCount][3]
	cMoeda := SuperGetMv ( "MV_SIMB" + StrZero(Max(1,nMoeda),1), ,1  ) 

	
	For nCntVias := 1 To nVias
	
		IF lEnd
			@Prow()+1,001 PSAY OemToAnsi(STR0006) //"CANCELADO PELO OPERADOR"
			Exit
		EndIF
		
		If MOD(nCntVias,2)> 0 
			// Imprime Cabeçalho
			nLinha := 0
			Cabec(cTitulo,"","",cNomeProg,cTamanho,nTipo)
			
			nLinha += 6
		EndIf
		
		nLinha += 3
		@ nLinha,nColuna PSAY __PrtLeft(SM0->M0_NOME,.T.)		       		    // Empresa
		@ nLinha,nColuna + 65 PSAY __PrtRight(STR0007 + DTOC(dDataBase),.T.)	// "Data Emissao: "
		
		nLinha++
		@ nLinha,nColuna PSAY __PrtCenter(STR0008 + aDiarias[nCount][1])	// "Recibo de Despesa - Nro: "
		
		nLinha++
		@ nLinha,nColuna PSAY __PrtCenter(STR0009 + aDiarias[nCount][8])	// Nro Titulo:  
		
		cValor := cMoeda+" "+ AllTrim(Transform(aDiarias[nCount][2],PesqPict("DYX","DYX_VLRTOT",19,1)))
	
		nLinha += 2
		@ nLinha ,nColuna + 65  PSAY __PrtRight(cValor,.T.)
		
		
		If FwRetIdiom() == "pt-br"
			cIdioma := "1"
		ElseIf FwRetIdiom() == "es"
			cIdioma := "2"
		ElseIf  FwRetIdiom() == "en"
			cIdioma := "3"
		EndIf
	
		cExtenso := Extenso(aDiarias[nCount][2],,nMoeda,,cIdioma )
		
		TMSRB10EXT(cExtenso,@cExt1,@cExt2)
		
		nLinha += 3
		@nLinha,nColuna + 10 PSAY  __PrtLeft(STR0010 + DTOC(aDiarias[nCount][5])+ STR0011 + Alltrim(cExt1) + ;
		iif(Empty(cExt2),".","") ,.T.) //"Recebi em "###" a quantia de ### "
		
	
		If !Empty(cExt2)
			nLinha++
			@nLinha,nColuna PSAY  __PrtLeft(ALLTRIM(cExt2) + "." ,.T.)		
		Endif	
		
		nLinha++
	
		@nLinha,nColuna PSAY __PrtLeft( STR0012 + Iif(!Empty(aDiarias[nCount][6]), STR0025 + aDiarias[nCount][6] ,"")  +; //"Este valor refere-se a Despesas de Diárias." ###" viagem:"
		 Iif(!Empty(aDiarias[nCount][7]),STR0026 + aDiarias[nCount][7],"") + " ." , .T.) //" - rota:" 
	
		nLinha+= 6
		@nLinha,nColuna PSAY __PrtCenter(Replicate("-",Len(aDiarias[nCount][4])+40))
		nLinha++
		@nLinha,nColuna PSAY __PrtCenter(aDiarias[nCount][4])
		nLinha += 10
		@nLinha,nColuna PSAY __PrtCenter(Replicate("-",250))
		nLinha += 5
		
	Next nCntVias
	
Next nCount

SET DEVICE TO SCREEN

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} TMSRB10EXT()
Quebra o valor por extenso

Uso: TMSRB10

@sample
//TMSRB10EXT(cExtenso,cExt1,cExt2)

@author Paulo Henrique Corrêa Cardoso.
@since 24/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function TMSRB10EXT(cExtenso,cExt1,cExt2)
Local nLoop := 0

cExt1 := SubStr (cExtenso,1,39) // 1.a linha do extenso
nLoop := Len(cExt1)

While .T.
	If Len(cExtenso) == Len(cExt1)
		Exit
	EndIf

	If SubStr(cExtenso,Len(cExt1),1) == " " 
		Exit
	EndIf

	cExt1 += SubStr( cExtenso,nLoop + 1, 1 )
	nLoop ++
Enddo

cExt2 := SubStr(cExtenso,Len(cExt1)+1,80) // 2.a linha do extenso
IF !Empty(cExt2)
	cExt1 := StrTran(cExt1," ","  ",,39-Len(cExt1))
Endif

Return

/*/-----------------------------------------------------------
{Protheus.doc} RB10Busc()
Busca apartir dos parametros

Uso: TMSRB10

@sample
//RB10Busc()

@author Paulo Henrique Corrêa Cardoso.
@since 27/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function RB10Busc()
Local aRet := {}					// Recebe o Retorno
Local cAliasDYX  := GetNextAlias()	// Recebe o Proximo alias disponivel
Local cQuery	 := ""				// Recebe a Query	
Local cNumRecIni := ""				// Recebe o Numero do Recibo Inicial
Local cNumRecFim := ""				// Recebe o Numero do Recibo Final
Local cDatAprIni := ""				// Recebe a data de Aprovação Inicial
Local cDatAprFim := ""				// Recebe a data de Aprovação Final
Local cCodMotIni := ""				// Recebe o Fornecedor Inicial
Local cCodMotFim := ""				// Recebe o Fornecedor Final
Local cViagem	 := ""				// Recebe a Viagem
Local cRota		 := ""				// Recebe a Rota
Local cNomeMot	 := ""				// Recebe o Nome do Motorista

cNumRecIni := ALLTRIM(MV_PAR01)
cNumRecFim := ALLTRIM(MV_PAR02)
cDatAprIni := ALLTRIM(DTOS(MV_PAR03))
cDatAprFim := ALLTRIM(DTOS(MV_PAR04))
cCodMotIni := ALLTRIM(MV_PAR05)				
cCodMotFim := ALLTRIM(MV_PAR06)	

dbSelectArea("DYV")
DYV->( dbSetOrder(1) )

//Busca os itens para a Impressão
		
cQuery += " SELECT    DYX_IDCDIA													"+ CRLF
cQuery += "	 		, DYX_NUMREC 													"+ CRLF
cQuery += "	    	, DYX_VALTIT													"+ CRLF
cQuery += "		    , E2_NUM														"+ CRLF
cQuery += "		    , E2_MOEDA														"+ CRLF
cQuery += "			, E2_NOMFOR														"+ CRLF
cQuery += "			, DYX_DATAPR													"+ CRLF
cQuery += " FROM " + RetSqlName( 'DYV' )+ " DYV										"+ CRLF
cQuery += " INNER JOIN " + RetSqlName( 'DYX' )+ " DYX								"+ CRLF
cQuery += " ON  DYX_IDCDIA = DYV_IDCDIA												"+ CRLF
cQuery += " INNER JOIN " + RetSqlName( 'SE2' )+ " SE2								"+ CRLF
cQuery += " ON  DYX_PRETIT = E2_PREFIXO												"+ CRLF
cQuery += "     AND DYX_NUMTIT = E2_NUM												"+ CRLF
cQuery += " WHERE   DYX.D_E_L_E_T_ = ' '											"+ CRLF
cQuery += "		AND SE2.D_E_L_E_T_ = ' '											"+ CRLF
cQuery += "		AND DYV.D_E_L_E_T_ = ' '											"+ CRLF
cQuery += "		AND E2_FILIAL = '"+ FWxFilial("SE2") +"'							"+ CRLF
cQuery += "		AND DYX_FILIAL = '"+ FWxFilial("DYX") +"'							"+ CRLF
cQuery += "		AND DYV_FILIAL = '"+ FWxFilial("DYV") +"'							"+ CRLF
cQuery += "		AND DYX_STATUS = '3'												"+ CRLF
cQuery += "		AND DYX_VALTIT > 0 													"+ CRLF
cQuery += "		AND DYX_NUMREC  BETWEEN '"+ cNumRecIni +"' AND '"+ cNumRecFim +"'	"+ CRLF
cQuery += "		AND DYX_DATAPR	BETWEEN '"+ cDatAprIni +"' AND '"+ cDatAprFim +"'	"+ CRLF
cQuery += "		AND DYV_CODMOT	BETWEEN '"+ cCodMotIni +"' AND '"+ cCodMotFim +"'	"+ CRLF

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDYX, .F., .T. )

While !(cAliasDYX)->(EOF())
	 
	 // Busca a Viagem e Rota da Diaria	
 	 DYV->( dbSeek( FWxFilial("DYV") + (cAliasDYX)->DYX_IDCDIA ) )
 	 cNomeMot := Posicione("DA4",1,FWxFilial("DA4") + DYV->DYV_CODMOT, "DA4_NOME")
 	 
	 If !Empty(DYV->DYV_VIAGEM)
     	 cViagem  := DYV->DYV_VIAGEM 
     	 cRota 	  := Posicione("DTQ",2,FWxFilial("DTQ") + DYV->DYV_FILORI + DYV->DYV_VIAGEM,"DTQ_ROTA")	 
	 EndIf
	 
	 // Adiciona no Arry de Retorno
	 AADD(aRet,{(cAliasDYX)->DYX_NUMREC,;
	 			(cAliasDYX)->DYX_VALTIT,;
	 			(cAliasDYX)->E2_MOEDA,;
	 			cNomeMot,;
	 			SToD((cAliasDYX)->DYX_DATAPR),;
	 			cViagem,;
	 			cRota,;
	 			Alltrim( (cAliasDYX)->E2_NUM ) } )
	 			
	(cAliasDYX)->(DbSkip())
EndDo

(cAliasDYX)->(dbCloseArea())

Return aRet
