#INCLUDE "PROTHEUS.CH"

static lPT1200A := ExistBlock("PT1200A")
static lExPlVTb := ExistBlock("PLSVATBI")

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA1200
Exportacao do PTU A1200 - Pacotes
@author Lucas Nonato
@since 11/05/2016
@version P12
/*/
//-------------------------------------------------------------------

Function PLSUA1200
Local cPerg := "PLSU1200"
    
If Pergunte(cPerg,.T.)
	cCodLay   	:= mv_par01
	cUnimed   	:= mv_par02	
	cDirNov  	:= mv_par03
	cPacDe  	:= mv_par04
	cPacAte   	:= mv_par05 	
	cEmpDe    	:= mv_par06
	cEmpAte   	:= mv_par07
	cDtNegG		:= mv_par08
	

	If 'A1200' $ AllTrim(cCodLay)
		Processa({||GeraA1200()},"Geração do arquivo do PTU A1200","Processando...",.T.)
	EndIf	
EndIf

Return  
     
//-------------------------------------------------------------------
/*/{Protheus.doc} GeraA1200
Gera arquivo A1200 
@author Lucas Nonato
@since 11/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function GeraA1200()  
Local aStru201   		:= {}  
Local aStru202   		:= {} 
Local aStru203   		:= {}
Local aStru204   		:= {}
Local aStru205   		:= {}
Local aStru210   		:= {}
Local aStru211   		:= {}
Local aStru215   		:= {}
Local cOpcAnt			:= ""
Local cR201      		:= ""            
Local cR202      		:= ""       
Local cR203      		:= ""  
Local cR204      		:= ""  
Local cR205		 		:= ""
Local cR210      		:= ""  
Local cR211      		:= ""   
Local cR215      		:= ""
Local cSeq		 		:= "01"
Local oTempR01			:= nil
Local oTempR02			:= nil
Local oTempR03			:= nil
Local oTempR04			:= nil
Local oTempR05			:= nil
Local oTempR10			:= nil
Local oTempR11			:= nil
Local oTempR15			:= nil
local cCodInt			:= PlsIntPad()
local cTpTab			:= ''
local aPctInc			:= {}
local nFor				:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Variaveis registro 201	     			                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCD_UNI_ORI 		:= ""
Local cDT_GERACAO 		:= ""
Local cTP_CARGA	 		:= ""
Local cTP_INF			:= ""
Local cNR_VER_TRA		:= ""
local cDatEsc			:= ''
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Variaveis registro 202	     			                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCD_PACOTE 		:= ""
Local cNM_PACOTE 		:= ""
Local cDT_NEGOCIACAO 	:= ""
Local cDT_PUBLICACAO 	:= ""
Local cTP_ACOMODACAO 	:= ""
Local cTP_PACOTE 		:= ""
Local cCD_ESPEC 		:= ""
Local cDT_INI_VIGENCIA 	:= ""
Local cDT_FIM_VIGENCIA 	:= ""
Local cTP_INTERNACAO	:= ""        
Local cVL_TAXAS 		:= 0
Local cVL_DIARIAS 		:= 0
Local cVL_GASES 		:= 0
Local cVL_OPME 			:= 0
Local cVL_MAT 			:= 0
Local cVL_MED 			:= 0
Local cVL_PROC  		:= 0
Local cVL_SOMA			:= 0
Local cVersao			:= ""
local cId_Anest			:= 'N'
local cId_Auxi			:= 'N'
local cId_OPME			:= 'N'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Variaveis registro 203	     			                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDS_OBSERV 		:= ""
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Variaveis registro 204	     			                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cTP_ITEM   		:= ""
Local cTP_TAB_PTU    	:= ""
Local cCD_SERVICO    	:= ""
Local cID_SERV  		:= ""
Local cID_HONOR   		:= "N"
Local cQT_SERV   		:= ""
Local cVL_SERV			:= ""
Local cDesc				:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Variaveis registro 205	     			                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cCD_UNI_PRE 		:= ""
Local cCD_PRE			:= ""
Local cNM_PREST 		:= ""
Local cCNES				:= ""
Local cCGC				:= ""
local cReajuste			:= ""
local cNomeArq			:= ""
local cArqPesq			:= ""
local aArquivos			:= {}
local cNomeZip			:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Variaveis registro 215	     			                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Local cSqlBLZ 	:= ""
//Local cSqlBLY	:= ""
Local nReg201 			:= 0
Local nReg202 			:= 0
Local nReg203 			:= 0
Local nReg204 			:= 0
Local nReg205 			:= 0
Local nReg210 			:= 0
Local nReg211 			:= 0

local lGrvDad			:= .t.
local cMatricUsr		:= ''
local aDadRda			:= {}
local aDadUsr			:= {}
local cContChv			:= ''
local aPdeReal			:= {.f., ''}
local aValor			:= {}

Local lNewCmp			:= BLZ->(fieldPos("BLZ_TIPPAC")) > 0
Local lNewCmpIte		:= BLY->(FieldPos("BLY_DESPTU")) > 0
Local cTipRede			:= AllTrim(Str(0))

Local nLinha := 1
Local cLinSeq := ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//Procura o layout
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("DE9")
DE9->(DBSetOrder(1))
DE0->(DBSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Verifica se todos os campos foram informados                             
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCodLay).Or. Empty(cUnimed) .Or.  Empty(cPacAte) .Or. Empty(cDirNov) .Or. Empty(cEmpAte)
	MsgInfo("Preencha todos os campos.")		
	Return	PLSUA1200()
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Verifica se o Layout foi importado					                        	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !MsSeek(xFilial("DE9")+cCodLay)
	MsgStop("Layout "+cCodLay+" não encontrado.")
	Return
EndIF  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 201			                                 		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R201'))
aadd(aStru201,{"Campo" ,"C",DE0->DE0_TAMREG,0}) 

//--< Criação do objeto FWTemporaryTable >---
oTempR01 := FWTemporaryTable():New( "R01" )
oTempR01:SetFields( aStru201 )
oTempR01:AddIndex( "INDR01",{ "CAMPO" } )

if( select( "R01" ) > 0 )
	R01->( dbCloseArea() )
endIf

oTempR01:Create()
DbSelectArea("R01")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 202				                                 		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R202'))
aadd(aStru202,{"Chave","C",017,0})
aadd(aStru202,{"Campo" ,"C",DE0->DE0_TAMREG,0})  

//--< Criação do objeto FWTemporaryTable >---
oTempR02 := FWTemporaryTable():New( "R02" )
oTempR02:SetFields( aStru202 )
oTempR02:AddIndex( "INDR02",{ "CHAVE" } )

if( select( "R02" ) > 0 )
	R02->( dbCloseArea() )
endIf

oTempR02:Create()
DbSelectArea("R02")
R02->(DbSetorder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 203				                                 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R203'))
aadd(aStru203,{"Chave","C",017,0})
aadd(aStru203,{"Campo" ,"C",DE0->DE0_TAMREG,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR03 := FWTemporaryTable():New( "R03" )
oTempR03:SetFields( aStru203 )
oTempR03:AddIndex( "INDR03",{ "CHAVE" } )

if( select( "R03" ) > 0 )
	R03->( dbCloseArea() )
endIf

oTempR03:Create()
DbSelectArea("R03")
R03->(DbSetorder(1))
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 204				                                 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R204'))
aadd(aStru204,{"Chave","C",017,0})
aadd(aStru204,{"Campo" ,"C",DE0->DE0_TAMREG,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR04 := FWTemporaryTable():New( "R04" )
oTempR04:SetFields( aStru204 )
oTempR04:AddIndex( "INDR04",{ "CHAVE" } )

if( select( "R04" ) > 0 )
	R04->( dbCloseArea() )
endIf

oTempR04:Create()
DbSelectArea("R04")
R04->(DbSetorder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 205    		                                 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R205'))
aadd(aStru205,{"Chave","C",017,0})
aadd(aStru205,{"Campo" ,"C",DE0->DE0_TAMREG,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR05 := FWTemporaryTable():New( "R05" )
oTempR05:SetFields( aStru205 )
oTempR05:AddIndex( "INDR05",{ "CHAVE" } )

if( select( "R05" ) > 0 )
	R05->( dbCloseArea() )
endIf

oTempR05:Create()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 210				                                 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R210'))
aadd(aStru210,{"CHAVE","C",017,0})
aadd(aStru210,{"CAMPO" ,"C",DE0->DE0_TAMREG,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR10 := FWTemporaryTable():New( "R10" )
oTempR10:SetFields( aStru210 )
oTempR10:AddIndex( "INDR10",{ "CHAVE" } )

if( select( "R10" ) > 0 )
	R10->( dbCloseArea() )
endIf

oTempR10:Create()
DbSelectArea("R10")
R10->(DbSetorder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 211				                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R211'))
aadd(aStru211,{"CHAVE","C",017,0})
aadd(aStru211,{"CAMPO" ,"C",DE0->DE0_TAMREG,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR11 := FWTemporaryTable():New( "R11" )
oTempR11:SetFields( aStru211 )
oTempR11:AddIndex( "INDR11",{ "CHAVE" } )

if( select( "R11" ) > 0 )
	R11->( dbCloseArea() )
endIf

oTempR11:Create()
DbSelectArea("R11")
R11->(DbSetorder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Cria arquivo temporario 215				                                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DE0->(MsSeek(xFilial("DE0")+cCodLay+'R215'))
aadd(aStru215,{"CAMPO" ,"C",DE0->DE0_TAMREG,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR15 := FWTemporaryTable():New( "R15" )
oTempR15:SetFields( aStru215 )
oTempR15:AddIndex( "INDR15",{ "CAMPO" } )

if( select( "R15" ) > 0 )
	R15->( dbCloseArea() )
endIf

oTempR15:Create()
DbSelectArea("R15")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                      
// Setando os indices que serao utilizados										
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(DbGoTop()) 
BLZ->(DbSetOrder(1))//BTS_FILIAL + BTS_MATVID

BRP->(DbSetOrder(1))//BRP_FILIAL + BRP_CODIGO
BG9->(DbSetOrder(1))//BG9_FILIAL + BG9_CODINT + BG9_CODIGO + BG9_TIPO
BI3->(DbSetOrder(1))//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO   
BI4->(DbSetOrder(1))//BI4_FILIAL + BI4_CODACO
BI6->(DbSetOrder(1))//BI6_FILIAL + BI6_CODSEG
BA3->(DbSetOrder(1))//BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB
BIL->(DbSetOrder(1))//BIL_FILIAL + BIL_CODIGO + BIL_VERSAO + DTOS(BIL_DATINI)
BF7->(DbSetOrder(1))//BF7_FILIAL + BF7_CODORI      
BG3->(DbSetOrder(1))//BG3_FILIAL + BG3_CODBLO
BG1->(DbSetOrder(1))//BG1_FILIAL + BG1_CODBLO + BG1_TIPBLO
BC9->(DbSetOrder(1))//BC9_FILIAL + BC9_CEP
B18->(DbSetOrder(1))//B18_FILIAL + B18_CODIGO

//Percorrer todas as RDA's selecionadas 
QryPrestRng(cEmpDe,cEmpAte)   
QRYPREST->( DbGoTop() )

cCD_UNI_ORI 	:= cCodInt
cDT_GERACAO 	:= DToS(Date())
cTP_CARGA		:= '1'
cTP_INF			:= '1'
cNR_VER_TRA		:= '08'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Gravacao dos registros no arquivo temporario 			                 	
// ------------------------------------------------------------------------ 
// Grava R201 do arquivo temporario...						                 	
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
cLinSeq := Right(Space(8) + Alltrim(Str(nLinha)), 8)
nLinha++
cR201 := cLinSeq  					// 01 Sequencial
cR201 += Space(3)   				// 02 Tipo de Registro  
cR201 += cCD_UNI_ORI				// 03 Codigo UNIMED que gerou o arquivo
cR201 += cDT_GERACAO				// 04 Data de geração do arquivo de envio
cR201 += cTP_CARGA	             	// 05 Tipo de carga
cR201 += cTP_INF		         	// 06 Tipo de Informação
cR201 += cNR_VER_TRA             	// 07 Numero da versão da transacao

R01->(Reclock("R01",.T.))
	R01->Campo  := cR201
R01->(MsUnlock())  
nReg201 ++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Grava R202 do arquivo temporario...						                 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
BLZ->(dbSetOrder(1)) // BLZ_FILIAL, BLZ_CODINT, BLZ_CODRDA, BLZ_CODPAD, CODPAC
BAU->(dbSetOrder(1)) // BAU_FILIAL, BAU_CODIGO

//***********Pesquisa usuário de intercambio para valorização***************
If BA1->(MsSeek(xfilial("BA1") + cCodInt + Getnewpar("MV_PLSGEIN", "0050")))
	While !(Empty(BA1->BA1_DATBLO))
		BA1->(dbSkip())
	endDo
	cMatricUsr := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREg + BA1_DIGITO)
endIf
aDadUsr := PLSDADUSR(cMatricUsr, "1", .f., ddatabase, , , nil, nil)
//***************************************************************************

While !QRYPREST->(EOF())

	QryPacotes(cCodInt, QRYPREST->CODRDA, cPacDe, cPacAte)
	QRYPACOTE->( DbGoTop() )
	aDadRda := PLSDADRDA(cCodInt, QRYPREST->CODRDA, "1", dDataBase,"","")

	if !(aDadRda[1])
		QRYPREST->(dbSkip())
		loop
	endif

	While !QRYPACOTE->(eof())
		cCD_PACOTE		:= Substr(QRYPACOTE->CODPAC,1,8)
		cNM_PACOTE		:= Posicione("BR8",1,xFilial("BR8")+QRYPACOTE->(CODPAD+CODPAC),"BR8_DESCRI")  
		cDatEsc			:= iif(QRYPACOTE->TAB != "BLZ" .and. !empty(cDtNegG) .and. dtos(cDtNegG) >=  QRYPREST->INCLUSAO, dtos(cDtNegG), QRYPREST->INCLUSAO )   
		cDT_NEGOCIACAO 	:= iif( QRYPACOTE->TAB == "BLZ", QRYPACOTE->DTNEGO, cDatEsc )
		cDT_PUBLICACAO 	:= iif( QRYPACOTE->TAB == "BLZ", QRYPACOTE->DTPUBL,space(8))
	
		If lNewCmp
			cId_Anest		:= IIF(QRYPACOTE->IDANES == "1", "S", "N")
			cId_Auxi		:= IIF(QRYPACOTE->IDAUX == "1", "S", "N")
			cID_HONOR		:= IIF(QRYPACOTE->IDHON == "1", "S", "N")
			cCD_ESPEC 		:= GetEspPTU(QRYPACOTE->ESPEC)
			cTP_PACOTE 		:= QRYPACOTE->TIPPAC
			If !(empty(QRYPACOTE->TIPACO))
				cTP_ACOMODACAO 	:= QRYPACOTE->TIPACO
			endIF
			If !(empty(QRYPACOTE->TIPINT))
				cTP_INTERNACAO	:= QRYPACOTE->TIPINT
			endIf
		else
			cTP_ACOMODACAO 	:= "C"
			cID_HONOR		:= 'N'
			cId_Anest		:= 'N'
			cId_Auxi		:= 'N'
			cCD_ESPEC 		:= '99'
			cTP_INTERNACAO	:= '2'
			cTP_PACOTE 		:= '04'
		endIf

		cId_OPME		:= 'N'
		cCD_UNI_PRE		:= cCodInt

		cTpTab 	:= "BLY"
		cContChv:= QRYPREST->CODRDA

		//***********Autorização e valorizaçãodo pacote*****************************
		aPdeReal := {.f., ''}
		aValor	 := {}

		aPdeReal := PLSTratExe(Alltrim(QRYPACOTE->CODPAD), allTrim(QRYPACOTE->CODPAC), .t., .t., .f., "2", "",{}, aDadRDA, aDadUsr,, dDatabase,,,,,,,,,)

		If !aPdeReal[1] 
			QRYPACOTE->(dbSkip())
			loop
		endIf
		
		aValor := PLSCALCEVE( Alltrim(QRYPACOTE->CODPAD), allTrim(QRYPACOTE->CODPAC),SubStr(DtoS(dDatabase), 5, 2),SubStr(DtoS(dDatabase), 1, 4),cCodInt,QRYPREST->CODRDA,;
		                      "","",'001', 1,dDatabase,IIF(len(aDadUsr)>=48,aDadUsr[48],""),"","",/*nValApr*/,aDadUsr,"",nil,"","",nil,nil,,{},.F.,"",0,{},.F.,dDatabase,,{}, )
                
	    If aValor[2] <= 0
	        QRYPACOTE->(dbSkip())
	        loop
	    endIf		
		
		lGrvDad	:= aScan(aPctInc,{|x| Alltrim(x[1]) == Substr(QRYPACOTE->CODPAC,1,8) .and. (x[2]) == cTpTab + cContChv}) == 0
		
		if lGrvDad
			aadd(aPctInc, {Substr(QRYPACOTE->CODPAC,1,8),cTpTab + cContChv})
		endif	

		if lGrvDad
			QryItemPacote(cTpTab, cCodInt, QRYPREST->CODRDA, QRYPACOTE->CODPAD, QRYPACOTE->CODPAC)
			QRYITENS->( DbGoTop() )
			
		cDT_INI_VIGENCIA  := QRYPACOTE->VIGEINI

		IF	cDT_INI_VIGENCIA < cDT_NEGOCIACAO
			cDT_INI_VIGENCIA := cDT_NEGOCIACAO
		endIf

		iif(!Empty(QRYPACOTE->VIGEFIM),cDT_FIM_VIGENCIA := QRYPACOTE->VIGEFIM,cDT_FIM_VIGENCIA := "")

			cVersao		:= QRYPACOTE->(VERSAO)
			
			cVL_PROC 	:= 	SomaProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, '0',  cTpTab, QRYPACOTE->CODPAD, cCodInt) 	
			cVL_MAT 	:= 	SomaProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, '1',  cTpTab, QRYPACOTE->CODPAD, cCodInt)
			cVL_MED 	:= 	SomaProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, '2',  cTpTab, QRYPACOTE->CODPAD, cCodInt) 	
			cVL_TAXAS 	:= 	SomaProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, '3',  cTpTab, QRYPACOTE->CODPAD, cCodInt) 	
			cVL_DIARIAS := 	SomaProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, '4',  cTpTab, QRYPACOTE->CODPAD, cCodInt) 	
			cVL_OPME 	:= 	SomaProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, '5',  cTpTab, QRYPACOTE->CODPAD, cCodInt) 	
			cVL_GASES 	:= 	SomaProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, '7',  cTpTab, QRYPACOTE->CODPAD, cCodInt) 
			
			cVL_SOMA := cVL_PROC + cVL_MAT + cVL_MED + cVL_TAXAS + cVL_DIARIAS + cVL_OPME + cVL_GASES

			if cVL_PROC > 0 .AND. !lNewCmp
				cID_HONOR	:= 'S'
				cId_Anest	:= 'S'
				cId_Auxi	:= 'S'
			endif

			if cVL_OPME > 0
				cId_OPME	:= 'S'	
			endif

			cOpcAnt := ''
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Grava R202 do arquivo temporario...						                 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			cLinSeq := Right(Space(8) + Alltrim(Str(nLinha)), 8)
			nLinha++
			cR202 := cLinSeq												// 01 Sequencial
			cR202 += Space(3)												// 02 Tipo de Registro
			cR202 += PadR(cCD_PACOTE,8) 									// 03 Codigo do Pacote
			cR202 += Space(60)/*PadR(SubStr(cNM_PACOTE,1,60),60)*/ 			// 04 Nome do Pacote
			cR202 += Space(4)												// 05 Codigo da Unimed do Prestador
			cR202 += Space(8)          										// 06 Codigo do Prestador
			cR202 += Space(40)												// 07 Nome do Prestador		
			cR202 += PadR(cDT_NEGOCIACAO,8) 	       						// 08 Data de Negociacao do Pacote
			cR202 += PadR(cDT_PUBLICACAO,8) 	     						// 09 Data de Publicacao do Pacote
			cR202 += PadR(cTP_ACOMODACAO,2) 	    						// 10 Tipo de acomodacao
			cR202 += StrZero(val(cTP_PACOTE),2)						 		// 11 Tipo de Pacote
			cR202 += PadR(cCD_ESPEC,2) 			  							// 12 Codigo da Especialidade Medica
			cR202 += PadR(cDT_INI_VIGENCIA,8) 	      						// 13 Data de Inicio da Vigencia do Pacote
			cR202 += PadR(cDT_FIM_VIGENCIA,8) 	      						// 14 Data de Fim da Vigencia do Pacote
			cR202 += StrZero(Val(cTP_INTERNACAO),1)	    	  				// 15 Tipo de Internação
			//Trunca na segunda casa decimal, multiplica por 100 pra tirar pontuação e completa os zeros À esquerda por ser numérico
			cR202 += StrZero( NoRound(cVL_TAXAS,2) * 100, 14)  			   	// 16 Valor total de Taxas  
			cR202 += StrZero( NoRound(cVL_DIARIAS,2) * 100, 14)		   		// 17 Valor total de diarias  
			cR202 += Space(14)/*StrZero( NoRound(cVL_GASES,2) * 100, 14)*/  // 18 Valor total de gases    
			cR202 += StrZero( NoRound(cVL_MAT,2) * 100, 14)  			   	// 19 Valor total de materiais
			cR202 += StrZero( NoRound(cVL_MED,2) * 100, 14) 			   	// 20 Valor total de medicamentos
			cR202 += StrZero( NoRound(cVL_PROC,2) * 100, 14)  			   	// 21 Valor total de procedimentos  
			cR202 += StrZero( NoRound(cVL_OPME,2) * 100, 14)  			   	// 22 Valor total de OPMEs
			cR202 += StrZero( NoRound(cVL_SOMA,2) * 100, 14)  			   	// 23 Valor Total do Pacote
			
			cR202 += PadR(cID_HONOR,1)  			   						// 24 Identifica se o honorário está incluso
			cR202 += cTipRede												// 25 Tipo de Rede conforme Manual do Intercâmbio Nacional
			cR202 += StrZero(Val(IIF(empty(cVersao), "0", cVersao)),3)  	// 26 Versão do Pacote
			cR202 += PadR(cId_OPME,1)  			   							// 27 Identifica se possui OPME
			cR202 += PadR(cId_Anest,1)  			   						// 28 Indica se inclui participação do anestesista
			cR202 += PadR(cId_Auxi,1)  			   							// 29 Indica se inclui participação do auxiliar
			
			R02->(Reclock("R02",.T.))
				R02->Chave := PadR(cCD_PACOTE,8) + PadR(cTpTab,3) + cContChv
				R02->Campo  := cR202
			R02->(MsUnlock())
			nReg202 ++ 
			
			BLZ->(dbCloseArea())
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Grava R203 do arquivo temporario...						                 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			BR8->(dbSetOrder(1))
			If BR8->(dbSeek(xFilial('BR8') + QRYPACOTE->CODPAD + cCD_PACOTE))  
				cDS_OBSERV := BR8->BR8_INFPRO
			EndIf
			If !Empty(cDS_OBSERV)
				cLinSeq := Right(Space(8) + Alltrim(Str(nLinha)), 8)
				nLinha++
				cR203 :=	cLinSeq						   		// 01 Sequencial
				cR203 += 	Space(3)						   	// 02 Tipo de Registro
				cR203 +=  cCD_PACOTE 							// 03 Codigo do Pacote    
				cR203 +=  cDS_OBSERV 							// 04 Observacao
				
				R03->(Reclock("R03",.T.))
					R03->Chave := PadR(cCD_PACOTE,8) + PadR(cTpTab,3) + cContChv
					R03->Campo  := cR203
				R03->(MsUnlock())    
				nReg203 ++
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Grava R204 do arquivo temporario...						                 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			While !QRYITENS->(Eof()) .AND. cTP_INF == '1' 
				If cOpcAnt == QRYITENS->CODPRO // Caso tenha dois procedimentos iguais gravo apenas um.
					QRYITENS->(dbSkip())
					loop
				EndIf
				Do Case
					Case QRYITENS->TIPO = '0'	//Procedimentos 
						cTP_ITEM  := 	'6' 		
					Case QRYITENS->TIPO = '1'   	//Materiais
						cTP_ITEM  := 	'4'			
					Case QRYITENS->TIPO = '2'   	//Medicamentos
						cTP_ITEM  := 	'5'			
					Case QRYITENS->TIPO = '3'   	//Taxas
						cTP_ITEM 		:= 	'1'  	
					Case QRYITENS->TIPO = '4'    //Diarias
						cTP_ITEM 		:= 	'2'		
					Case QRYITENS->TIPO = '7'    //Gases
						cTP_ITEM  	:= 	'3' 		
					Case QRYITENS->TIPO = '5'	//OPME 
						cTP_ITEM  := 	'7' 		
				EndCase
				
				If lNewCmpIte .AND. !(empty(QRYITENS->DESITE))
					cDesc := QRYITENS->DESITE
				else
					If BR8->(dbSeek(xFilial('BR8') + QRYITENS->CODPAD + AllTrim(QRYITENS->CODPRO)))  
						cDesc := BR8->BR8_DESCRI					
						cTP_TAB_PTU := PtTpTabTus(.T.,lExPlVTb) 					
					Else
						cDesc := "PROCEDIMENTO NAO ENCONTRADO"
					EndIf
				endIf
				
				If QRYITENS->PRINCI == '0' .or. Empty(QRYITENS->PRINCI)
					cID_SERV 	:= '2'
				Elseif QRYITENS->PRINCI == '2'
					cID_SERV 	:= '3'
				Else
					cID_SERV 	:= '1'
				EndIf
				
				cCD_SERVICO 	:= QRYITENS->CODPRO
				
				cQT_SERV   	:= getQtdProc(QRYPREST->CODRDA, QRYPACOTE->CODPAC, QRYITENS->CODPRO, cTpTab, QRYPACOTE->CODPAD, cCodInt)
				
				If !Empty(QRYITENS->VALCH)
					cVl_Tot_Serv	:= QRYITENS->VALCH			
				Else
					cVl_Tot_Serv	:= QRYITENS->VALFIX
				EndIf

				cVL_SERV := (cVl_Tot_Serv / val(cQT_SERV)) * 10000 //multiplica por 10000 pq o cQT_SERV vem multiplicado, daí isso anula o efeito extra da divisão
				cUnidMed	 := '000'
				If BA8->(FieldPos("BA8_UNMEDI")) > 0 
					BA8->(DbSetOrder(3))//BA8_FILIAL+BA8_CODPAD+BA8_CODPRO
					If BA8->(DbSeek(xFilial("BA8")+ QRYITENS->CODPAD + QRYITENS->CODPRO)) .And. !Empty(BA8->BA8_UNMEDI)
						cUnidMed  := Strzero(Val(BA8->BA8_UNMEDI),3)  
					EndIf				
				EndIf 
				cLinSeq := Right(Space(8) + Alltrim(Str(nLinha)), 8)
				nLinha++
				cR204 := cLinSeq					    				// 01 Sequencial
				cR204 += Space(3)					    	   			// 02 Tipo de Registro
				cR204 += PadR(cTP_ITEM,1)					    		// 03 Tipo do Item
				cR204 += PadR(cTP_TAB_PTU,1)      	            		// 04 Tipo de Tabela utilizado no Servico Medico 
				cR204 += Space(8)      	            					// 05 Reservado r7    
				cR204 += PadR(cID_SERV,1)                  				// 06 Indica se o Serviço é o Principal
				cR204 += Space(1)   	                 				// 07 Reservado   
				cR204 += Space(1)                     					// 08 Reservado
				cR204 += space(8)   	    							// 09 reservado
				cR204 += StrZero( NoRound(cVL_SERV,2) * 100, 14)		// 10 Valor do Servico
				cR204 += PadR(cDesc,80)									// 11 Descricao do Servico
				cR204 += StrZero( NoRound(cVl_Tot_Serv,2) * 100, 14)	// 12 Valor total do serviço - Valor unitário (VL_UNI_SERV) x quantidade do serviço
				cR204 += Padl(cValToChar(cUnidMed),3,'0')				// 13 Unidade de Medida
				cR204 += Padl(alltrim(SubStr(cCD_SERVICO,1,10)),10,'0') // 14 Codigo do Servico
				cR204 += cQT_SERV                            			// 15 Quantidade de um servico (foi movido pra cá na versão 13 do PTU)
				
				R04->(Reclock("R04",.T.))
					R04->Chave := PadR(cCD_PACOTE,8) + PadR(cTpTab,3) + cContChv
					R04->Campo  := cR204
				R04->(MsUnlock())    
				nReg204 ++ 
				cOpcAnt := QRYITENS->CODPRO
				QRYITENS->(dbSkip())	
			EndDo
		endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// Grava R205 do arquivo temporario...						                 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		if cCD_PACOTE == Substr(QRYPACOTE->CODPAC,1,8)
			cCD_PRE         := AllTrim(QRYPREST->CODRDA)
			If BAU->(MsSeek(xFilial("BAU")+QRYPREST->CODRDA))
				cNM_PREST	:= BAU->BAU_NOME
				cCNES		:= iif( !empty(BAU->BAU_CNES), BAU->BAU_CNES, '9999999' )  
				cCGC		:= BAU->BAU_CPFCGC
				cReajuste	:= iif( QRYPACOTE->REAJUS == "1", "S", "N")
				cNomeArq	:= alltrim(QRYPACOTE->ARQREA)
				cLinSeq := Right(Space(8) + Alltrim(Str(nLinha)), 8)
				nLinha++
				cR205 := cLinSeq							// 01 Sequencial
				cR205 += Space(3)							// 02 Tipo de Registro
				cR205 += PadR(cCD_UNI_PRE,4)				// 03 Código da Unimed do Prestador
				cR205 += StrZero(Val(cCD_PRE),8)			// 04 Código do Prestador
				cR205 += PadR(SubStr(cNM_PREST,1,70),70)	// 05 Nome do Prestador   
				cR205 += StrZero(Val(cCGC),15)				// 06 CNPJ ou CPF do Prestador
				cR205 += padr(cCNES,7)						// 07 Código Nacional de Estabelecimento de Saúde 
				cR205 += padr(cReajuste,1)					// 08 Indicador de Reajuste r7
				cR205 += padr(cNomeArq,29)					// 09 Identificação do anexo do reajuste do prestador para o pacote
				cArqPesq += iif( !empty(cNomeArq), cNomeArq + "-", "")
			EndIf
			
			If ( QRYPACOTE->TAB == "BLZ" .and. BLZ->(dbSeek(xFilial('BLZ') + cCD_UNI_PRE + cCD_PRE + QRYPACOTE->CODPAD + cCD_PACOTE  )) ) // IndexKey() ==> BLZ_FILIAL+BLZ_CODINT+BLZ_CODRDA+BLZ_CODPAD+BLZ_CODPRO
				BLZ->(Reclock("BLZ",.F.))
					BLZ->BLZ_EXPORT := '1'
					BLZ->BLZ_STATUS := '01'
				BLZ->(MsUnlock())		
			EndIf
			R05->(Reclock("R05",.T.))
				R05->Chave := PadR(cCD_PACOTE,8) + PadR(cTpTab,3) + cContChv
				R05->Campo  := cR205
			R05->(MsUnlock())  
			nReg205 ++ 
		endif
		QRYPACOTE->(dbSkip())
	EndDo
	QRYPREST->(dbSkip())
enddo	

Iif( Select('QRYPREST') > 0 , QRYPREST->(dbCloseArea()) , '' )
Iif( Select('QRYPACOTE') > 0, QRYPACOTE->(dbCloseArea()), '' )
Iif( Select('QRYITENS') > 0 , QRYITENS->(dbCloseArea()) , '' )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Grava R215 do arquivo temporario...						                 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
cLinSeq := Right(Space(8) + Alltrim(Str(nLinha)), 8)
nLinha++
cR215 := cLinSeq					   							// 01 Sequencial
cR215 += Space(3)						   						// 02 Tipo de Registro
cR215 += PadL(cValToChar(nReg202),5,"0")	           		// 03 Total de registros 202
cR215 += PadL(cValToChar(nReg203),5,"0")          				// 04 Total de registros 203
cR215 += PadL(cValToChar(nReg204),5,"0")						// 05 Total de registros 204
cR215 += PadL(cValToChar(nReg210),5,"0")						// 06 Total de registros 210
cR215 += PadL(cValToChar(nReg211),5,"0")                    	// 07 Total de registros 211
cR215 += PadL(cValToChar(nReg205),5,"0")						// 08 Total de registros 205
R15->(Reclock("R15",.T.))
   	R15->Campo  := cR215
R15->(MsUnlock())    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  Ajusta o ponteiro dos arquivos temporarios 	  						    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R01->(DbGoTop())     
R02->(DbGoTop())      
R03->(DbGoTop())
R04->(DbGoTop())
R05->(DbGoTop())
R10->(DbGoTop())
R11->(DbGoTop())
R15->(DbGoTop())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  Verifica o nome que o arquivo sera gerado   								
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
cArqNom := "PC"+Substr(Dtos(dDataBase),7,2)+Substr(Dtos(dDataBase),5,2)+Substr(Dtos(dDataBase),3,2)+ cSeq +"."+Substr(PlsIntPad(),2,3) 
While File(Alltrim(cDirNov)+cArqNom)
	cSeq := Soma1(cSeq)
	cArqNom := "PC"+Substr(Dtos(dDataBase),7,2)+Substr(Dtos(dDataBase),5,2)+Substr(Dtos(dDataBase),3,2)+ cSeq +"."+Substr(PlsIntPad(),2,3) 
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  Gera o arquivo A1200														
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PlsPTU(PadR(cCodLay, 6),cArqNom,cDirNov,.F.)     

//Se existir arquivos de renegociação, compactar o A1200 e arquivos em um zip
cDirNov := alltrim(cDirNov)
if ( !empty(alltrim(cArqPesq)) )
	aArquivos := StrTokArr2(cArqPesq, "-")
	//Copio os arquivos do banco de conhecimento para a pasta do A1200 gerado
	PlSrcBC587({"P", aArquivos, cDirNov}) 

	//Adiciono o próprio a1200 no array de compactação e adiciona o caminho completo
	aAdd(aArquivos, cArqNom)
	for nFor := 1 to len(aArquivos)
		aArquivos[nFor] := PLSMUDSIS(cDirNov + "\" + aArquivos[nFor])
	next 

	//Realizo a compactação de tudo e excluo arquivos não compactados
	cNomeZip := upper(PLSMUDSIS(cDirNov + "\" + substr(cArqNom, 1, rat(".", cArqNom)-1)) + ".zip")
	if ( fZip(cNomeZip, aArquivos, cDirNov ) == 0 )
		for nFor := 1 to len(aArquivos)
			if file( PLSMUDSIS( aArquivos[nFor]) )
				fErase( PLSMUDSIS( aArquivos[nFor]) )
			endif
		next
    endif

endif 

if ( empty(alltrim(cArqPesq)) )
	MsgInfo("Arquivo gerado: " + cDirNov + "\" + cArqNom)
else
	MsgInfo("Por possuir anexos, foi gerado um arquivo compactado, contendo o arquivo A1200 e anexos em: " + CRLF + cDirNov + "\" + substr(cArqNom, 1, rat(".", cArqNom)-1) + ".zip")
endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// Fecha arquivo temporario...                                              
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if( select( "R01" ) > 0 )
	oTempR01:Delete()
endIf

if( select( "R02" ) > 0 )
	oTempR02:Delete()
endIf

if( select( "R03" ) > 0 )
	oTempR03:Delete()
endIf

if( select( "R04" ) > 0 )
	oTempR04:Delete()
endIf

if( select( "R05" ) > 0 )
	oTempR05:Delete()
endIf

if( select( "R10" ) > 0 )
	oTempR10:Delete()
endIf

if( select( "R11" ) > 0 )
	oTempR11:Delete()
endIf

if( select( "R15" ) > 0 )
	oTempR15:Delete()
endIf

If Select('QRYITENS') > 0
	QRYITENS->(dbCloseArea())
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaProc
Soma o valor total dos procedimentos
@author Lucas Nonato
@since 11/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function SomaProc(cCodRda, cCodPro, cTipo, cAlias, cCodPad, cCodInt)
Local cSQL 	:= ""
Local cRet	:= ''
local cCampos := cAlias+"_TIPO, SUM(" + cAlias+"_VALFIX) VALFIX, SUM(" + cAlias+"_VALCH) VALCH "

cSQL := " SELECT " + cCampos + " FROM " + RetSqlName(cAlias) 
cSQL += " WHERE " 
cSql += cAlias+"_FILIAL = '" + xFilial(cAlias) + "' "
cSql += " AND "   + cAlias+"_CODINT = '" + cCodInt + "'"  
cSql += iif( cAlias == "BLY", " AND " + cAlias+"_CODRDA ='" + cCodRda + "' ", '')
cSQL += " AND "   + cAlias+"_CODPAD = '" + cCodPad + "' " 
cSQL += " AND "   + cAlias+"_CODPRO = '" + cCodPro + "' " 
cSql += " AND "   + cAlias+"_TIPO   = '" + cTipo   + "' "
cSql += " AND ( '" + dtos(dDataBase) + "' >= " + cAlias+"_VIGDE OR  " + cAlias+"_VIGDE  = '        ' )  "
cSql += " AND ( '" + dtos(dDataBase) + "' <= " + cAlias+"_VIGATE OR " + cAlias+"_VIGATE = '        ' )  "
cSql += " AND D_E_L_E_T_ = ' ' " 
cSql += " GROUP BY " + cAlias+"_TIPO "
cSQL := ChangeQuery(cSQL)        

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBSUM",.F.,.T.)
If !Empty(TRBSUM->VALFIX)
	cRet := TRBSUM->VALFIX
Else
	cRet := TRBSUM->VALCH
EndIf

TRBSUM->(dbCloseArea())

Return  cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getVigencia
Pega uma data de vigencia que todos os procedimentos estão inclusos.
@author Lucas Nonato
@since 11/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function getVigencia(cCodRda, cCodPro, cTipo, cAlias, cCodPad, cCodInt)   
Local cSQL  := ""
Local cRet	:= ''

If cTipo == '1'
	cSQL := "SELECT Min(" + cAlias+"_VIGDE) VIG FROM " + RetSqlName(cAlias)
Else
	cSQL := "SELECT  Max(" + cAlias+"_VIGATE) VIG, CASE WHEN " + cAlias+"_VIGATE = ' ' THEN '0' ELSE '1' END FROM " + RetSqlName(cAlias)
EndIf
cSQL += " WHERE " + cAlias+"_FILIAL = '" + xFilial(cAlias) + "' "
cSql += " AND "   + cAlias+"_CODINT = '" + cCodInt + "'"  
cSql += iif( cAlias == "BLY", " AND " + cAlias+"_CODRDA ='" + cCodRda + "' ", '')
cSQL += " AND "   + cAlias+"_CODPAD = '" + cCodPad + "' " 
cSQL += " AND "   + cAlias+"_CODPRO = '" + cCodPro + "' " 
cSQL += " AND D_E_L_E_T_ = ' ' " 
If cTipo == '2'
	cSql += " Group By " + cAlias+"_VIGATE "
endIf
cSQL := ChangeQuery(cSQL)     

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBVIG",.F.,.T.)
cRet := TRBVIG->VIG

TRBVIG->(dbCloseArea())

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdProc
Pega uma data de vigencia que todos os procedimentos estão inclusos.
@author Lucas Nonato
@since 11/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Static Function getQtdProc(cCodRda, cCodPro, cCodOpc, cAlias, cCodPad, cCodInt)
Local cSql := ""
Local cRet := ""
local cCampos := cAlias+"_QTDPAC Qtd "
cSql := " SELECT " + cCampos + " FROM " + RetSqlName(cAlias) 
cSQL += " WHERE "
cSql += cAlias+"_FILIAL = '" + xFilial(cAlias) + "' "
cSql += " AND "   + cAlias+"_CODINT = '" + cCodInt + "'" 
cSql += iif( cAlias == "BLY", " AND " + cAlias+"_CODRDA ='" + cCodRda + "' ", '')
cSQL += " AND "   + cAlias+"_CODPAD = '" + cCodPad + "' " 
cSQL += " AND "   + cAlias+"_CODPRO = '" + cCodPro + "' " 
cSQL += " AND "   + cAlias+"_CODOPC = '" + cCodOpc + "'" 
cSql += " AND ( '" + dtos(dDataBase) + "' >= " + cAlias+"_VIGDE OR  " + cAlias+"_VIGDE  = ' ' ) "
cSqL += " AND ( '" + dtos(dDataBase) + "' <= " + cAlias+"_VIGATE OR " + cAlias+"_VIGATE = ' ' ) "
cSQL += " AND D_E_L_E_T_ = ' ' " 

cSQL := ChangeQuery(cSQL) 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBPROC",.F.,.T.)
cRet := strzero(iif(TRBPROC->Qtd==0,1,TRBPROC->Qtd) * 10000,9) 
TRBPROC->(dbCloseArea())
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QryPrestRng
Pega prestadores que estão no intervalo
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function QryPrestRng(cEmpDe, cEmpAte)
Local cSql := ""

cSql := " SELECT BAU_CODIGO CODRDA, BAU_DTINCL INCLUSAO FROM " + RetSqlName('BAU') 
cSql += " WHERE 
cSql += "   BAU_FILIAL = '" + xFilial("BAU") + "' AND "
cSql += "   BAU_CODIGO >= '" + cEmpDe  + "' AND "  
cSql += "   BAU_CODIGO <= '" + cEmpAte + "' AND " 
cSql += "   D_E_L_E_T_ = ' ' "     
cSql += " ORDER BY BAU_CODIGO "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSQL)),"QRYPREST",.F.,.T.)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} QryPacotes
Query para verificar os pacotes gerais e específicos.
A query busca os registros que não tiveram o PTU A1200 gerado. (BLZ_STATUS = ' ')
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function QryPacotes(cCodInt, cCodRda, cCodPacDe, cCodPacAte)
Local cSql 		:= ""
local cRetName	:= RetSqlName("BLZ")
Local lNewCmp	:= BLZ->(fieldPos("BLZ_TIPPAC")) > 0
Local lBlzStatus:= BLZ->(fieldPos("BLZ_STATUS")) > 0

If Select('QRYPACOTE') > 0
	QRYPACOTE->(dbCloseArea())
EndIf 

cSql := "  SELECT BLZ_CODPRO CODPAC, BLZ_CODPAD CODPAD, BLZ_CODRDA RDA, BLZ_DTNEGO DTNEGO, BLZ_DTPUBL DTPUBL, BLZ_VERSAO VERSAO, BLZ_VIGINI VIGEINI, BLZ_VIGFIM VIGEFIM, "
If lNewCmp
	cSql += " BLZ_TIPACO TIPACO, BLZ_TIPPAC TIPPAC, BLZ_ESPEC ESPEC, BLZ_TIPINT TIPINT, "
	cSql += " BLZ_IDANES IDANES, BLZ_IDAUX IDAUX, BLZ_IDHON IDHON, BLZ_REAJUS REAJUS, BLZ_ARQREA ARQREA, "
endIf
cSql += "    'BLZ' TAB FROM " + cRetName
cSql += "    WHERE BLZ_FILIAL = '" + xFilial("BLZ") + "' AND " 
cSql += "	   BLZ_CODINT = '"  + cCodInt    + "' AND "
cSql += "      BLZ_CODRDA = '"  + cCodRda    + "' AND "
cSql += "      BLZ_CODPRO >= '" + cCodPacDe  + "' AND "
cSql += "      BLZ_CODPRO <= '" + cCodPacAte + "' AND "
If lBlzStatus
	cSql += "      BLZ_STATUS = ' ' AND "
EndIf
cSql += "      D_E_L_E_T_ = ' ' "
cSql += "  ORDER BY TAB, CODPAC "

if lPT1200A
    cSql := ExecBlock("PT1200A", .F., .F., {cSql, cCodRda, cCodPacDe, cCodPacAte})
endIf

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSql)),"QRYPACOTE",.F.,.T.)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} QryItemPacote
Query para verificar os pacotes gerais e específicos
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function QryItemPacote(cAlias, cCodInt, cCodRda, cCodPad, cCodPro)
Local cSql 		:= ""
local lPorRda	:= iif( cAlias == "BLY", .t., .f.)
Local lNewCmp	:= BLY->(FieldPos("BLY_DESPTU")) > 0
local cCampos	:= cAlias+"_CODPRO PAC," + cAlias+"_CODOPC CODPRO," + cAlias+"_TIPO TIPO," + cAlias+"_CPADOC CODPAD," + cAlias+"_PRINCI PRINCI," + cAlias+"_VALCH VALCH,";
 				   +cAlias+"_VALFIX VALFIX "

If lNewCmp
	cCampos += ", " + calias + "_DESPTU DESITE "
endIf

If Select('QRYITENS') > 0
	QRYITENS->(dbCloseArea())
EndIf 

cSql := " SELECT " + cCampos + " FROM " + RetSqlName(cAlias)
cSql += "   WHERE "
cSql +=       cAlias+"_FILIAL = '" + xFilial(cAlias) + "' AND "
cSql +=       cAlias+"_CODINT = '" + cCodInt         + "' AND "  
cSql += iif( lPorRda, cAlias+"_CODRDA = '" + cCodRda + "' AND ", '') 
cSql +=       cAlias+"_CODPAD = '" + cCodPad		 + "' AND " 
cSql +=       cAlias+"_CODPRO = '" + cCodPro         + "' AND "  
cSql +=       "( '" + dtos(dDataBase) + "' >= " + cAlias+"_VIGDE OR  " + cAlias+"_VIGDE  = ' ' ) AND "
cSqL += 	  "( '" + dtos(dDataBase) + "' <= " + cAlias+"_VIGATE OR " + cAlias+"_VIGATE = ' ' ) AND "
cSql +=       cAlias+"_ATIVO = '1' AND "

cSql += "     D_E_L_E_T_ = ' ' "
cSql += "  ORDER BY CODPAD, CODPRO "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSql)),"QRYITENS",.F.,.T.)

Return

static function GetEspPTU(cEspec)
Local cRet := "99"
BAQ->(dbsetOrder(1))
If !(empty(cEspec))
	If BAQ->(MsSeek(xFilial("BAQ")+PlsIntPad()+cEspec))
		cRet := strzero(val(BAQ->BAQ_INTERC),2)
	endIf
	If empty(cRet)
		cRet := "99"
	endIf
endIf
return cRet

function PLSMVCOMPA(nOpc)
Local lRet := .F.
LOCAL cCodMedGen    := GetNewPar("MV_PLMEDPT","")
LOCAL cCodMatGen    := GetNewPar("MV_PLMATPT","")
LOCAL cCodTaxGen    := GetNewPar("MV_PLTAXPT","")
LOCAL cCodOpmGen    := GetNewPar("MV_PLOPMPT","")

lRet := Alltrim(M->BLY_CODOPC) $ cCodMedGen + "|" + cCodMatGen + "|" + cCodTaxGen + "|" + cCodOpmGen

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} plStatPac
Função que é chamada pelo schedule configurada através do Wizard Configurador, no
arquivo \Protheus_data\sigapls\DSAUPC-INTEGRACAO-CENTRAL.json
A query busca os registros que já tiveram o PTU A1200 gerado. (BLZ_STATUS <> ' ')
OBS: O serviço deve estar iniciado lá no SIGACFG.
@author Silvia Sant'Anna
@since 12/2020
@version P12
/*/
//-------------------------------------------------------------------
Function plStatPac()
	Local cSQL 		:= ""
	Local cDatRef	:= ""
	Local cDtVigIni	:= ""
	Local lSchedule := .T.

	cDatRef		:= DTOS(dDataBase)
	cDatRef		:= Substr(cDatRef,1,4) + "-" + Substr(cDatRef,5,2) + "-" + Substr(cDatRef,7,2) // Formatado YYYY-MM-DD

	cSQL := " SELECT * FROM " + RetSQLName('BLZ') + "  "
	cSQL += "  WHERE BLZ_FILIAL = '" + xFilial('BLZ') + "' "
	cSQL += "    AND BLZ_VIGFIM = ' ' "
	cSQL += "    AND BLZ_STATUS <> ' ' "
	cSQL += "    AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changequery(cSql)),"QRYBLZ",.F.,.T.)

	If !( QRYBLZ->(EoF()) )
		While !( QRYBLZ->(EoF()) )

			cDtVigIni	:= DTOS(QRYBLZ->BLZ_VIGINI)
			cDtVigIni	:= Substr(cDtVigIni,1,4) + "-" + Substr(cDtVigIni,5,2) + "-" + Substr(cDtVigIni,7,2) // Formatado YYYY-MM-DD

			consPacUni( QRYBLZ->BLZ_CODINT, QRYBLZ->BLZ_CODRDA, QRYBLZ->BLZ_CODPAD, QRYBLZ->BLZ_CODPRO, cDatRef, cDtVigIni, lSchedule )
			QRYBLZ->( DbSkip() )
		EndDo
	EndIf
	QRYBLZ->(dbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} consPacUni
Schedule/robô que atualiza com base no retorno do webservice os status dos pacotes
Para mais detalhes do webservice
https://jiraproducao.totvs.com.br/browse/DSAUBE-10402
@author Silvia Sant'Anna
@since 12/2020
@version P12
/*/
//-------------------------------------------------------------------
function consPacUni(cCodOpe,cCodRda,cCodPad,cCodPac,cDatRef,cDtVigIni,lSchedule,lAutoma)
    Local aRet 		:= {}
	Local oRestClient
	Local aPacote	:= {}
	Local lRet		:= .F.
	Local cPacCodInt := ""
	Local cPacCodRDA := ""
	Local cPacCodigo := ""
	Local cPacVigIni := ""
	Default cCodOpe := PLSINTPAD()
	Default cCodRda := ""
	Default cCodPad := ""
	Default cCodPac := ""
	Default cDatRef := ""
	Default cDtVigIni := ""
	Default lSchedule := .F.
	Default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	

	oRestClient := PLSPTUSISPAC():New(cCodOpe)
	aRet := oRestClient:consultapacote(cCodOpe,cCodPac,,,,,,cDatRef,Alltrim(cCodRda),,,)

	//vai solicitar um pacote por vez, então não deve vir mais de uma posição no aPacote
	If aRet[1]
		aPacote := aRet[8]
	endIf

/*
	// Preenchendo array para teste - ambiente PTUONLINE_V8
    aPacote := {;
		55      															,; // [1,1]  cCdUniOri        x			CD_UNI_ORI
		"UNIMED VALE DO SINOS"    											,; // [1,2]  cNmUniOri        x			NM_UNI_ORI
		{"ASSOCIACAO CONGREGACAO DE SANTA CATARINA",499,"91681361000368"}	,; // [1,3]  aPrestadores     x			{NM_PREST,CD_PREST,CD_CPF_CNPJ}
		"30904129"     														,; // [1,4]  cCdItem          x			CD_ITEM
		"TROCA DE GERADOR" 													,; // [1,5]  cDsItem          x			DS_ITEM
		1       															,; // [1,6]  nQtServico       x			QT_SERVICO
		346.08    															,; // [1,7]  nVlServico       x			VL_SERVIÇO
		346.08    															,; // [1,8]  nVlTotal         x			VL_TOTAL
		"70001391"	       													,; // [1,9]  cCdPacote        x			CD_PACOTE
		9       															,; // [1,10] cStPacote        Usa 10	ST_PACOTE
		"C"    																,; // [1,11] cTpAcomodacao    x			TP_ACOMODACAO
		4        															,; // [1,12] cTpPacote        x			TP_PACOTE
		"" 																	,; // [1,13] cCdEspecialidade x			CD_ESPECIALIDADE
		1    																,; // [1,14] cTpInternacao    x			TP_INTERNACAO
		"2020-09-01"   														,; // [1,15] cDtNegocPacote   x			DT_NEGOC_PACOTE		Formato YYYY-MM-DD
		"S"           														,; // [1,16] cIndHm           x			IND_HM
		""    																,; // [1,17] cIndAnestesia    x			IND_ANESTESISTA
		"S"    																,; // [1,18] cIndAuxiliar     x			IND_AUXILIAR
		""          														,; // [1,19] cTpRede          x			TP_REDE
		"N"        															,; // [1,20] cIndOpme         x			IND_OPME
		"2020-09-16"  	   													,; // [1,21] cDtInicioVig     x			DT_INCIO_VIGENCIA	Formato YYYY-MM-DD
		""       															,; // [1,22] cDtFimVig        x			DT_FIM_VIGENCIA		Formato YYYY-MM-DD
		"2020-09-16"														,; // [1,23] cDtPublicacao    Usa 23	DT_PUBLICACAO		Formato YYYY-MM-DD
		""																	,; // [1,24] cDtAprovRepro    x			NM_PACOTE
		2076       															,; // [1,25] nVlPacote        x			VL_PACOTE
		1        															,; // [1,26] nVrPacote        x			VR_PACOTE
		{}    																,; // [1,27] aOutrosProced    x			
		{}         															;  // [1,28] aDetalhes        x				
	}
*/

	If lAutoma
		aPacote := {{;
			1      																,; // [1,1]  cCdUniOri        x			CD_UNI_ORI
			"UNIMED VALE DO SINOS"    											,; // [1,2]  cNmUniOri        x			NM_UNI_ORI
			{{"PLS DSAUPC RDA SILVIA SANT ANNA",7,"34391654857"}}				,; // [1,3]  aPrestadores     x			{NM_PREST,CD_PREST,CD_CPF_CNPJ}
			"30904129"     														,; // [1,4]  cCdItem          x			CD_ITEM
			"TROCA DE GERADOR" 													,; // [1,5]  cDsItem          x			DS_ITEM
			1       															,; // [1,6]  nQtServico       x			QT_SERVICO
			100.00    															,; // [1,7]  nVlServico       x			VL_SERVIÇO
			100.00    															,; // [1,8]  nVlTotal         x			VL_TOTAL
			"99999994"	       													,; // [1,9]  cCdPacote        x			CD_PACOTE
			9       															,; // [1,10] cStPacote        Usa 10	ST_PACOTE
			"C"    																,; // [1,11] cTpAcomodacao    x			TP_ACOMODACAO
			4        															,; // [1,12] cTpPacote        x			TP_PACOTE
			"" 																	,; // [1,13] cCdEspecialidade x			CD_ESPECIALIDADE
			1    																,; // [1,14] cTpInternacao    x			TP_INTERNACAO
			"2021-01-01"   														,; // [1,15] cDtNegocPacote   x			DT_NEGOC_PACOTE		Formato YYYY-MM-DD
			"S"           														,; // [1,16] cIndHm           x			IND_HM
			""    																,; // [1,17] cIndAnestesia    x			IND_ANESTESISTA
			"S"    																,; // [1,18] cIndAuxiliar     x			IND_AUXILIAR
			""          														,; // [1,19] cTpRede          x			TP_REDE
			"N"        															,; // [1,20] cIndOpme         x			IND_OPME
			"2021-01-01"  	   													,; // [1,21] cDtInicioVig     x			DT_INCIO_VIGENCIA	Formato YYYY-MM-DD
			""       															,; // [1,22] cDtFimVig        x			DT_FIM_VIGENCIA		Formato YYYY-MM-DD
			"2021-01-01"														,; // [1,23] cDtPublicacao    Usa 23	DT_PUBLICACAO		Formato YYYY-MM-DD
			""																	,; // [1,24] cDtAprovRepro    x			NM_PACOTE
			100       															,; // [1,25] nVlPacote        x			VL_PACOTE
			1        															,; // [1,26] nVrPacote        x			VR_PACOTE
			{}    																,; // [1,27] aOutrosProced    x			
			{}         															;  // [1,28] aDetalhes        x				
		}}
	EndIf

	If len(aPacote) > 0
		cPacCodInt := PadL(aPacote[1,1], 4, '0')		//"0055"
		cPacCodRDA := PadL(aPacote[1,3,1,2], 6, '0')	//"000499"
		cPacCodigo := aPacote[1,9]						//"70001391"
		cPacVigIni := aPacote[1,21]						//"2020-09-16"

		BLZ->(dbSetOrder(1))//BLZ_FILIAL+BLZ_CODINT+BLZ_CODRDA+BLZ_CODPAD+BLZ_CODPRO
		if BLZ->( msSeek( xFilial("BLZ") + cPacCodInt + cPacCodRDA + cCodPad + cPacCodigo ) ) 
			While !(BLZ->(EoF())) .AND. ( ALLTRIM(xFilial("BLZ") + cPacCodInt + cPacCodRDA + cCodPad + cPacCodigo) == ALLTRIM(BLZ->( BLZ_FILIAL+BLZ_CODINT+BLZ_CODRDA+BLZ_CODPAD+BLZ_CODPRO)) ) 			
				If cPacVigIni == cDtVigIni
					RecLock("BLZ", .F.)       
					BLZ->BLZ_STATUS := cValToChar(aPacote[1,10])
					MsUnLock() 
					lRet := .T.
				EndIf
				BLZ->( DbSkip() )
			EndDo
		Else
			If !lSchedule .AND. !lAutoma
				MsgAlert("O Status não foi alterado pois não encontrou o pacote na base de dados.") 
			EndIf
		EndIf
	Else
		If !lSchedule .AND. !lAutoma
			MsgAlert("Não retornou dados do pacote solicitado.")
		EndIf
	EndIf

return lRet
