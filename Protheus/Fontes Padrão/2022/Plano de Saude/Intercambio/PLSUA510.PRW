#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"

#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF    

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA510
Envia para o WebService Unimed, as faturas que de intercambio que 
foram pagas

@author  Lucas Nonato
@version P11
@since   09/01/2017
/*/
//-------------------------------------------------------------------
Function PLSUA510(lAuto)

Local cPerg 		:= padr("PLSUA510",10)
Local aStruc		:= {}

PRIVATE cOpeDe     	:= ""
PRIVATE cOpeAte    	:= ""
PRIVATE cDtLoteDe  	:= ""
PRIVATE cDtLoteAte 	:= ""
PRIVATE cLotFin    	:= ""
PRIVATE nTp			:= ""
PRIVATE aCdCores  	:= {}
PRIVATE cCadastro 	:= "Exportação A510"
PRIVATE aErros	  	:= {}
default lAuto		:= .f.

if valtype(lAuto) <> 'L'
	lAuto := .f.
endif

Aadd(aStruc,{"OpeOri","C",4,0})
Aadd(aStruc,{"CodOpe","C",4,0})
Aadd(aStruc,{"NomOpe","C",100,0})
Aadd(aStruc,{"DtVenc","D",8,0})
Aadd(aStruc,{"NumDoc","C",20,0})
Aadd(aStruc,{"ValCob","C",21,0})
Aadd(aStruc,{"Status","C",1,0})
Aadd(aStruc,{"Numero","C",8,0})
Aadd(aStruc,{"TpParc","N",1,0})
Aadd(aStruc,{"TpMov" ,"C",1,0}) 
Aadd(aStruc,{"NumNot","C",9,0}) 
Aadd(aStruc,{"Recno" ,"N",7,0})                 
If lAuto .or. pergunte(cPerg,.T.)
	
    cOpeDe     	:= mv_par01
    cOpeAte    	:= mv_par02
    cDtLoteDe  	:= mv_par03
    cDtLoteAte 	:= mv_par04
    cLotFin    	:= mv_par05
    nTp    		:= mv_par06
    
    //Carrega erros de acordo com o Anexo do PTU Batch 8.0
    retErro(aErros)
    
    aCdCores := { { 'BR_AMARELO' ,"Não comunicado" },; 
				  { 'BR_VERDE'   ,"Baixa do Documento Realizada com Sucesso" },;
				  { 'BR_VERMELHO',"Baixa do Documento Realizada com Erro"} }  
    
    If nTp == 1
    	PL510BRJ(aStruc,lAuto)    	
    Else
    	PL510BTO(aStruc,lAuto)
    EndIf

EndIf
                  
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PL510BRJ
Processa itens importados para envio do PTU A510

@author  Lucas Nonato
@since   09/01/2017
@version P11
/*/
//-------------------------------------------------------------------  
Function PL510BRJ(aStruc,lAuto)
Local cSql 		:= ""
Local aOrdCmp	:= {}
Local aSeek		:= {} 
Local oBrwBRJ  	:= nil  
Local lPLU510P2	:= ExistBLock("PLU510P2")
default lAuto 	:= .f.
PRIVATE aRotina   	:= MenuBRJ()

cSql += " SELECT BRJ_CODOPE, BRJ_CODIGO, BRJ_OPEORI, BRJ_NOMORI, E1_BAIXA, BRJ_DTVENC, E1_PREFIXO, E1_NUM, E1_VALOR, BRJ_ARQUIV, BRJ_STTP1 AS STATUS, BRJ_TPCOB, E1_NUMNOTA, 1 AS TIPO, BRJ.R_E_C_N_O_ from " +  RetSQLName('BRJ') + " BRJ "
cSql += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON "
cSql += " SE1.E1_FILIAL = '" + xFilial('SE1') +  "'"
cSql += " AND SE1.E1_PREFIXO = BRJ.BRJ_PREFIX "
cSql += " AND SE1.E1_NUM = BRJ.BRJ_NUMTIT "
cSql += " AND SE1.D_E_L_E_T_ = BRJ.D_E_L_E_T_ "
cSql += " WHERE BRJ.BRJ_FILIAL = '" + xFilial('BRJ') + "'"
cSql += " AND  BRJ_DATA >= '" + dToS(cDtLoteDe) + "' "
cSql += " AND  BRJ_DATA <= '" + dToS(cDtLoteAte) + "' "
cSql += " AND BRJ.BRJ_OPEORI >= '" + cOpeDe + "' "
cSql += " AND BRJ.BRJ_OPEORI <= '" + cOpeAte + "'  "
cSql += " AND BRJ.BRJ_REGPRI = '1' "
If cLotFin == 2
	cSql += " AND BRJ.BRJ_STTP1 <> '1'"
EndIf
cSql += " AND BRJ.D_E_L_E_T_ = ' ' "

cSql += " UNION ALL "

cSql += " SELECT BRJ_CODOPE, BRJ_CODIGO,BRJ_OPEORI, BRJ_NOMORI, E1_BAIXA, BRJ_DTVENC, E1_PREFIXO, E1_NUM, E1_VALOR, BRJ_ARQUIV, BRJ_STTP2 AS STATUS, BRJ_TPCOB, E1_NUMNOTA, 2 AS TIPO, BRJ.R_E_C_N_O_ from " +  RetSQLName('BRJ') + " BRJ "
cSql += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON "
cSql += " SE1.E1_FILIAL = '" + xFilial('SE1') +  "'"
cSql += " AND SE1.E1_PREFIXO = BRJ.BRJ_FP2PRE "
cSql += " AND SE1.E1_NUM = BRJ.BRJ_FP2TIT "
cSql += " AND SE1.D_E_L_E_T_ = BRJ.D_E_L_E_T_ "
cSql += " WHERE BRJ.BRJ_FILIAL = '" + xFilial('BRJ') + "'"
cSql += " AND  BRJ_DATA >= '" + dToS(cDtLoteDe) + "' "
cSql += " AND  BRJ_DATA <= '" + dToS(cDtLoteAte) + "' "
cSql += " AND BRJ.BRJ_OPEORI >= '" + cOpeDe + "' "
cSql += " AND BRJ.BRJ_OPEORI <= '" + cOpeAte + "'  "
cSql += " AND BRJ.BRJ_REGPRI = '1' "
If cLotFin == 2
	cSql += " AND BRJ.BRJ_STTP2 <> '1'"
EndIf
cSql += " AND BRJ.D_E_L_E_T_ = ' ' "

cSql += " UNION ALL "

cSql += " SELECT BRJ_CODOPE, BRJ_CODIGO, BRJ_OPEORI, BRJ_NOMORI, E1_BAIXA, BRJ_DTVENC, E1_PREFIXO, E1_NUM, E1_VALOR, BRJ_ARQUIV, BRJ_STTCO AS STATUS, BRJ_TPCOB, E1_NUMNOTA, 3 AS TIPO, BRJ.R_E_C_N_O_ from " +  RetSQLName('BRJ') + " BRJ "
cSql += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON "
cSql += " SE1.E1_FILIAL = '" + xFilial('SE1') +  "'"
cSql += " AND SE1.E1_PREFIXO = BRJ.BRJ_CFTPRE "
cSql += " AND SE1.E1_NUM = BRJ.BRJ_CFTTIT "
cSql += " AND SE1.D_E_L_E_T_ = BRJ.D_E_L_E_T_ "
cSql += " WHERE BRJ.BRJ_FILIAL = '" + xFilial('BRJ') + "'"
cSql += " AND  BRJ_DATA >= '" + dToS(cDtLoteDe) + "' "
cSql += " AND  BRJ_DATA <= '" + dToS(cDtLoteAte) + "' "
cSql += " AND BRJ.BRJ_OPEORI >= '" + cOpeDe + "' "
cSql += " AND BRJ.BRJ_OPEORI <= '" + cOpeAte + "'  "
cSql += " AND BRJ.BRJ_REGPRI = '1' "
If cLotFin == 2
	cSql += " AND BRJ.BRJ_STTCO <> '1'"
EndIf
cSql += " AND BRJ.D_E_L_E_T_ = ' ' "
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBRJ",.F.,.T.)	

TrbBRJ->(dbGoTop())

oTempTable := FWTemporaryTable():New( "TRB" )
oTemptable:SetFields( aStruc )
oTempTable:AddIndex( "Titulo",{ "NumDoc" } )
oTempTable:AddIndex( "Operadora",{ "NomOpe" } )
oTempTable:Create()

While !TrbBRJ->(Eof())
	TRB->(RecLock("TRB",.T.))
		TRB->OpeOri	:=	TrbBRJ->BRJ_OPEORI
		TRB->CodOpe	:=	TrbBRJ->BRJ_CODOPE
		TRB->NomOpe	:=	TrbBRJ->BRJ_NOMORI
		TRB->DtVenc	:=	SToD(TrbBRJ->BRJ_DTVENC)
		TRB->NumDoc	:=	TrbBRJ->(E1_PREFIXO + E1_NUM)
		TRB->ValCob	:=	AllTrim(Transform(TrbBRJ->E1_VALOR,"@E 9,999,999,999,999.99"))
		TRB->Status := 	TrbBRJ->Status
		TRB->TpMov 	:= 	TrbBRJ->BRJ_TPCOB
		TRB->TpParc := 	TrbBRJ->TIPO
		TRB->Numero	:=  TrbBRJ->BRJ_CODIGO	
		TRB->Recno 	:=	TrbBRJ->R_E_C_N_O_	
		If lPLU510P2
   			TRB->NumNot := ExecBlock("PLU510P2",.F.,.F.,{TrbBRJ->E1_NUMNOTA,"TrbBRJ","TRB"})
   		Else
   			TRB->NumNot	:=  TrbBRJ->E1_NUMNOTA
		EndIf		
		
	TRB->( MsUnLock() )
	TrbBRJ->(dbSkip())
EndDo      

//Campos que irão compor o combo de pesquisa na tela principal
Aadd(aSeek,{"No.Titulo", 	{{"","C",20,0, 	"NumDoc"   ,"@!"}}, 1, .T. } )
Aadd(aSeek,{"Nome Operadora", 	{{"","C",100,0, "NomOpe" ,"@!"}}, 2, .T. } )

oBrwBRJ := FWmBrowse():New()
oBrwBRJ:SetAlias( 'TRB' )
oBrwBRJ:SetDescription( 'Faturas de Intercâmbio' ) 
oBrwBRJ:DisableDetails()
oBrwBRJ:AddLegend( "TRB->Status == '0' .Or. Empty(TRB->Status)",'BR_AMARELO' ,	OemToAnsi( "Não Comunicado" ) ) 
oBrwBRJ:AddLegend( "TRB->Status == '1'",'BR_VERDE'   ,	OemToAnsi( "Baixa do Documento Realizada com Sucesso" ) )   
oBrwBRJ:AddLegend( "TRB->Status == '2'",'BR_VERMELHO',	OemToAnsi( "Baixa do Documento Realizada com Erro" ) )   
oBrwBRJ:SetWalkThru(.F.)
oBrwBRJ:SetSeek(.T., aSeek)

SX3->(dbSetOrder(2))
SX3->(MsSeek("BRJ_OPEORI")) ; aadd(aOrdCmp,{X3TITULO(),"OpeOri"})
SX3->(MsSeek("BRJ_NOMORI")) ; aadd(aOrdCmp,{X3TITULO(),"NomOpe"})
SX3->(MsSeek("BRJ_DTVENC")) ; aadd(aOrdCmp,{X3TITULO(),"DtVenc"})
SX3->(MsSeek("E1_NUM")) 	; aadd(aOrdCmp,{X3TITULO(),"NumDoc"})
SX3->(MsSeek("E1_NUMNOTA")) ; aadd(aOrdCmp,{X3TITULO(),"NumNot"})
SX3->(MsSeek("E1_VALOR")) 	; aadd(aOrdCmp,{X3TITULO(),"ValCob"})

oBrwBRJ:setFields(aOrdCmp)

TrbBRJ->(dbCloseArea())   
if !lAuto
	oBrwBRJ:Activate()
	TRB->(DbCloseArea())  
endif
           
Return     

//-------------------------------------------------------------------
/*/{Protheus.doc} PL510BTO
Processa itens exportados para envio do PTU A510

@author  Lucas Nonato
@since   09/01/2017
@version P11
/*/
//-------------------------------------------------------------------  
Function PL510BTO(aStruc,lAuto)
Local cSql 		:= ""
Local aOrdCmp	:= {}
Local aSeek		:= {} 
Local oBrwBTO  	:= nil
Local lPLU510P2	:= ExistBLock("PLU510P2")
default lAuto 	:= .f.
PRIVATE aRotina   	:= MenuBTO()

cSql += " SELECT BTO_CODOPE, BTO_OPEORI, BAU_NOME, BTO_DATGER, E1_PREFIXO, E1_BAIXA, E1_NUM, E1_VALOR, BTO_STTIT AS STATUS, BTO_TPMOV, 0 AS TIPO, E1_NUMNOTA, BTO_NUMERO, BTO.R_E_C_N_O_ from " +  RetSQLName('BTO') + " BTO "
cSql += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON "
cSql += " SE1.E1_FILIAL = '" + xFilial('SE1') +  "'"
cSql += " AND SE1.E1_PREFIXO = BTO.BTO_PREFIX "
cSql += " AND SE1.E1_NUM = BTO.BTO_NUMTIT "
cSql += " AND SE1.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " INNER JOIN " + RetSQLName('BAU') + " BAU ON"
cSql += " BAU.BAU_FILIAL = '" + xFilial('BAU') +  "'"
cSql += " AND BAU.BAU_CODOPE = BTO.BTO_OPEORI" 
cSql += " AND BAU.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " WHERE BTO.BTO_FILIAL = '" + xFilial('BTO') + "'"
cSql += " AND BTO_DATGER >= '" + dToS(cDtLoteDe) + "' "
cSql += " AND BTO_DATGER <= '" + dToS(cDtLoteAte) + "' "
cSql += " AND BTO.BTO_OPEORI >= '" + cOpeDe + "' "
cSql += " AND BTO.BTO_OPEORI <= '" + cOpeAte + "'  "
cSql += " AND BTO.BTO_TPCOB = '2' "
If cLotFin == 2
	cSql += " AND BTO.BTO_STTIT <> '1'"
EndIf
cSql += " AND BTO.D_E_L_E_T_ = ' ' "

cSql += " UNION ALL "

cSql += " SELECT BTO_CODOPE, BTO_OPEORI, BAU_NOME, BTO_DATGER, E1_PREFIXO, E1_BAIXA, E1_NUM, E1_VALOR, BTO_STTP1 AS STATUS, BTO_TPMOV, 1 AS TIPO, E1_NUMNOTA, BTO_NUMERO, BTO.R_E_C_N_O_ from " +  RetSQLName('BTO') + " BTO "
cSql += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON "
cSql += " SE1.E1_FILIAL = '" + xFilial('SE1') +  "'"
cSql += " AND SE1.E1_PREFIXO = BTO.BTO_GPFPRE "
cSql += " AND SE1.E1_NUM = BTO.BTO_GPFTIT "
cSql += " AND SE1.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " INNER JOIN " + RetSQLName('BAU') + " BAU ON"
cSql += " BAU.BAU_FILIAL = '" + xFilial('BAU') +  "'"
cSql += " AND BAU.BAU_CODOPE = BTO.BTO_OPEORI" 
cSql += " AND BAU.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " WHERE BTO.BTO_FILIAL = '" + xFilial('BTO') + "'"
cSql += " AND BTO_DATGER >= '" + dToS(cDtLoteDe) + "' "
cSql += " AND BTO_DATGER <= '" + dToS(cDtLoteAte) + "' "
cSql += " AND BTO.BTO_OPEORI >= '" + cOpeDe + "' "
cSql += " AND BTO.BTO_OPEORI <= '" + cOpeAte + "'  "
cSql += " AND BTO.BTO_TPCOB = '2' "
If cLotFin == 2
	cSql += " AND BTO.BTO_STTP1 <> '1'"
EndIf
cSql += " AND BTO.D_E_L_E_T_ = ' ' "

cSql += " UNION ALL "

cSql += " SELECT BTO_CODOPE, BTO_OPEORI, BAU_NOME, BTO_DATGER, E1_PREFIXO, E1_BAIXA, E1_NUM, E1_VALOR, BTO_STTP2 AS STATUS, BTO_TPMOV, 2 AS TIPO, E1_NUMNOTA, BTO_NUMERO, BTO.R_E_C_N_O_ from " +  RetSQLName('BTO') + " BTO "
cSql += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON "
cSql += " SE1.E1_FILIAL = '" + xFilial('SE1') +  "'"
cSql += " AND SE1.E1_PREFIXO = BTO.BTO_GP2PRE "
cSql += " AND SE1.E1_NUM = BTO.BTO_GP2TIT "
cSql += " AND SE1.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " INNER JOIN " + RetSQLName('BAU') + " BAU ON"
cSql += " BAU.BAU_FILIAL = '" + xFilial('BAU') +  "'"
cSql += " AND BAU.BAU_CODOPE = BTO.BTO_OPEORI" 
cSql += " AND BAU.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " WHERE BTO.BTO_FILIAL = '" + xFilial('BTO') + "'"
cSql += " AND BTO_DATGER >= '" + dToS(cDtLoteDe) + "' "
cSql += " AND BTO_DATGER <= '" + dToS(cDtLoteAte) + "' "
cSql += " AND BTO.BTO_OPEORI >= '" + cOpeDe + "' "
cSql += " AND BTO.BTO_OPEORI <= '" + cOpeAte + "'  "
cSql += " AND BTO.BTO_TPCOB = '2' "
If cLotFin == 2
	cSql += " AND BTO.BTO_STTP2 <> '1'"
EndIf
cSql += " AND BTO.D_E_L_E_T_ = ' ' "

cSql += " UNION ALL "

cSql += " SELECT BTO_CODOPE, BTO_OPEORI, BAU_NOME, BTO_DATGER, E1_PREFIXO, E1_BAIXA, E1_NUM, E1_VALOR, BTO_STTCO AS STATUS, BTO_TPMOV, 3 AS TIPO, E1_NUMNOTA, BTO_NUMERO, BTO.R_E_C_N_O_ from " +  RetSQLName('BTO') + " BTO "
cSql += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON "
cSql += " SE1.E1_FILIAL = '" + xFilial('SE1') +  "'"
cSql += " AND SE1.E1_PREFIXO = BTO.BTO_GCOPRE "
cSql += " AND SE1.E1_NUM = BTO.BTO_GCOTIT "
cSql += " AND SE1.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " INNER JOIN " + RetSQLName('BAU') + " BAU ON"
cSql += " BAU.BAU_FILIAL = '" + xFilial('BAU') +  "'"
cSql += " AND BAU.BAU_CODOPE = BTO.BTO_OPEORI " 
cSql += " AND BAU.D_E_L_E_T_ = BTO.D_E_L_E_T_ "
cSql += " WHERE BTO.BTO_FILIAL = '" + xFilial('BTO') + "'"
cSql += " AND BTO_DATGER >= '" + dToS(cDtLoteDe) + "' "
cSql += " AND BTO_DATGER <= '" + dToS(cDtLoteAte) + "' "
cSql += " AND BTO.BTO_OPEORI >= '" + cOpeDe + "' "
cSql += " AND BTO.BTO_OPEORI <= '" + cOpeAte + "'  "
cSql += " AND BTO.BTO_TPCOB = '2' "
If cLotFin == 2
	cSql += " AND BTO.BTO_STTCO <> '1'"
EndIf
cSql += " AND BTO.D_E_L_E_T_ = ' ' "
cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBTO",.F.,.T.)	

TrbBTO->(dbGoTop())

oTempTable := FWTemporaryTable():New( "TRB" )
oTemptable:SetFields( aStruc )
oTempTable:AddIndex( "Titulo",{ "NumDoc" } )
oTempTable:AddIndex( "Operadora",{ "NomOpe" } )
oTempTable:Create()

While !TrbBTO->(Eof())
	TRB->(RecLock("TRB",.T.))
		TRB->OpeOri	:=	TrbBTO->BTO_OPEORI
		TRB->CodOpe	:=	TrbBTO->BTO_CODOPE
		TRB->NomOpe	:=	TrbBTO->BAU_NOME
		TRB->DtVenc	:=	SToD(TrbBTO->BTO_DATGER)
		TRB->NumDoc	:=	TrbBTO->(E1_PREFIXO + E1_NUM)
		TRB->ValCob	:=	AllTrim(Transform(TrbBTO->E1_VALOR,"@E 9,999,999,999,999.99"))
		TRB->Status := 	TrbBTO->Status
		TRB->TpMov 	:= 	TrbBTO->BTO_TPMOV
		TRB->TpParc := 	TrbBTO->TIPO
		TRB->Numero := 	TrbBTO->BTO_NUMERO
		TRB->Recno :=	TrbBTO->R_E_C_N_O_
		If lPLU510P2
   			TRB->NumNot := ExecBlock("PLU510P2",.F.,.F.,{TrbBTO->E1_NUMNOTA,"TrbBTO","TRB"})
   		Else
   			TRB->NumNot	:=  TrbBTO->E1_NUMNOTA
		EndIf	
		
		
	TRB->( MsUnLock() )
	TrbBTO->(dbSkip())
EndDo

//Campos que irão compor o combo de pesquisa na tela principal
Aadd(aSeek,{"No.Titulo", 	{{"","C",20,0, 	"NumDoc"   ,"@!"}}, 1, .T. } )
Aadd(aSeek,{"Nome Operadora", 	{{"","C",100,0, "NomOpe" ,"@!"}}, 2, .T. } )

oBrwBTO := FWmBrowse():New()
oBrwBTO:SetAlias( 'TRB' )
oBrwBTO:SetDescription( 'Faturas de Intercâmbio' ) 
oBrwBTO:DisableDetails()
oBrwBTO:AddLegend( "TRB->Status == '0' .Or. Empty(TRB->Status)",'BR_AMARELO' ,	OemToAnsi( "Não Comunicado" ) ) 
oBrwBTO:AddLegend( "TRB->Status == '1'",'BR_VERDE'   ,	OemToAnsi( "Baixa do Documento Realizada com Sucesso" ) )   
oBrwBTO:AddLegend( "TRB->Status == '2'",'BR_VERMELHO',	OemToAnsi( "Baixa do Documento Realizada com Erro" ) )   
oBrwBTO:SetWalkThru(.F.)
oBrwBTO:SetSeek(.T., aSeek)

SX3->(dbSetOrder(2))
SX3->(MsSeek("BTO_OPEORI")) ; aadd(aOrdCmp,{X3TITULO(),"OpeOri"})
SX3->(MsSeek("BAU_NOME")) 	; aadd(aOrdCmp,{X3TITULO(),"NomOpe"})
SX3->(MsSeek("BTO_DATGER")) ; aadd(aOrdCmp,{X3TITULO(),"DtVenc"})
SX3->(MsSeek("E1_NUM")) 	; aadd(aOrdCmp,{X3TITULO(),"NumDoc"})
SX3->(MsSeek("E1_NUMNOTA")) ; aadd(aOrdCmp,{X3TITULO(),"NumNot"})
SX3->(MsSeek("E1_VALOR")) 	; aadd(aOrdCmp,{X3TITULO(),"ValCob"})

oBrwBTO:setFields(aOrdCmp)

TrbBTO->(DbCloseArea())    
if !lAuto
	oBrwBTO:Activate() 
	TRB->(DbCloseArea())
endif
                   
Return  
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuBTO
Monta menu da rotina BTO

@author  Lucas Nonato
@since   09/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function MenuBTO()
Local aRotina := {	{ "Enviar"    ,'PLSBTOENV(.f.)'  , 0, K_Visualizar , 0, Nil},;					
					{ "Legenda "  ,'PLSU510LEG'  , 0, K_Incluir  , 0, Nil}}  
					//{ "Gerar Lote",'PLSU510LOT'  , 0, K_Visualizar , 0, Nil},;   						
						
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuBRJ
Monta menu da rotina BRJ 

@author  Lucas Nonato
@since   09/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function MenuBRJ()
Local aRotina := {	{ "Enviar"    ,'PLSBRJENV(.f.)'  , 0, K_Visualizar , 0, Nil},;					
					{ "Legenda "  ,'PLSU510LEG'  , 0, K_Incluir  , 0, Nil}}  
					
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP500LEG
Exibe a legenda 

@author  Lucas Nonato
@since   09/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Function PLSU510LEG()

BrwLegenda(cCadastro,"Status" ,aCdCores)

Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraXml
Gera arquivo XML A510

@author  Lucas Nonato
@since   09/01/2017
@version P11
/*/
//-------------------------------------------------------------------       
Static Function GeraXml(aDados,lEnvSoap)
Local cXml     	:= ""    
Local cErro    	:= ""
Local cAviso   	:= ""
Local cStrHash 	:= ""  
Local cSoap    	:= ""
Local cSchema  := GetNewPar("MV_P510XSD","mi_Transacoes-V1_00_00.xsd")    
Local lRet     := .T.

Default lEnvSoap   := .T.   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
//cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'+CRLF
//cXml += GerA510Tag("solicitarBaixaWS",nil,nil,nil,.T.,nil)  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta cabecalho                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
cXml += GerA510Tag("cabecalhoTransacao",nil,nil,nil,.T.,nil)   

cXml += GerA510Tag("codigoUnimedOrigemMensagem" ,cValToChar(Val(Substr(PlsIntPad(),2,3))),@cStrHash,.T.) 
cXml += GerA510Tag("codigoUnimedDestinoMensagem","999"		 ,@cStrHash,.T.) 
cXml += GerA510Tag("versaoTransacao"            ,"02"      	 ,@cStrHash,.T.) 

cXml += GerA510Tag("cabecalhoTransacao",nil,nil,nil,nil,.T.)                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corpo Mensagem                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cXml += GerA510Tag("corpoMensagem" ,nil,nil,nil,.T.,nil)   
//cXml += GerA510Tag("mensagemEnvio" ,nil,nil,nil,.T.,nil)   
cXml += GerA510Tag("solicitarBaixa",nil,nil,nil,.T.,nil)   
cXml += GerA510Tag("dadosCobranca" ,nil,nil,nil,.T.,nil)
                                          
cXml += GerA510Tag("codigoUnimedRecebeuCobranca",cValToChar(Val(aDados[01])),@cStrHash,.T.)
cXml += GerA510Tag("numeroDocumento1"           ,aDados[02],@cStrHash,.T.)
cXml += GerA510Tag("numeroDocumento2"           ,aDados[03],@cStrHash,.T.)
cXml += GerA510Tag("tpDocumento1"               ,aDados[04],@cStrHash,.T.)
cXml += GerA510Tag("tpDocumento2"               ,aDados[05],@cStrHash,.T.)
cXml += GerA510Tag("valorTotalPagoDoc1"         ,aDados[06],@cStrHash,.T.)
cXml += GerA510Tag("valorTotalPagoDoc2"         ,aDados[07],@cStrHash,.T.)
cXml += GerA510Tag("dataPagamentoDoc1"          ,aDados[08],@cStrHash,.T.,,,.T.)
cXml += GerA510Tag("dataPagamentoDoc2"          ,aDados[09],@cStrHash,.T.)
cXml += GerA510Tag("identificadorPagamentoDoc1" ,aDados[10],@cStrHash,.T.)
cXml += GerA510Tag("identificadorPagamentoDoc2" ,aDados[11],@cStrHash,.T.)

cXml += GerA510Tag("dadosCobranca" ,nil,nil,nil,nil,.T.)
cXml += GerA510Tag("solicitarBaixa",nil,nil,nil,nil,.T.)				
//cXml += GerA510Tag("mensagemEnvio" ,nil,nil,nil,nil,.T.) 				
//cXml += GerA510Tag("corpoMensagem" ,nil,nil,nil,nil,.T.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o hash                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
cXml += GerA510Tag("hash",MD5(cStrHash,2),nil,.T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o arquivo                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
cXml += GerA510Tag("solicitarBaixaWS" ,nil,nil,nil,nil,.T.)  

If lEnvSoap
	cSoap := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://mi.unimed.coop.br/schemas/V1_00_00">'+Chr(10)
	cSoap += '<soapenv:Header/>'+Chr(10)
	cSoap += '<soapenv:Body>'+Chr(10)  
	cSoap += '<v1:solicitarBaixaWS>'
	cSoap += cXml+Chr(10)
	cSoap += '</soapenv:Body>'+Chr(10)
	cSoap += '</soapenv:Envelope>'+Chr(10)
EndIf 

cXml := '<v1:solicitarBaixaWS xsi:schemaLocation="http://mi.unimed.coop.br/schemas/V1_00_00" xmlns:v1="http://mi.unimed.coop.br/schemas/V1_00_00" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + Chr(10) + cXml

/*If (!XmlSVldSch( cXml, "\plsptu\A510\schemas\"+cSchema, @cErro,@cAviso)) 
	cMsgXsdErr := Iif( !Empty(cErro),"Erro: " +cErro,"")
	cMsgXsdErr += Iif( !Empty(cAviso),"Aviso: "+cAviso,"")   
	MsgInfo(cMsgXsdErr)
	lRet := .F.
Else 
	lRet := .T.	
EndIf*/

Return {lRet,cSoap,cErro}  

//-------------------------------------------------------------------
/*/{Protheus.doc} GerA510Tag
Gera arquivo XML A510

@author  Lucas Nonato
@since   09/01/2017
@version P11
/*/
//-------------------------------------------------------------------
Static Function GerA510Tag(cTag,cConteudo,cStrHash,lAbreFecha,lAbre,lFecha,lBco)      
Local cRet := ""
Default cStrHash   := ""
Default cConteudo  := ""
Default lAbreFecha := .F.
Default lAbre      := .F.
Default lFecha     := .F.
Default lBco       := .F.

If lAbreFecha   
	If !Empty(cConteudo) .Or. lBco
		cRet := "<v1:"+cTag+">"+cConteudo+"</v1:"+cTag+">" 
	Else        
		Return(cRet)  
		//cRet := "</v1:"+cTag+">
	EndIf
Endif

If lAbre
	cRet := "<v1:"+cTag+">
EndIf

If lFecha
	cRet := "</v1:"+cTag+">
EndIf    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona conteudo para variavel de hash geral                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cConteudo)
	cStrHash += cConteudo
EndIf

Return(cRet+CRLF)  
   
	
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBTOENV
Envia uma fatura singular    

@author  Lucas Nonato
@since   24/11/2016
@version P11
/*/
//-------------------------------------------------------------------       
Function PLSBTOENV(lAuto)  
Local cNumero    := ""
Local cNumDoc1   := ""
Local cNumDoc2   := "" 
Local cTipDoc1   := ""
Local cTipDoc2   := ""       
Local cDtPagDoc1 := ""
Local cDtPagDoc2 := ""
Local cValorDoc1 := ""
Local cValorDoc2 := ""
Local cCodOpe    := ""
Local cMsg       := ""   
Local cCmp		 := "" 
Local dData 	 := stod("")
Local aDados     := {}
Local aRetPE     := {}
Local aRet       := {}
Local aArea      := TRB->(GetArea())   
Local aRetDad	 := {}   
Local lOk        := .T.
Local nValorDoc1 := 0
Local nValorDoc2 := 0                 
Local cIdPgDc    := "3"   //     1 – Encontro de Contas 2 – Câmara 3 – Entre Unimeds
Local lParc1     := .F.
default lAuto := .f.

SE1->(dbSetOrder(1)) //	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
BTO->(dbSetOrder(1)) //	BTO_FILIAL, BTO_CODOPE, BTO_NUMERO, BTO_OPEORI
SE5->(dbSetOrder(7)) // E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ

If TRB->Status == "1"
	MsgInfo("Já foi realizada uma operação de baixa para a fatura informada. ")
	Return
EndIf

If TRB->TpParc == 0 
	cCmp := "BTO->(BTO_PREFIX+BTO_NUMTIT)" // Titulo inicial 
ElseIf TRB->TpParc == 1 
	cCmp := "BTO->(BTO_GPFPRE+BTO_GPFTIT)" // Parcial 1      
	lParc1 := .T.
ElseIf TRB->TpParc == 2 
	cCmp := "BTO->(BTO_GP2PRE+BTO_GP2TIT)" // Parcial 2
	lParc1 := .T.	
ElseIf TRB->TpParc == 3 
	cCmp := "BTO->(BTO_GCOPRE+BTO_GCOTIT)" // Complementar
	lParc1 := .T.	
EndIf
 
cCodOpe := Substr(Trb->OpeOri,2,3)  
cNumero := TRB->Numero 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BTO_TPMOV 3 sao dois titulos, dois BTOs                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Trb->TpMov == "3"

	If BTO->(MsSeek(xFilial("BTO")+ PlsIntPad() + cNumero + TRB->(OpeOri))) // BTO->(BTO_CODOPE+BTO_NUMERO+BTO_OPEORI)
		While xFilial("BTO")+cNumero == BTO->(BTO_FILIAL+BTO_NUMERO) .And. !BTO->(Eof())
			If BTO->BTO_TPCOB == "1" //Documento 2 
				cNumDoc2 := Alltrim(&cCmp)  
				cTipDoc2 := "1"
				If SE1->(MsSeek(xFilial("SE1")+&cCmp))
			    	
			    	If  SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
    					
    					While !SE5->(EoF()) .And. SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) 
    						
	     					If SE5->E5_RECPAG == 'R'
	
								If SE5->E5_MOTBX = 'CEC' .AND. SE5->E5_TIPODOC $ ("BA","CP")
									cIdPgDc := "1"
								EndIf
				
	    						nValorDoc2 += SE5->E5_VALOR
	    					EndIf   					
	
				 			If cIdPgDc $ "3" .And. lParc1
				 				cIdPgDc := "2"					
				 			EndIf
										
    					SE5->(dbSkip())

						EndDo 
    					
    					If nValorDoc2 <> 0
    						cValorDoc2 := cValtoChar(nValorDoc2*100)   
    						cValorDoc2 := Substr(cValorDoc2,1,len(cValorDoc2)-2)+"."+Substr(cValorDoc2,len(cValorDoc2)-1,len(cValorDoc2))
    					Else
    						cValorDoc2 := cValtoChar(SE1->E1_VALOR*100)   
    						cValorDoc2 := Substr(cValorDoc2,1,len(cValorDoc2)-2)+"."+Substr(cValorDoc2,len(cValorDoc2)-1,len(cValorDoc2))
    					EndIf
    					
    				Else
    					cValorDoc2 := StrTran(cValToChar(SE1->E1_VALOR),",",".")     
    					cValorDoc2 := Substr(cValorDoc2,1,len(cValorDoc2)-2)+"."+Substr(cValorDoc2,len(cValorDoc2)-1,len(cValorDoc2))
    				EndIf
			    	
			    	
			    	If !Empty(SE1->E1_BAIXA)
			    		cDtPagDoc2 := SubStr(DtoS(SE1->E1_BAIXA),1,4) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),5,2) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),7,2)	
			     	Else
			       	lOk  := .F.
			       	cMsg += "Lote "+cNumero+" - O título "+&cCmp+" não foi baixado." 
			    	EndIf
  				EndIf        
				
			ElseIf BTO->BTO_TPCOB == "2" //Documento 1
				cNumDoc1 := Alltrim(&cCmp)
				cTipDoc1 := "1"  
				If SE1->(MsSeek(xFilial("SE1")+&cCmp))	    	
			    	
    				If  SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
    					
    					While !SE5->(EoF()) .And. SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)  

	     					If SE5->E5_RECPAG == 'R'
	
								If SE5->E5_MOTBX = 'CEC' .AND. SE5->E5_TIPODOC $ ("BA","CP")
									cIdPgDc := "1"
								EndIf
				
	    						nValorDoc1 += SE5->E5_VALOR
	    					EndIf   					
				 			If cIdPgDc $ "3" .And. lParc1
				 				cIdPgDc := "2"					
				 			EndIf
									
    					SE5->(dbSkip())
    					EndDo
    					
    					If nValorDoc1 <> 0
    						cValorDoc1 := cValtoChar(nValorDoc1*100)   
    						cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1))
    					Else
    						cValorDoc1 := cValtoChar(SE1->E1_VALOR*100)   
    						cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1))
    					EndIf
    					
    				Else
    	   				cValorDoc1 := cValtoChar(SE1->E1_VALOR*100)   
    					cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1))
    				EndIf
    				
					If !Empty(SE1->E1_BAIXA) .And. SE1->E1_SALDO == 0
			    		cDtPagDoc1 := SubStr(DtoS(SE1->E1_BAIXA),1,4) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),5,2) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),7,2) 
			    	Else
						cDtPagDoc1 := "        "
			    	EndIf
				EndIf
			EndIf
			
			BTO->(DbSkip())
		EndDo 
	EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BTO_TPMOV 1 e 2 somente um BTO e somente DOC 1                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	cNumDoc1 := Alltrim(TRB->NumDoc)  
	cTipDoc1 := "1"
		If BTO->(MsSeek(xFilial("BTO")+ PlsIntPad() + TRB->(cNumero + OpeOri))) 
			If SE1->(MsSeek(xFilial("SE1")+&cCmp))
				
			   	If  SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
	    			
	    			While !SE5->(EoF()) .And. SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)  
    					
						if SE5->E5_RECPAG == 'R'			
							If SE5->E5_MOTBX = 'CEC' .AND. SE5->E5_TIPODOC $ ("BA","CP")
								cIdPgDc := "1"
							EndIf				
							if SE5->E5_DATA > dData
								dData := SE5->E5_DATA
							endif
			    			nValorDoc1 += SE5->E5_VALOR
						elseif SE5->E5_RECPAG == 'P'
							nValorDoc1 -= SE5->E5_VALOR
			    		endif  
										
			 			If cIdPgDc $ "3" .And. lParc1
			 				cIdPgDc := "2"					
			 			EndIf
								
    					SE5->(dbSkip())    					
    				EndDo
    				
					if nValorDoc1 <= 0 
						nValorDoc1 := 0	 
						dData := stod("")
					endif

    				If nValorDoc1 <> 0
    					cValorDoc1 := cValtoChar(nValorDoc1*100)   
    					cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1))
    				Else
    					cValorDoc1 := cValtoChar(SE1->E1_VALOR*100)   
    					cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1))
    				EndIf
	    		Else
	    			cValorDoc1 := cValtoChar(SE1->E1_VALOR*100)   
    				cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1)) 			
	    		EndIf
	    			
				if !Empty(SE1->E1_BAIXA) .And. SE1->E1_SALDO == 0
					cDtPagDoc1 := SubStr(DtoS(SE1->E1_BAIXA),1,4) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),5,2) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),7,2)
				elseif SE1->E1_SALDO >= 0 .and. !empty(dData)
					cDtPagDoc1 := SubStr(DtoS(dData),1,4) + "-"	+ SubStr(DtoS(dData),5,2) + "-"	+ SubStr(DtoS(dData),7,2)
				else
					cDtPagDoc1 := "        "
			  	endif
			EndIf  
		EndIf     
EndIf

aRet := MntArray(cNumero,cCodOpe,cNumDoc1,cNumDoc2,cTipDoc1,cTipDoc2,cDtPagDoc1,cDtPagDoc2,lOk,cValorDoc1,cValorDoc2,"BTO",cMsg,cIdPgDc,lAuto)

RestArea(aArea)   

Return(aRet)    


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBRJENV
Envia uma fatura singular    

@author  Lucas Nonato
@since   24/11/2016
@version P11
/*/
//-------------------------------------------------------------------       
Function PLSBRJENV(lAuto)  
Local cNumero    := ""
Local cNumDoc1   := ""
Local cNumDoc2   := "" 
Local cTipDoc1   := ""
Local cTipDoc2   := ""       
Local cDtPagDoc1 := ""
Local cDtPagDoc2 := ""
Local cValorDoc1 := ""
Local cValorDoc2 := ""
Local cCodOpe    := ""
Local cMsg       := ""   
Local cCmpDOC1	 := "" 
Local cCmpDOC2	 := "" 
Local aRetPE     := {}
Local aRet       := {}
Local aArea      := TRB->(GetArea())   
Local aRetDad	 := {}   
Local lOk        := .T.
Local nValorDoc1 := 0
Local nValorDoc2 := 0
Local cIdPgDc    := "3"   //     1 – Encontro de Contas 2 – Câmara 3 – Entre Unimeds
default lAuto 	 := .f.

SE1->(dbSetOrder(1)) //	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
BRJ->(dbSetOrder(1)) //	BRJ_FILIAL, BRJ_CODIGO
SE5->(dbSetOrder(7)) // E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_SEQ

If TRB->Status == "1"
	MsgInfo("Já foi realizada uma operação de baixa para a fatura informada. ")
	Return
EndIf

If TRB->TpParc == 1 
	cCmpDOC1 := "BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)" // Parcial 1
	cCmpDOC2 := "BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)" 
ElseIf TRB->TpParc == 2 
	cCmpDOC1 := "BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)" // Parcial 2
	cCmpDOC2 := "BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP)" 
ElseIf TRB->TpParc == 3 
	cCmpDOC1 := "BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP)" // Complementar
	cCmpDOC2 := "BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP)" 
EndIf

cCodOpe := Substr(Trb->OpeOri,2,3)  
cNumero := TRB->Numero 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BRJ_TPCOB = 3 sao dois titulos                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Trb->TpMov == "3"
	If BRJ->(MsSeek(xFilial("BRJ")+ cNumero )) 		
		
		cNumDoc2 := Alltrim(&cCmpDOC2)  
		cTipDoc2 := "1"			
		
		// Titulo no Financeiro do documento 2
		If SE1->(MsSeek(xFilial("SE1")+&cCmpDOC2))
			// Movimentacoes do pagamento do titulo
			If  SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
    			
    			While !SE5->(EoF()) .And. SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) 
    				
     				If SE5->E5_RECPAG == 'R'

						If SE5->E5_MOTBX = 'CEC' .AND. SE5->E5_TIPODOC $ ("BA","CP")
							cIdPgDc := "1"
						EndIf
	
    					nValorDoc2 += SE5->E5_VALOR
    				EndIf   					
 					If cIdPgDc $ "3"
 						cIdPgDc := "2"					
 					EndIf
						
    				SE5->(dbSkip())
    			EndDo
    			
    			If nValorDoc2 <> 0
    				cValorDoc2 := cValtoChar(nValorDoc2*100)   
    				cValorDoc2 := Substr(cValorDoc2,1,len(cValorDoc2)-2)+"."+Substr(cValorDoc2,len(cValorDoc2)-1,len(cValorDoc2))
    			Else
    				cValorDoc2 := cValtoChar(SE1->E1_VALOR*100)   
    				cValorDoc2 := Substr(cValorDoc2,1,len(cValorDoc2)-2)+"."+Substr(cValorDoc2,len(cValorDoc2)-1,len(cValorDoc2))
    			EndIf	    			
    			
    		Else
    			cValorDoc2 := StrTran(cValToChar(SE1->E1_VALOR),",",".")
    		EndIf
			    	
			If !Empty(SE1->E1_BAIXA)
			    cDtPagDoc2 := SubStr(DtoS(SE1->E1_BAIXA),1,4) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),5,2) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),7,2)	
			Else
			   	lOk  := .F.
			   	cMsg += "Lote "+cNumero+" - O título "+&cCmpDOC2+" não foi baixado." 
			EndIf
			
  		EndIf	  
  	EndIf      
EndIf				
	
If BRJ->(MsSeek(xFilial("BRJ")+ cNumero )) 			
	cNumDoc1 := Alltrim(&cCmpDoc1)
	cTipDoc1 := "1"  
	// Titulo no Financeiro do documento 2
	If SE1->(MsSeek(xFilial("SE1")+&cCmpDoc1))	    	
		
		If  SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
			
			While !SE5->(EoF()) .And. SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) 
				
				If SE5->E5_RECPAG == 'R'
	
					If SE5->E5_MOTBX = 'CEC' .AND. SE5->E5_TIPODOC $ ("BA","CP")
						cIdPgDc := "1"
					EndIf
		
	    			nValorDoc1 += SE5->E5_VALOR
	    		EndIf   					
	 			If cIdPgDc $ "3"
	 				cIdPgDc := "2"					
	 			EndIf
							
	    		SE5->(dbSkip())
	    			
			EndDo
			
			If nValorDoc1 <> 0
    			cValorDoc1 := cValtoChar(nValorDoc1*100)   
    			cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1))
    		Else
    			cValorDoc1 := cValtoChar(SE1->E1_VALOR*100)   
    			cValorDoc1 := Substr(cValorDoc1,1,len(cValorDoc1)-2)+"."+Substr(cValorDoc1,len(cValorDoc1)-1,len(cValorDoc1))
    		EndIf
    		
		Else
			cValorDoc1 := StrTran(cValToChar(SE1->E1_VALOR),",",".")
		EndIf
		
		If !Empty(SE1->E1_BAIXA) .And. SE1->E1_SALDO == 0
			cDtPagDoc1 := SubStr(DtoS(SE1->E1_BAIXA),1,4) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),5,2) + "-"	+ SubStr(DtoS(SE1->E1_BAIXA),7,2) 
		Else
			cDtPagDoc1 := "        "
		EndIf
		
	EndIf
			
EndIf 

aRet := MntArray(cNumero,cCodOpe,cNumDoc1,cNumDoc2,cTipDoc1,cTipDoc2,cDtPagDoc1,cDtPagDoc2,lOk,cValorDoc1,cValorDoc2,"BRJ",cMsg,cIdPgDc,lAuto)

RestArea(aArea)   
Return(aRet) 


//-------------------------------------------------------------------
/*/{Protheus.doc} MntArray
Monta estrutura de envio  

@author  Lucas Nonato
@since   20/01/2017
@version P11
/*/
//-------------------------------------------------------------------  
Static Function MntArray(cNumero,cCodOpe,cNumDoc1,cNumDoc2,cTipDoc1,cTipDoc2,cDtPagDoc1,cDtPagDoc2,lOk,cValorDoc1,cValorDoc2, cAlias, cMsg, cIdPgDc, lAuto)
Local aDados := {}
Local aRetPE := {}
Local aRet	 := {}         
Default cMsg   := ""
Default cIdPgDc:= "3"
Default lAuto:= .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para o usuario alterar as informacoes enviadas		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBLock("PLU510P1")

   	aRetPE := ExecBlock("PLU510P1",.F.,.F.,{cNumero,cCodOpe,cNumDoc1,cNumDoc2,cTipDoc1,cTipDoc2,cDtPagDoc1,cDtPagDoc2,lOk,cValorDoc1,cValorDoc2,SE1->(Recno()) })
	cNumero    := aRetPE[1]
	cCodOpe    := aRetPE[2]
	cNumDoc1   := aRetPE[3]
	cNumDoc2   := aRetPE[4]
	cTipDoc1   := aRetPE[5]
	cTipDoc2   := aRetPE[6]
	cDtPagDoc1 := aRetPE[7]
	cDtPagDoc2 := aRetPE[8]
	lOk        := aRetPE[9]
	cMsg       := aRetPE[10] 
	cValorDoc1 := aRetPE[11]
	cValorDoc2 := aRetPE[12]

EndIf

If lOk

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array com dados para geracao do arquivo XML                		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Aadd(aDados,cCodOpe)   //CD_UNI_ORI     - Código da Unimed que recebeu a cobrança
	Aadd(aDados,cNumDoc1)  //NR_DOCUMENTO_1 - Numero do Documento 1
	Aadd(aDados,cNumDoc2)  //NR_DOCUMENTO_2 - Numero do Documento 2
	Aadd(aDados,cTipDoc1)  //TP_DOCUMENTO_1 - Tipo do documento 1
	Aadd(aDados,cTipDoc2)  //TP_DOCUMENTO_2 - Tipo do documento 2
	Aadd(aDados,IIF(EMPTY(cDtPagDoc1),"0",cValorDoc1))//VL_PAGO_DOC_1 - Valor total pago do Documento 1
	Aadd(aDados,cValorDoc2)//VL_PAGO_DOC_2 - Valor total pago do Documento 2
	Aadd(aDados,cDtPagDoc1)//DT_PAGA_DOC_1 - Data do pagamento do Documento 1
	Aadd(aDados,cDtPagDoc2)//DT_PAGA_DOC_2 Data do pagamento do Documento 2
	Aadd(aDados,cIdPgDc)       //ID_PAGA_DOC_1 Identificador do pagamento do Documento 1
	Aadd(aDados,Iif(Empty(cNumDoc2),"",cIdPgDc))       //ID_PAGA_DOC_2 Identificador do pagamento do Documento 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo XML                										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	aRetDad := GeraXml(aDados)     
	If aRetDad[1]
		
		If GetNewPar("MV_P510LOG",.F.)
			PlsPtuLog("-----------------------------------------------", "Ptu510.log")
			PlsPtuLog("Enviando A510 ", "Ptu510.log")    
			PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time(), "Ptu510.log")
			PlsPtuLog("-----------------------------------------------", "Ptu510.log")
			PlsPtuLog("Soap Enviado:", "Ptu510.log")	
			PlsPtuLog(aRetDad[2], "Ptu510.log")
	 	EndIf
	 	
		PLPt510Wsdl("solicitarBaixaWS",aRetDad[2],cAlias,lAuto)
	Else
		MsgInfo(aRetDad[3])
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento em lote monta array de retorno							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 	

Else
 	Aviso( "Não foi possível gerar o arquivo", cMsg , {"Ok"} )
EndIf

Return(aRet) 
//-------------------------------------------------------------------
/*/{Protheus.doc} PLPt510Wsdl
Gera os arquivos .pem para conectar com o WebService

@author  Lucas Nonato
@version P11
@since   24/11/2016      
/*/
//-------------------------------------------------------------------     
Function PLPt510Wsdl(cAcao,cXml,cAlias,lAuto) 
Local oWsdl       
Local cPFX   := PLSMUDSIS("\plsptu\A510\certificados\certificado.p12")
Local cCert  := PLSMUDSIS("\plsptu\A510\certificados\cert.pem")  
Local cKey   := PLSMUDSIS("\plsptu\A510\certificados\key.pem")  
Local cPass  := GetNewPar("MV_P510SEN","")
Local cError := ""    
Local cSoap  := ""           
Local cUrl   := GetNewPar("MV_PTSOLBX","https://cmbhml.unimed.coop.br/ws/inadimplencia/solicitarBaixa?wsdl")   
Local cOper  := "solicitarBaixaOperation"    
Local lRet   := .T.
Local nAt    := 0

default lAuto := .f.
//Extrai o Cert do arquivo PFX
If !File(cCert)
	If !PFXCert2PEM( cPFX, cCert, @cError, cPass )
		cError += "Não foi possível gerar o arquivo Cert." + Chr(10)
		lRet := .F.
	EndIf
EndIf

//Extrai a Key do arquivo PFX
If !File(cKey)
	If !PFXKey2PEM( cPFX, cKey, @cError, cPass )
		cError += "Não foi possível gerar o arquivo Key." + Chr(10)      
		lRet := .F.
	EndIf        
EndIf

If !File(cPFX)
	cError += "Certificado não encontrado" + Chr(10)  
	lRet := .F.
EndIf

If lRet .or. lAuto

	oWsdl := TwsdlManager():New()
	oWsdl:cSSLCertFile     := cCert
	oWsdl:cSSLKeyFile      := cKey
	oWsdl:cSSLKeyPwd       := cPass   
	oWsdl:bNoCheckPeerCert := .T. 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza o Parse da URL com o EndPoint                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	If oWsdl:ParseURL( cURL ) 
		aOps := oWsdl:ListOperations() 
		If len(aOps) > 0  
			cOper := aOps[1][1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seta a Operacao  					                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
			If oWsdl:SetOperation(cOper)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia o SOAP     					                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
			    oWsdl:SendSoapMsg(EncodeUTF8(cXml))
			    cSoap := (oWsdl:GetSoapResponse() )
		    EndIf
		Else
			lRet   := .F.
			cError := "Não foi possível realizar a comunicacao: Nao foi possivel encontrar a lista de Operacoes do WebService"
		Endif		    
	EndIf  

	//cSoap := SOAPRESP()//SOAPRESP()
	If Empty(cSoap)
		cError := "Não foi possível realizar a comunicacao: Operadora Fora do Ar"
	EndIf
	
	If GetNewPar("MV_P510LOG",.F.)
		PlsPtuLog("-----------------------------------------------", "Ptu510.log")
		PlsPtuLog("Recebendo A515 ", , "Ptu510.log")    
		PlsPtuLog(Substr(Dtos(dDataBase),7,2)+"/"+Substr(Dtos(dDataBase),5,2)+"/"+Substr(Dtos(dDataBase),1,4) + " - " + Time() , "Ptu510.log")
		PlsPtuLog("-----------------------------------------------", "Ptu510.log")
		PlsPtuLog("Soap Recebido:", "Ptu510.log")	
		PlsPtuLog(cSoap, "Ptu510.log")
	EndIf
	lRet := LeSoapXml('515',cSoap,cAlias)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa a resposta de erro  		                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	If !lRet .And. !Empty(oWsdl:cError)                  
		If (nAt := At('FAULT STRING:',Upper(oWsdl:cError)) ) > 0 
			cError := "Não foi possível realizar a comunicacao: " + Substr(oWsdl:cError,nAt+len('FAULT STRING:'),len(oWsdl:cError))
		Else
			cError := "Não foi possível realizar a comunicacao: " + oWsdl:cError
		EndIf	
		lRet := .F.
	EndIf 
Else
	Alert(cError) 
EndIf

If !Empty(cError) .and. !lAuto
	MsgAlert(cError)
EndIf 

Return({lRet,cSoap,cError})  

//-------------------------------------------------------------------
/*/{Protheus.doc} LeSoapXml
Funcao para leitura do SOAP

@author  Lucas Nonato
@version P11
@since   28/11/16
/*/
//------------------------------------------------------------------- 
Static Function LeSoapXml(cCodTra,cSoap,cAlias)
Local lRetObj	:= .F.
Local lErroInesp:= .F.
Local aRetObj	:= {}
Local cErro		:= ""
Local cAviso	:= ""
Local cStatus 	:= ""
Local lUnico	:= .F.
Local nPosErro	:= 0
Local bGui    := {||Iif(lUnico,"","["+cValtoChar(1)+"]")}


aRetObj := PLVldXmlPT(@cErro,@cAviso,cSoap)
If aRetObj[1]
	lRetObj    := aRetObj[1]
	oObjXml    := aRetObj[2]	
ElseIf Len(aRetObj) > 1 // Erro Inesperado
	lRetObj    := aRetObj[1]
	oObjXml    := aRetObj[2]
	lErroInesp := .T.
Else
	lRetObj    := aRetObj[1]
EndIf  

If lRetObj 

	//Define a regra caso tenha somente um beneficiario enviado
	If Type("oObjXml:_RESPOSTASOLICITARBAIXA:_STATUSRETORNO:_STATUSBAIXA") <> "U"
		lUnico := .T.
	EndIf
	
	cStatus := PLRetTagWB(oObjXml,"_","respostaSolicitarBaixa\statusRetorno"+ Eval(bGui) +"\statusBaixa\")
	(cAlias)->(dbGoTo(TRB->Recno))
	(cAlias)->(Reclock(cAlias,.F.))
		If cStatus == 'S'
			// Foi criado um campo de Status para cada tipo de titulo
			If TRB->TpParc == 0 
				(cAlias)->&(cAlias+"_STTIT") := '1' // Titulo inicial
			ElseIf TRB->TpParc == 1 
				(cAlias)->&(cAlias+"_STTP1") := '1' // Parcial 1
			ElseIf TRB->TpParc == 2 
				(cAlias)->&(cAlias+"_STTP2") := '1' // Parcial 2
			ElseIf TRB->TpParc == 3 
				(cAlias)->&(cAlias+"_STTCO") := '1' // Complementar
			EndIf
			
			MsgInfo('Baixa do Documento Realizada com Sucesso')
		Else
			If TRB->TpParc == 0 
				(cAlias)->&(cAlias+"_STTIT") := '2' // Titulo inicial
			ElseIf TRB->TpParc == 1 
				(cAlias)->&(cAlias+"_STTP1") := '2' // Parcial 1
			ElseIf TRB->TpParc == 2 
				(cAlias)->&(cAlias+"_STTP2") := '2' // Parcial 2
			ElseIf TRB->TpParc == 3 
				(cAlias)->&(cAlias+"_STTCO") := '2' // Complementar
			EndIf
			nPosErro := aScan(aErros,{|x| AllTrim(x[1]) == PLRetTagWB(oObjXml,"_","respostaSolicitarBaixa\statusRetorno"+ Eval(bGui) +"\codigoMensagemRetorno\")})
			If nPosErro  > 0
				MsgInfo('Baixa do Documento Negada '+ CRLF +  "Retorno da Unimed do Brasil: " + aErros[nPosErro][2])
			Else
				MsgInfo('Baixa do Documento Negada')
			EndIf
		EndIf
		
	(cAlias)->(MsUnlock())
	
	//Atualiza Temporario para exibição no browse
	TRB->(RecLock("TRB",.F.))
		TRB->Status := Iif(cStatus == 'S','1','2')
	TRB->(MsUnlock())
	
	
ElseIf lErroInesp
	cStatus := '2'		
	
	(cAlias)->(dbGoTo(TRB->Recno))
	(cAlias)->(Reclock(cAlias,.F.))
	
	If TRB->TpParc == 0 
		(cAlias)->&(cAlias+"_STTIT") := '2' // Titulo inicial
	ElseIf TRB->TpParc == 1 
		(cAlias)->&(cAlias+"_STTP1") := '2' // Parcial 1
	ElseIf TRB->TpParc == 2 
		(cAlias)->&(cAlias+"_STTP2") := '2' // Parcial 2
	ElseIf TRB->TpParc == 3 
		(cAlias)->&(cAlias+"_STTCO") := '2' // Complementar
	EndIf
	
		
	(cAlias)->(MsUnlock())
	//MsgInfo(oObjXML:_FAULTSTRING:TEXT)
EndIf

Return lRetObj

//-------------------------------------------------------------------
/*/{Protheus.doc} PLVldXmlPT
Ajusta um soap de recebimento para montagem do objeto de trabalho

@author  Lucas Nonato
@version P11
@since   28/06/16
/*/
//------------------------------------------------------------------- 
Static Function PLVldXmlPT(cErro,cAviso,cSoap)
Local cSoapAux   := ''   
Local nPos       := 0   
Local nX         := 0
Local lRet       := .T.
Local oXml

nPos := At("BODY",Upper(cSoap))
cSoapAux := Substr(cSoap,nPos+4,len(cSoap))    
nPos := At(">",Upper(cSoapAux))
cSoapAux := Substr(cSoapAux,nPos+1,len(cSoapAux))  

nPos := At("BODY",Upper(cSoapAux)) 
For nX := 1 to nPos 
	If Substr(cSoapAux,nPos-nX,1) == "<"
		cSoapAux := Substr(cSoapAux,1,nPos-(nX+1))
		Exit
	EndIf   
Next

If nPos == 0 .Or. Empty(cSoap)
	cErro := "Erro com o pacote Soap recebido"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria diretorios                                   					     	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If !ExistDir("\plsptu\")
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\") == 3  
		cErro := "Não foi possivel criar o diretorio \plsptu"     
	EndIf      
EndIf
If !ExistDir("\plsptu\A510\")
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\A510\") == 3  
		cErro := "Não foi possivel criar o diretorio \plsptu\A510\"     
	EndIf      
EndIf

If !ExistDir("\plsptu\A510\schemas\")
	If MakeDir(GetSrvProfString ("ROOTPATH","")+"\plsptu\A510\schemas\") == 3
		cErro := "Não foi possivel criar o diretorio \plsptu\A510\schemas\" 
	EndIf  
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houve erro fatal finaliza							                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
If !Empty(cErro)
	Return {.F.}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o parse             							                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
cSoapAux := EncodeUTF8(cSoapAux)
oXml := XmlParser( cSoapAux ,"_",@cErro,@cAviso )    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para montagem do arquivo para validacao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                        
nPos := At(">",Upper(cSoapAux))      
cSoapPt1 := Substr(cSoapAux,1,nPos-1)
cSoapPt2 := Substr(cSoapAux,nPos,len(cSoapAux))
cSoapXml := cSoapPt1 + ' <v1:solicitarBaixaWS xsi:schemaLocation="http://mi.unimed.coop.br/schemas/V1_00_00 mi_Transacoes-V1_00_00.xsd" xmlns:v1="http://mi.unimed.coop.br/schemas/V1_00_00" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'  + cSoapPt2  

aMatAux 	:= classDataArr(oXml)
nPos 		:= ( At("_",SubStr( aMatAux[Len(aMatAux),1],2 ) )+1 )
cNameSpace 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],1,nPos ) )
cNameEleme 	:= Upper( SubStr( aMatAux[Len(aMatAux),1],(nPos+1) ) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura bruta															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjXml := XmlChildEx(oXml,"_"+cNameEleme)   

Return {lRet,oObjXml,cErro}          


//-------------------------------------------------------------------
/*/{Protheus.doc} retErro
Carrega Tabela de Mensagens de Erros - Mensagem de Retorno Inadimplência disponivel no Anexos PTU Batch

@author  Lucas Nonato
@version P11
@since   10/01/2017
/*/
//------------------------------------------------------------------- 
Static Function retErro(aRetInad)

aAdd(aRetInad,{"6001","Erro desconhecido ao recuperar o histórico de ações do processo de baixa."})
aAdd(aRetInad,{"6002","Erro desconhecido ao processar a baixa."})
aAdd(aRetInad,{"6003","Tamanho do campo inválido"})
aAdd(aRetInad,{"6004","O campo de CD_UNI_DES da mensagem de solicitação de baixa deverá sempre ser preenchido com '999' - Unimed do Brasil."})
aAdd(aRetInad,{"6005","Formato de dado incompatível com o tipo."})
aAdd(aRetInad,{"6006","Campo de preenchimento obrigatório"})
aAdd(aRetInad,{"6007","Código da Unimed desconhecido."})
aAdd(aRetInad,{"6008","Já foi realizada uma operação de baixa para a fatura informada."})
aAdd(aRetInad,{"6009","A data de pagamento do documento não pode ser futura."})
aAdd(aRetInad,{"6010","Caso seja informada a baixa do Documento 2, todos os campos NUMERO_DOC_2, VALOR_PAGO_DOC_2, DATA_PAGAMENTO_DOC_2 e ENCONTRO_CONTAS_DOC_2 devem ser preenchidos."})
aAdd(aRetInad,{"6011","Não foi encontrado o documento informado para realização da baixa."})
aAdd(aRetInad,{"6012","O documento não pode ser marcado como Inadimplente antes do seu vencimento."})
aAdd(aRetInad,{"6013","A data de pagamento do documento não pode ser sido feita antes da postagem da fatura."})
aAdd(aRetInad,{"6014","O valor pago não pode ser maior que o valor total do documento."})
aAdd(aRetInad,{"6015","Quando houver uma constestação (A550) de pagamento parcial relacionado à fatura (A500) o valor pago informado não pode ser maior que a diferença entre o valor total do documento e o valor contestado."})
aAdd(aRetInad,{"6016","Já foi informado um valor para o encontro de contas que difere do que foi informado"})
aAdd(aRetInad,{"6017","Deverá ser informado a baixa do documento 2, senão, não será possível a realização da baixa do documento 1"})
aAdd(aRetInad,{"6018","Não é possível realizar baixa em faturas canceladas ou devolvidas"})
aAdd(aRetInad,{"6019","Fatura já está marcada como Inadimplente Total"})
aAdd(aRetInad,{"6020","Erro Inesperado"})

Return aRetInad      

function PLSUA510LE(cCodTra,cSoap,cAlias)
return LeSoapXml(cCodTra,cSoap,cAlias)